// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Dart core library.

patch class bool {

  int get _identityHashCode {
    return this ? 1231 : 1237;
  }
}
