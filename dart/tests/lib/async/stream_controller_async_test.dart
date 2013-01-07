// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Test the basic StreamController and StreamController.singleSubscription.
import 'dart:async';
import 'dart:isolate';
import '../../../pkg/unittest/lib/unittest.dart';
import 'event_helper.dart';

testController() {
  // Test reduce
  test("StreamController.reduce", () {
    StreamController c = new StreamController();
    c.reduce(0, (a,b) => a + b)
    .then(expectAsync1((int v) {
        Expect.equals(42, v);
    }));
    c.add(10);
    c.add(32);
    c.close();
  });

  test("StreamController.reduce throws", () {
    StreamController c = new StreamController();
    c.reduce(0, (a,b) { throw "Fnyf!"; })
            .catchError(expectAsync1((e) {
              Expect.equals("Fnyf!", e.error);
            }));
    c.add(42);
  });

  test("StreamController.pipeInto", () {
    StreamController c = new StreamController();
    var list = <int>[];
    c.pipeInto(new CollectionSink<int>(list))
     .then(expectAsync0(() { Expect.listEquals(<int>[1,2,9,3,9], list); }));
    c.add(1);
    c.add(2);
    c.add(9);
    c.add(3);
    c.add(9);
    c.close();
  });
}

testSingleController() {
  test("Single-subscription StreamController.reduce", () {
    StreamController c = new StreamController.singleSubscription();
    c.reduce(0, (a,b) => a + b)
    .then(expectAsync1((int v) { Expect.equals(42, v); }));
    c.add(10);
    c.add(32);
    c.close();
  });

  test("Single-subscription StreamController.reduce throws", () {
    StreamController c = new StreamController.singleSubscription();
    c.reduce(0, (a,b) { throw "Fnyf!"; })
            .catchError(expectAsync1((e) { Expect.equals("Fnyf!", e.error); }));
    c.add(42);
  });

  test("Single-subscription StreamController.pipeInto", () {
    StreamController c = new StreamController.singleSubscription();
    var list = <int>[];
    c.pipeInto(new CollectionSink<int>(list))
     .then(expectAsync0(() { Expect.listEquals(<int>[1,2,9,3,9], list); }));
    c.add(1);
    c.add(2);
    c.add(9);
    c.add(3);
    c.add(9);
    c.close();
  });

  test("Single-subscription StreamController subscription changes", () {
    StreamController c = new StreamController.singleSubscription();
    StreamSink sink = c.sink;
    Stream stream = c.stream;
    int counter = 0;
    var subscription;
    subscription = stream.listen((data) {
      counter += data;
      Expect.throws(() => stream.listen(null), (e) => e is StateError);
      subscription.cancel();
      stream.listen((data) {
        counter += data * 10;
      },
      onDone: expectAsync0(() {
        Expect.equals(1 + 20, counter);
      }));
    });
    sink.add(1);
    sink.add(2);
    sink.close();
  });

  test("Single-subscription StreamController events are buffered when"
       " there is no subscriber",
       () {
    StreamController c = new StreamController.singleSubscription();
    StreamSink sink = c.sink;
    Stream stream = c.stream;
    int counter = 0;
    sink.add(1);
    sink.add(2);
    sink.close();
    stream.listen(
      (data) {
        counter += data;
      },
      onDone: expectAsync0(() {
        Expect.equals(3, counter);
      }));
  });

  // Test subscription changes while firing.
  test("Single-subscription StreamController subscription changes while firing",
       () {
    StreamController c = new StreamController.singleSubscription();
    StreamSink sink = c.sink;
    Stream stream = c.stream;
    int counter = 0;
    var subscription = stream.listen(null);
    subscription.onData(expectAsync1((data) {
      counter += data;
      subscription.cancel();
      stream.listen((data) {
        counter += 10 * data;
      },
      onDone: expectAsync0(() {
        Expect.equals(1 + 20 + 30 + 40 + 50, counter);
      }));
      Expect.throws(() => stream.listen(null), (e) => e is StateError);
    }));
    sink.add(1); // seen by stream 1
    sink.add(2); // seen by stream 10 and 100
    sink.add(3); // -"-
    sink.add(4); // -"-
    sink.add(5); // seen by stream 10
    sink.close();
  });
}

