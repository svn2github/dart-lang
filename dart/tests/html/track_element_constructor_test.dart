// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// A regression test for dart2js generating illegal JavaScript code
// dynamically in non-csp mode.  The name of the field "defaultValue"
// in JavaScript is "default".  This meant that dart2js would create a
// constructor function that looked like this:
//
// function TrackElement(default) { this.default = default; }

import 'dart:html';

import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';

void main() {
  useHtmlConfiguration();
  test('', () {
    document.body.append(new TrackElement()..defaultValue = true);
    if (!document.query('track').defaultValue) {
      throw 'Expected default value to be true';
    }
    document.query('track').defaultValue = false;
    if (document.query('track').defaultValue) {
      throw 'Expected default value to be false';
    }
  });
}
