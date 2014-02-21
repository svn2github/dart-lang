// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Test that the helper [Compiler.inUserCode] works as intended.

import 'package:async_helper/async_helper.dart';
import 'package:expect/expect.dart';

import 'memory_compiler.dart';

const SOURCE = const {
  'main.dart': """
library main;

import 'dart:async';
import 'foo.dart';
import 'pkg/sub/bar.dart';
import 'package:sub/bar.dart';
import 'package:sup/boz.dart';

main() {}
""",

  'foo.dart': """
library foo;
""",

  'pkg/sub/bar.dart': """
library sub.bar;

import 'package:sup/boz.dart';
import 'baz.dart';
""",

  'pkg/sub/baz.dart': """
library sub.baz;
""",

  'pkg/sup/boz.dart': """
library sup.boz;
""",
};

void test(List<Uri> entryPoints, Map<String, bool> expectedResults) {
  var compiler = compilerFor(SOURCE,
                             options: ['--analyze-only', '--analyze-all'],
                             packageRoot: Uri.parse('memory:pkg/'));
  Uri mainUri = null;
  if (entryPoints.length == 1) {
    mainUri = entryPoints[0];
  } else {
    compiler.librariesToAnalyzeWhenRun = entryPoints;
  }
  asyncTest(() => compiler.run(mainUri).then((_) {
    expectedResults.forEach((String uri, bool expectedResult) {
      var element = compiler.libraries[uri];
      Expect.isNotNull(element, "Unknown library '$uri'.");
      Expect.equals(expectedResult, compiler.inUserCode(element),
          expectedResult ? "Library '$uri' expected to be in user code"
                         : "Library '$uri' not expected to be in user code");
    });
  }));
}

void main() {
  test([Uri.parse('memory:main.dart')],
       {'memory:main.dart': true,
        'memory:foo.dart': true,
        'memory:pkg/sub/bar.dart': true,
        'memory:pkg/sub/baz.dart': true,
        'package:sub/bar.dart': false,
        'package:sub/baz.dart': false,
        'package:sup/boz.dart': false,
        'dart:core': false,
        'dart:async': false});
  test([Uri.parse('dart:async')],
       {'dart:core': true,
        'dart:async': true});
  test([Uri.parse('package:sub/bar.dart')],
       {'package:sub/bar.dart': true,
        'package:sub/baz.dart': true,
        'package:sup/boz.dart': false,
        'dart:core': false});
  test([Uri.parse('package:sub/bar.dart'), Uri.parse('package:sup/boz.dart')],
       {'package:sub/bar.dart': true,
        'package:sub/baz.dart': true,
        'package:sup/boz.dart': true,
        'dart:core': false});
  test([Uri.parse('dart:async'), Uri.parse('package:sub/bar.dart')],
       {'package:sub/bar.dart': true,
        'package:sub/baz.dart': true,
        'package:sup/boz.dart': false,
        'dart:core': true,
        'dart:async': true});
}

