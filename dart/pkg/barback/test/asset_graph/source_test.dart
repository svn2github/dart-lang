// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library barback.test.asset_graph.source_test;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:barback/src/asset_graph.dart';
import 'package:scheduled_test/scheduled_test.dart';

import '../utils.dart';

main() {
  initConfig();
  test("gets a source asset", () {
    initGraph(["app|foo.txt"]);
    updateSources(["app|foo.txt"]);
    expectAsset("app|foo.txt");
  });

  test("doesn't get an unknown source", () {
    initGraph();
    expectNoAsset("app|unknown.txt");
  });

  test("doesn't get an unprovided source", () {
    initGraph();
    updateSources(["app|unknown.txt"]);
    expectNoAsset("app|unknown.txt");
  });

  test("doesn't get an asset that isn't an updated source", () {
    initGraph(["app|foo.txt"]);

    // Sources must be explicitly made visible to barback by calling
    // updateSources() on them. It isn't enough for the provider to be able
    // to provide it.
    //
    // This lets you distinguish between sources that you want to be primaries
    // and the larger set of inputs that those primaries are allowed to pull in.
    expectNoAsset("app|foo.txt");
  });

  test("gets a source asset if not transformed", () {
    initGraph(["app|foo.txt"], {"app": [
      [new RewriteTransformer("nottxt", "whatever")]
    ]});

    updateSources(["app|foo.txt"]);
    expectAsset("app|foo.txt");
  });

  test("doesn't get a removed source", () {
    initGraph(["app|foo.txt"]);

    updateSources(["app|foo.txt"]);
    expectAsset("app|foo.txt");

    schedule(() {
      removeSources(["app|foo.txt"]);
    });

    expectNoAsset("app|foo.txt");
  });

  test("collapses redundant updates", () {
    var transformer = new RewriteTransformer("blub", "blab");
    initGraph(["app|foo.blub"], {"app": [[transformer]]});

    schedule(() {
      // Make a bunch of synchronous update calls.
      updateSources(["app|foo.blub"]);
      updateSources(["app|foo.blub"]);
      updateSources(["app|foo.blub"]);
      updateSources(["app|foo.blub"]);
    });

    expectAsset("app|foo.blab", "foo.blab");

    schedule(() {
      expect(transformer.numRuns, equals(1));
    });
  });

  test("a removal cancels out an update", () {
    initGraph(["app|foo.txt"]);

    schedule(() {
      updateSources(["app|foo.txt"]);
      removeSources(["app|foo.txt"]);
    });

    expectNoAsset("app|foo.txt");
  });

  test("an update cancels out a removal", () {
    initGraph(["app|foo.txt"]);

    schedule(() {
      removeSources(["app|foo.txt"]);
      updateSources(["app|foo.txt"]);
    });

    expectAsset("app|foo.txt");
  });

  test("restarts a build if a source is updated while sources are loading", () {
    var transformer = new RewriteTransformer("txt", "out");
    initGraph(["app|foo.txt", "app|other.bar"], {"app": [[transformer]]});

    // Run the whole graph so all nodes are clean.
    updateSources(["app|foo.txt", "app|other.bar"]);
    expectAsset("app|foo.out", "foo.out");
    expectAsset("app|other.bar");

    buildShouldSucceed();

    // Make the provider slow to load a source.
    pauseProvider();

    schedule(() {
      // Update an asset that doesn't trigger any transformers.
      updateSources(["app|other.bar"]);
    });

    schedule(() {
      // Now update an asset that does trigger a transformer.
      updateSources(["app|foo.txt"]);
    });

    resumeProvider();

    buildShouldSucceed();
    waitForBuild();

    schedule(() {
      expect(transformer.numRuns, equals(2));
    });
  });
}
