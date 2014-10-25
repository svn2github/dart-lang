library java.engine;

import 'interner.dart';
import 'java_core.dart';

/**
 * A predicate is a one-argument function that returns a boolean value.
 */
typedef bool Predicate<E>(E argument);

class StringUtilities {
  static const String EMPTY = '';
  static const List<String> EMPTY_ARRAY = const <String>[];

  static Interner INTERNER = new NullInterner();

  static String intern(String string) => INTERNER.intern(string);
  static bool isTagName(String s) {
    if (s == null || s.length == 0) {
      return false;
    }
    int sz = s.length;
    for (int i = 0; i < sz; i++) {
      int c = s.codeUnitAt(i);
      if (!Character.isLetter(c)) {
        if (i == 0) {
          return false;
        }
        if (!Character.isDigit(c) && c != 0x2D) {
          return false;
        }
      }
    }
    return true;
  }
  static bool isEmpty(String s) {
    return s == null || s.isEmpty;
  }
  static String substringBefore(String str, String separator) {
    if (str == null || str.isEmpty) {
      return str;
    }
    if (separator == null) {
      return str;
    }
    int pos = str.indexOf(separator);
    if (pos < 0) {
      return str;
    }
    return str.substring(0, pos);
  }
  static endsWithChar(String str, int c) {
    int length = str.length;
    return length > 0 && str.codeUnitAt(length - 1) == c;
  }
  static endsWith3(String str, int c1, int c2, int c3) {
    var length = str.length;
    return length >= 3 && str.codeUnitAt(length - 3) == c1 && str.codeUnitAt(
        length - 2) == c2 && str.codeUnitAt(length - 1) == c3;
  }

  static startsWithChar(String str, int c) {
    return str.length != 0 && str.codeUnitAt(0) == c;
  }
  static startsWith2(String str, int start, int c1, int c2) {
    return str.length - start >= 2 && str.codeUnitAt(start) == c1 &&
        str.codeUnitAt(start + 1) == c2;
  }
  static startsWith3(String str, int start, int c1, int c2, int c3) {
    return str.length - start >= 3 && str.codeUnitAt(start) == c1 &&
        str.codeUnitAt(start + 1) == c2 && str.codeUnitAt(start + 2) == c3;
  }
  static startsWith4(String str, int start, int c1, int c2, int c3, int c4) {
    return str.length - start >= 4 && str.codeUnitAt(start) == c1 &&
        str.codeUnitAt(start + 1) == c2 && str.codeUnitAt(start + 2) == c3 &&
        str.codeUnitAt(start + 3) == c4;
  }
  static startsWith5(String str, int start, int c1, int c2, int c3, int c4, int
      c5) {
    return str.length - start >= 5 && str.codeUnitAt(start) == c1 &&
        str.codeUnitAt(start + 1) == c2 && str.codeUnitAt(start + 2) == c3 &&
        str.codeUnitAt(start + 3) == c4 && str.codeUnitAt(start + 4) == c5;
  }
  static startsWith6(String str, int start, int c1, int c2, int c3, int c4, int
      c5, int c6) {
    return str.length - start >= 6 && str.codeUnitAt(start) == c1 &&
        str.codeUnitAt(start + 1) == c2 && str.codeUnitAt(start + 2) == c3 &&
        str.codeUnitAt(start + 3) == c4 && str.codeUnitAt(start + 4) == c5 &&
        str.codeUnitAt(start + 5) == c6;
  }
  static int indexOf1(String str, int start, int c) {
    int index = start;
    int last = str.length;
    while (index < last) {
      if (str.codeUnitAt(index) == c) {
        return index;
      }
      index++;
    }
    return -1;
  }
  static int indexOf2(String str, int start, int c1, int c2) {
    int index = start;
    int last = str.length - 1;
    while (index < last) {
      if (str.codeUnitAt(index) == c1 && str.codeUnitAt(index + 1) == c2) {
        return index;
      }
      index++;
    }
    return -1;
  }
  static int indexOf4(String string, int start, int c1, int c2, int c3, int c4)
      {
    int index = start;
    int last = string.length - 3;
    while (index < last) {
      if (string.codeUnitAt(index) == c1 && string.codeUnitAt(index + 1) == c2
          && string.codeUnitAt(index + 2) == c3 && string.codeUnitAt(index + 3) == c4) {
        return index;
      }
      index++;
    }
    return -1;
  }
  static int indexOf5(String str, int start, int c1, int c2, int c3, int c4, int
      c5) {
    int index = start;
    int last = str.length - 4;
    while (index < last) {
      if (str.codeUnitAt(index) == c1 && str.codeUnitAt(index + 1) == c2 &&
          str.codeUnitAt(index + 2) == c3 && str.codeUnitAt(index + 3) == c4 &&
          str.codeUnitAt(index + 4) == c5) {
        return index;
      }
      index++;
    }
    return -1;
  }
  static String substringBeforeChar(String str, int c) {
    if (isEmpty(str)) {
      return str;
    }
    int pos = indexOf1(str, 0, c);
    if (pos < 0) {
      return str;
    }
    return str.substring(0, pos);
  }

