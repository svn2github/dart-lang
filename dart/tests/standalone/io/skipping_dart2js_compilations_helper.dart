// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

main() {
  var outputFile = Platform.arguments[0];
  var file = new File(outputFile);
  file.createSync();
}
