// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Test the basic StreamController and StreamController.singleSubscription.
import 'dart:async';
import 'dart:isolate';
import '../../../pkg/unittest/lib/unittest.dart';
import 'event_helper.dart';

main() {
  test("single", () {
    StreamController c = new StreamController();
    Future f = c.single;
    f.then(expectAsync1((v) { Expect.equals(42, v);}));
    new Events.fromIterable([42]).replay(c);
  });

  test("single empty", () {
    StreamController c = new StreamController();
    Future f = c.single;
    f.catchError(expectAsync1((e) { Expect.isTrue(e.error is StateError); }));
    new Events.fromIterable([]).replay(c);
  });

  test("single error", () {
    StreamController c = new StreamController();
    Future f = c.single;
    f.catchError(expectAsync1((e) { Expect.equals("error", e.error); }));
    Events errorEvents = new Events()..error("error")..close();
    errorEvents.replay(c);
  });

  test("single error 2", () {
    StreamController c = new StreamController();
    Future f = c.single;
    f.catchError(expectAsync1((e) { Expect.equals("error", e.error); }));
    Events errorEvents = new Events()..error("error")..error("error2")..close();
    errorEvents.replay(c);
  });

  test("single error 3", () {
    StreamController c = new StreamController();
    Future f = c.single;
    f.catchError(expectAsync1((e) { Expect.equals("error", e.error); }));
    Events errorEvents = new Events()..add(499)..error("error")..close();
    errorEvents.replay(c);
  });
}
