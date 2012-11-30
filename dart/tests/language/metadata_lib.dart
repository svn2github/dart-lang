// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library metadata.dart;

class Alien {
  final String qwrrkz;
  const Alien(this.qwrrkz);
  const Alien.unknown() : qwrrkz = "???";
}

const Klingon = const Alien("Klingon");
