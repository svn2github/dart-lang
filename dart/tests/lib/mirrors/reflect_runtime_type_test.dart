// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// A simple test that ensure that reflection works on runtime types of
// instantiated classes.

import "dart:mirrors";

class Foo {
  int a;
}

main() {
  var m = reflectClass(new Foo().runtimeType);
  var field = publicFields(m).single;
  if (MirrorSystem.getName(field.simpleName) != 'a') {
    throw 'Expected "a", but got "${MirrorSystem.getName(field.simpleName)}"';
  }
  print(field);
}

Iterable<VariableMirror> publicFields(ClassMirror mirror) =>
    mirror.variables.values.where((x) => !(x.isPrivate || x.isStatic));