testExtraMethods() {
  Events sentEvents = new Events()..add(7)..add(9)..add(13)..add(87)..close();

  test("firstMatching", () {
    StreamController c = new StreamController();
    Future f = c.firstMatching((x) => (x % 3) == 0);
    f.then(expectAsync1((v) { Expect.equals(9, v); }));
    sentEvents.replay(c);
  });

  test("firstMatching 2", () {
    StreamController c = new StreamController();
    Future f = c.firstMatching((x) => (x % 4) == 0);
    f.catchError(expectAsync1((e) {}));
    sentEvents.replay(c);
  });

  test("firstMatching 3", () {
    StreamController c = new StreamController();
    Future f = c.firstMatching((x) => (x % 4) == 0, defaultValue: () => 999);
    f.then(expectAsync1((v) { Expect.equals(999, v); }));
    sentEvents.replay(c);
  });


  test("lastMatching", () {
    StreamController c = new StreamController();
    Future f = c.lastMatching((x) => (x % 3) == 0);
    f.then(expectAsync1((v) { Expect.equals(87, v); }));
    sentEvents.replay(c);
  });

  test("lastMatching 2", () {
    StreamController c = new StreamController();
    Future f = c.lastMatching((x) => (x % 4) == 0);
    f.catchError(expectAsync1((e) {}));
    sentEvents.replay(c);
  });

  test("lastMatching 3", () {
    StreamController c = new StreamController();
    Future f = c.lastMatching((x) => (x % 4) == 0, defaultValue: () => 999);
    f.then(expectAsync1((v) { Expect.equals(999, v); }));
    sentEvents.replay(c);
  });

  test("singleMatching", () {
    StreamController c = new StreamController();
    Future f = c.singleMatching((x) => (x % 9) == 0);
    f.then(expectAsync1((v) { Expect.equals(9, v); }));
    sentEvents.replay(c);
  });

  test("singleMatching 2", () {
    StreamController c = new StreamController();
    Future f = c.singleMatching((x) => (x % 3) == 0);  // Matches both 9 and 87..
    f.catchError(expectAsync1((e) { Expect.isTrue(e.error is StateError); }));
    sentEvents.replay(c);
  });

  test("first", () {
    StreamController c = new StreamController();
    Future f = c.first;
    f.then(expectAsync1((v) { Expect.equals(7, v);}));
    sentEvents.replay(c);
  });

  test("first empty", () {
    StreamController c = new StreamController();
    Future f = c.first;
    f.catchError(expectAsync1((e) { Expect.isTrue(e.error is StateError); }));
    Events emptyEvents = new Events()..close();
    emptyEvents.replay(c);
  });

  test("first error", () {
    StreamController c = new StreamController();
    Future f = c.first;
    f.catchError(expectAsync1((e) { Expect.equals("error", e.error); }));
    Events errorEvents = new Events()..error("error")..close();
    errorEvents.replay(c);
  });

  test("first error 2", () {
    StreamController c = new StreamController();
    Future f = c.first;
    f.catchError(expectAsync1((e) { Expect.equals("error", e.error); }));
    Events errorEvents = new Events()..error("error")..error("error2")..close();
    errorEvents.replay(c);
  });

  test("last", () {
    StreamController c = new StreamController();
    Future f = c.last;
    f.then(expectAsync1((v) { Expect.equals(87, v);}));
    sentEvents.replay(c);
  });

  test("last empty", () {
    StreamController c = new StreamController();
    Future f = c.last;
    f.catchError(expectAsync1((e) { Expect.isTrue(e.error is StateError); }));
    Events emptyEvents = new Events()..close();
    emptyEvents.replay(c);
  });

  test("last error", () {
    StreamController c = new StreamController();
    Future f = c.last;
    f.catchError(expectAsync1((e) { Expect.equals("error", e.error); }));
    Events errorEvents = new Events()..error("error")..close();
    errorEvents.replay(c);
  });

  test("last error 2", () {
    StreamController c = new StreamController();
    Future f = c.last;
    f.catchError(expectAsync1((e) { Expect.equals("error", e.error); }));
    Events errorEvents = new Events()..error("error")..error("error2")..close();
    errorEvents.replay(c);
  });

  test("elementAt", () {
    StreamController c = new StreamController();
    Future f = c.elementAt(2);
    f.then(expectAsync1((v) { Expect.equals(13, v);}));
    sentEvents.replay(c);
  });

  test("elementAt 2", () {
    StreamController c = new StreamController();
    Future f = c.elementAt(20);
    f.catchError(expectAsync1((e) { Expect.isTrue(e.error is StateError); }));
    sentEvents.replay(c);
  });
}