  /**
   * Return the index of the first not letter/digit character in the [string]
   * that is at or after the [startIndex]. Return the length of the [string] if
   * all characters to the end are letters/digits.
   */
  static int indexOfFirstNotLetterDigit(String string, int startIndex) {
    int index = startIndex;
    int last = string.length;
    while (index < last) {
      int c = string.codeUnitAt(index);
      if (!Character.isLetterOrDigit(c)) {
        return index;
      }
      index++;
    }
    return last;
  }

  /**
   * Produce a string containing all of the names in the given array, surrounded by single quotes,
   * and separated by commas. The list must contain at least two elements.
   *
   * @param names the names to be printed
   * @return the result of printing the names
   */
  static String printListOfQuotedNames(List<String> names) {
    if (names == null) {
      throw new IllegalArgumentException("The list must not be null");
    }
    int count = names.length;
    if (count < 2) {
      throw new IllegalArgumentException("The list must contain at least two names");
    }
    StringBuffer buffer = new StringBuffer();
    buffer.write("'");
    buffer.write(names[0]);
    buffer.write("'");
    for (int i = 1; i < count - 1; i++) {
      buffer.write(", '");
      buffer.write(names[i]);
      buffer.write("'");
    }
    buffer.write(" and '");
    buffer.write(names[count - 1]);
    buffer.write("'");
    return buffer.toString();
  }
}

class FileNameUtilities {
  static String getExtension(String fileName) {
    if (fileName == null) {
      return "";
    }
    int index = fileName.lastIndexOf('.');
    if (index >= 0) {
      return fileName.substring(index + 1);
    }
    return "";
  }
}

class ArrayUtils {
  static List add(List target, Object value) {
    target = new List.from(target);
    target.add(value);
    return target;
  }
  static List addAt(List target, int index, Object value) {
    target = new List.from(target);
    target.insert(index, value);
    return target;
  }
  static List addAll(List target, List source) {
    List result = new List.from(target);
    result.addAll(source);
    return result;
  }
}

class ObjectUtilities {
  static int combineHashCodes(int first, int second) => first * 31 + second;
}

class UUID {
  static int __nextId = 0;
  final String id;
  UUID(this.id);
  String toString() => id;
  static UUID randomUUID() => new UUID((__nextId).toString());
}


/**
 * Instances of the class `AnalysisException` represent an exception that
 * occurred during the analysis of one or more sources.
 */
class AnalysisException implements Exception {
  /**
   * The message that explains why the exception occurred.
   */
  final String message;

  /**
   * The exception that caused this exception, or `null` if this exception was
   * not caused by another exception.
   */
  final CaughtException cause;

  /**
   * Initialize a newly created exception to have the given [message] and
   * [cause].
   */
  AnalysisException([this.message = 'Exception', this.cause = null]);

  String toString() {
    StringBuffer buffer = new StringBuffer();
    buffer.write("AnalysisException: ");
    buffer.writeln(message);
    if (cause != null) {
      buffer.write('Caused by ');
      cause._writeOn(buffer);
    }
    return buffer.toString();
  }
}


/**
 * Instances of the class `CaughtException` represent an exception that was
 * caught and has an associated stack trace.
 */
class CaughtException implements Exception {
  /**
   * The exception that was caught.
   */
  final Object exception;

  /**
   * The stack trace associated with the exception.
   */
  StackTrace stackTrace;

  /**
   * Initialize a newly created caught exception to have the given [exception]
   * and [stackTrace].
   */
  CaughtException(this.exception, stackTrace) {
    if (stackTrace == null) {
      try {
        throw this;
      } catch (_, st) {
        stackTrace = st;
      }
    }
    this.stackTrace = stackTrace;
  }

  @override
  String toString() {
    StringBuffer buffer = new StringBuffer();
    _writeOn(buffer);
    return buffer.toString();
  }

  /**
   * Write a textual representation of the caught exception and its associated
   * stack trace.
   */
  void _writeOn(StringBuffer buffer) {
    if (exception is AnalysisException) {
      AnalysisException analysisException = exception;
      buffer.writeln(analysisException.message);
      if (stackTrace != null) {
        buffer.writeln(stackTrace.toString());
      }
      CaughtException cause = analysisException.cause;
      if (cause != null) {
        buffer.write('Caused by ');
        cause._writeOn(buffer);
      }
    } else {
      buffer.writeln(exception.toString());
      buffer.writeln(stackTrace.toString());
    }
  }
}
