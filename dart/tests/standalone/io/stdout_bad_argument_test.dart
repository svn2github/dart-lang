// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:io";

main() {
  stdout.writeBytes("Hello\n");
  stdout.done.catchError((e) {
    exit(0);
  });
  stdin.listen(print);
}