testPause() {
  test("pause event-unpause", () {
    StreamController c = new StreamController();
    Events actualEvents = new Events.capture(c);
    Events expectedEvents = new Events();
    expectedEvents.add(42);
    c.add(42);
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    SignalCompleter completer = new SignalCompleter();
    actualEvents.pause(completer.signal);
    c..add(43)..add(44)..close();
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    completer.complete();
    expectedEvents..add(43)..add(44)..close();
    actualEvents.onDone(expectAsync0(() {
      Expect.listEquals(expectedEvents.events, actualEvents.events);
    }));
  });

  test("pause twice event-unpause", () {
    StreamController c = new StreamController();
    Events actualEvents = new Events.capture(c);
    Events expectedEvents = new Events();
    expectedEvents.add(42);
    c.add(42);
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    SignalCompleter completer = new SignalCompleter();
    SignalCompleter completer2 = new SignalCompleter();
    actualEvents.pause(completer.signal);
    actualEvents.pause(completer2.signal);
    c..add(43)..add(44)..close();
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    completer.complete();
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    completer2.complete();
    expectedEvents..add(43)..add(44)..close();
    actualEvents.onDone(expectAsync0((){
      Expect.listEquals(expectedEvents.events, actualEvents.events);
    }));
  });

  test("pause twice direct-unpause", () {
    StreamController c = new StreamController();
    Events actualEvents = new Events.capture(c);
    Events expectedEvents = new Events();
    expectedEvents.add(42);
    c.add(42);
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    actualEvents.pause();
    actualEvents.pause();
    c.add(43);
    c.add(44);
    c.close();
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    actualEvents.resume();
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    expectedEvents..add(43)..add(44)..close();
    actualEvents.onDone(expectAsync0(() {
      Expect.listEquals(expectedEvents.events, actualEvents.events);
    }));
    actualEvents.resume();
  });

  test("pause twice direct-event-unpause", () {
    StreamController c = new StreamController();
    Events actualEvents = new Events.capture(c);
    Events expectedEvents = new Events();
    expectedEvents.add(42);
    c.add(42);
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    SignalCompleter completer = new SignalCompleter();
    actualEvents.pause(completer.signal);
    actualEvents.pause();
    c.add(43);
    c.add(44);
    c.close();
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    actualEvents.resume();
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    expectedEvents..add(43)..add(44)..close();
    actualEvents.onDone(expectAsync0(() {
      Expect.listEquals(expectedEvents.events, actualEvents.events);
    }));
    completer.complete();
  });

  test("pause twice direct-unpause", () {
    StreamController c = new StreamController();
    Events actualEvents = new Events.capture(c);
    Events expectedEvents = new Events();
    expectedEvents.add(42);
    c.add(42);
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    SignalCompleter completer = new SignalCompleter();
    actualEvents.pause(completer.signal);
    actualEvents.pause();
    c.add(43);
    c.add(44);
    c.close();
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    completer.complete();
    Expect.listEquals(expectedEvents.events, actualEvents.events);
    expectedEvents..add(43)..add(44)..close();
    actualEvents.onDone(expectAsync0(() {
      Expect.listEquals(expectedEvents.events, actualEvents.events);
    }));
    actualEvents.resume();
  });
}

main() {
  testController();
  testSingleController();
  testExtraMethods();
  testPause();
}
