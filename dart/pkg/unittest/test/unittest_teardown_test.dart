// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library unittestTest;
import 'dart:isolate';
import 'dart:async';
import 'package:unittest/unittest.dart';

part 'unittest_test_utils.dart';

var testName = 'teardown test';

var testFunction = (TestConfiguration testConfig) {
  group('a', () {
    tearDown(() { testConfig.teardown = 'teardown'; });
    test(testName, () {});
  });
};

var expected = buildStatusString(1, 0, 0, 'a $testName',
    count: 0, setup: '', teardown: 'teardown');
