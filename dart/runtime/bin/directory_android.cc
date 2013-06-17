// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "platform/globals.h"
#if defined(TARGET_OS_ANDROID)

#include "bin/directory.h"

#include <dirent.h>  // NOLINT
#include <errno.h>  // NOLINT
#include <string.h>  // NOLINT
#include <sys/param.h>  // NOLINT
#include <sys/stat.h>  // NOLINT
#include <unistd.h>  // NOLINT

#include "bin/file.h"
#include "bin/platform.h"


namespace dart {
namespace bin {


PathBuffer::PathBuffer() : length_(0) {
  data_ = new char[PATH_MAX + 1];
}

bool PathBuffer::AddW(const wchar_t* name) {
  UNREACHABLE();
  return false;
}

char* PathBuffer::AsString() const {
  return reinterpret_cast<char*>(data_);
}

wchar_t* PathBuffer::AsStringW() const {
  UNREACHABLE();
  return NULL;
}

bool PathBuffer::Add(const char* name) {
  char* data = AsString();
  int written = snprintf(data + length_,
                         PATH_MAX - length_,
                         "%s",
                         name);
  data[PATH_MAX] = '\0';
  if (written <= PATH_MAX - length_ &&
      written >= 0 &&
      static_cast<size_t>(written) == strnlen(name, PATH_MAX + 1)) {
    length_ += written;
    return true;
  } else {
    errno = ENAMETOOLONG;
    return false;
  }
}

void PathBuffer::Reset(int new_length) {
  length_ = new_length;
  AsString()[length_] = '\0';
}


// A linked list of symbolic links, with their unique file system identifiers.
// These are scanned to detect loops while doing a recursive directory listing.
struct LinkList {
  dev_t dev;
  ino_t ino;
  LinkList* next;
};


ListType DirectoryListingEntry::Next(DirectoryListing* listing) {
  if (done_) {
    return kListDone;
  }

  if (lister_ == 0) {
    if (!listing->path_buffer().Add(File::PathSeparator())) {
      done_ = true;
      return kListError;
    }
    path_length_ = listing->path_buffer().length();
    do {
      lister_ = reinterpret_cast<intptr_t>(
          opendir(listing->path_buffer().AsString()));
    } while (lister_ == 0 && errno == EINTR);

    if (lister_ == 0) {
      done_ = true;
      return kListError;
    }
  }
  // Reset.
  listing->path_buffer().Reset(path_length_);
  ResetLink();

  // Iterate the directory and post the directories and files to the
  // ports.
  int status = 0;
  dirent entry;
  dirent* result;
  if ((status = TEMP_FAILURE_RETRY(readdir_r(reinterpret_cast<DIR*>(lister_),
                                    &entry,
                                    &result))) == 0 &&
      result != NULL) {
    if (!listing->path_buffer().Add(entry.d_name)) {
      done_ = true;
      return kListError;
    }
    switch (entry.d_type) {
      case DT_DIR:
        if (strcmp(entry.d_name, ".") == 0) return Next(listing);
        if (strcmp(entry.d_name, "..") == 0) return Next(listing);
        return kListDirectory;
      case DT_REG:
        return kListFile;
      case DT_LNK:
        if (!listing->follow_links()) {
          return kListLink;
        }
        // Else fall through to next case.
        // Fall through.
      case DT_UNKNOWN: {
        // On some file systems the entry type is not determined by
        // readdir_r. For those and for links we use stat to determine
        // the actual entry type. Notice that stat returns the type of
        // the file pointed to.
        struct stat entry_info;
        int stat_success;
        stat_success = TEMP_FAILURE_RETRY(
            lstat(listing->path_buffer().AsString(), &entry_info));
        if (stat_success == -1) {
          return kListError;
        }
        if (listing->follow_links() && S_ISLNK(entry_info.st_mode)) {
          // Check to see if we are in a loop created by a symbolic link.
          LinkList current_link = { entry_info.st_dev,
                                    entry_info.st_ino,
                                    link_ };
          LinkList* previous = link_;
          while (previous != NULL) {
            if (previous->dev == current_link.dev &&
                previous->ino == current_link.ino) {
              // Report the looping link as a link, rather than following it.
              return kListLink;
            }
            previous = previous->next;
          }
          stat_success = TEMP_FAILURE_RETRY(
              stat(listing->path_buffer().AsString(), &entry_info));
          if (stat_success == -1) {
            // Report a broken link as a link, even if follow_links is true.
            return kListLink;
          }
          if (S_ISDIR(entry_info.st_mode)) {
            // Recurse into the subdirectory with current_link added to the
            // linked list of seen file system links.
            link_ = new LinkList(current_link);
            if (strcmp(entry.d_name, ".") == 0) return Next(listing);
            if (strcmp(entry.d_name, "..") == 0) return Next(listing);
            return kListDirectory;
          }
        }
        if (S_ISDIR(entry_info.st_mode)) {
          if (strcmp(entry.d_name, ".") == 0) return Next(listing);
          if (strcmp(entry.d_name, "..") == 0) return Next(listing);
          return kListDirectory;
        } else if (S_ISREG(entry_info.st_mode)) {
          return kListFile;
        } else if (S_ISLNK(entry_info.st_mode)) {
          return kListLink;
        }
      }

      default:
        break;
    }
  }
  done_ = true;

  if (status != 0) {
    errno = status;
    return kListError;
  }

  if (closedir(reinterpret_cast<DIR*>(lister_)) == -1) {
    return kListError;
  }

  return kListDone;
}


static bool DeleteRecursively(PathBuffer* path);


static bool DeleteFile(char* file_name,
                       PathBuffer* path) {
  return path->Add(file_name) && unlink(path->AsString()) == 0;
}


static bool DeleteDir(char* dir_name,
                      PathBuffer* path) {
  if (strcmp(dir_name, ".") == 0) return true;
  if (strcmp(dir_name, "..") == 0) return true;
  return path->Add(dir_name) && DeleteRecursively(path);
}


static bool DeleteRecursively(PathBuffer* path) {
  // Do not recurse into links for deletion. Instead delete the link.
  // If it's a file, delete it.
  struct stat st;
  if (TEMP_FAILURE_RETRY(lstat(path->AsString(), &st)) == -1) {
    return false;
  } else if (S_ISREG(st.st_mode) || S_ISLNK(st.st_mode)) {
    return (unlink(path->AsString()) == 0);
  }

  if (!path->Add(File::PathSeparator())) return false;

  // Not a link. Attempt to open as a directory and recurse into the
  // directory.
  DIR* dir_pointer;
  do {
    dir_pointer = opendir(path->AsString());
  } while (dir_pointer == NULL && errno == EINTR);

  if (dir_pointer == NULL) {
    return false;
  }

  // Iterate the directory and delete all files and directories.
  int path_length = path->length();
  int read = 0;
  bool success = true;
  dirent entry;
  dirent* result;
  while ((read = TEMP_FAILURE_RETRY(readdir_r(dir_pointer,
                                              &entry,
                                              &result))) == 0 &&
         result != NULL &&
         success) {
    switch (entry.d_type) {
      case DT_DIR:
        success = success && DeleteDir(entry.d_name, path);
        break;
      case DT_REG:
      case DT_LNK:
        // Treat all links as files. This will delete the link which
        // is what we want no matter if the link target is a file or a
        // directory.
        success = success && DeleteFile(entry.d_name, path);
        break;
      case DT_UNKNOWN: {
        // On some file systems the entry type is not determined by
        // readdir_r. For those we use lstat to determine the entry
        // type.
        struct stat entry_info;
        if (!path->Add(entry.d_name)) {
          success = false;
          break;
        }
        int lstat_success = TEMP_FAILURE_RETRY(
            lstat(path->AsString(), &entry_info));
        if (lstat_success == -1) {
          success = false;
          break;
        }
        path->Reset(path_length);
        if (S_ISDIR(entry_info.st_mode)) {
          success = success && DeleteDir(entry.d_name, path);
        } else if (S_ISREG(entry_info.st_mode) || S_ISLNK(entry_info.st_mode)) {
          // Treat links as files. This will delete the link which is
          // what we want no matter if the link target is a file or a
          // directory.
          success = success && DeleteFile(entry.d_name, path);
        }
        break;
      }
      default:
        break;
    }
    path->Reset(path_length);
  }

  if ((read != 0) ||
      (closedir(dir_pointer) == -1) ||
      (remove(path->AsString()) == -1)) {
    return false;
  }
  return success;
}


Directory::ExistsResult Directory::Exists(const char* dir_name) {
  struct stat entry_info;
  int success = TEMP_FAILURE_RETRY(stat(dir_name, &entry_info));
  if (success == 0) {
    if (S_ISDIR(entry_info.st_mode)) {
      return EXISTS;
    } else {
      return DOES_NOT_EXIST;
    }
  } else {
    if (errno == EACCES ||
        errno == EBADF ||
        errno == EFAULT ||
        errno == ENOMEM ||
        errno == EOVERFLOW) {
      // Search permissions denied for one of the directories in the
      // path or a low level error occured. We do not know if the
      // directory exists.
      return UNKNOWN;
    }
    ASSERT(errno == ELOOP ||
           errno == ENAMETOOLONG ||
           errno == ENOENT ||
           errno == ENOTDIR);
    return DOES_NOT_EXIST;
  }
}


char* Directory::Current() {
  // Android's getcwd adheres closely to the POSIX standard. It won't
  // allocate memory. We need to make our own copy.

  char buffer[PATH_MAX];
  if (NULL == getcwd(buffer, PATH_MAX)) {
    return NULL;
  }

  return strdup(buffer);
}


bool Directory::SetCurrent(const char* path) {
  int result = TEMP_FAILURE_RETRY(chdir(path));
  return result == 0;
}


bool Directory::Create(const char* dir_name) {
  // Create the directory with the permissions specified by the
  // process umask.
  int result = TEMP_FAILURE_RETRY(mkdir(dir_name, 0777));
  // If the directory already exists, treat it as a success.
  if (result == -1 && errno == EEXIST) {
    return (Exists(dir_name) == EXISTS);
  }
  return (result == 0);
}


// Android doesn't currently provide mkdtemp.  Once Android provied mkdtemp,
// remove this function in favor of calling mkdtemp directly.
static char* MakeTempDirectory(char* path_template) {
  if (mktemp(path_template) == NULL) {
    return NULL;
  }
  if (mkdir(path_template, 0700) != 0) {
    return NULL;
  }
  return path_template;
}


char* Directory::CreateTemp(const char* const_template) {
  // Returns a new, unused directory name, modifying the contents of
  // dir_template.  Creates the directory with the permissions specified
  // by the process umask.
  // The return value must be freed by the caller.
  PathBuffer path;
  path.Add(const_template);
  if (path.length() == 0) {
    // Android does not have a /tmp directory. A partial substitute,
    // suitable for bring-up work and tests, is to create a tmp
    // directory in /data/local/tmp.
    //
    // TODO(4413): In the long run, when running in an application we should
    // probably use android.content.Context.getCacheDir().
    #define ANDROID_TEMP_DIR "/data/local/tmp"
    struct stat st;
    if (stat(ANDROID_TEMP_DIR, &st) != 0) {
      mkdir(ANDROID_TEMP_DIR, 0777);
    }
    path.Add(ANDROID_TEMP_DIR "/temp_dir1_");
  } else if ((path.AsString())[path.length() - 1] == '/') {
    path.Add("temp_dir_");
  }
  if (!path.Add("XXXXXX")) {
    // Pattern has overflowed.
    return NULL;
  }
  char* result;
  do {
    result = MakeTempDirectory(path.AsString());
  } while (result == NULL && errno == EINTR);
  if (result == NULL) {
    return NULL;
  }
  int length = strnlen(path.AsString(), PATH_MAX);
  result = static_cast<char*>(malloc(length + 1));
  strncpy(result, path.AsString(), length);
  result[length] = '\0';
  return result;
}


bool Directory::Delete(const char* dir_name, bool recursive) {
  if (!recursive) {
    if (File::GetType(dir_name, false) == File::kIsLink &&
        File::GetType(dir_name, true) == File::kIsDirectory) {
      return (TEMP_FAILURE_RETRY(unlink(dir_name)) == 0);
    }
    return (TEMP_FAILURE_RETRY(rmdir(dir_name)) == 0);
  } else {
    PathBuffer path;
    if (!path.Add(dir_name)) {
      return false;
    }
    return DeleteRecursively(&path);
  }
}


bool Directory::Rename(const char* path, const char* new_path) {
  ExistsResult exists = Exists(path);
  if (exists != EXISTS) return false;
  return (TEMP_FAILURE_RETRY(rename(path, new_path)) == 0);
}

}  // namespace bin
}  // namespace dart

#endif  // defined(TARGET_OS_ANDROID)
