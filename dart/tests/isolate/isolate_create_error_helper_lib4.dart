// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library isolate.create.error_helper4_lib;

// This library has a main that is not a function,
// but does have a function type.

final main = () { print("Not a function declaration!"); };
