// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// And end-to-end test that generates code and checks that the output matches
/// the code in `static_test.dart`. Techincally we could run the result in an
/// isolate, but instead we decided to split that up in two tests. This test
/// ensures that we generate the code as it was written in static_test, and
/// separately static_test ensures that the smoke.static library behaves as
/// expected.
library smoke.test.codegen.end_to_end_test;

import 'dart:io';

import 'package:analyzer/src/generated/element.dart';
import 'package:smoke/codegen/generator.dart';
import 'package:smoke/codegen/recorder.dart';
import 'package:unittest/unittest.dart';
import 'package:path/path.dart' as path;

import 'testing_resolver_utils.dart' show initAnalyzer;

main(args) {
  final updateStaticTest = args.length > 0 && args[0] == '--update_static_test';

  test('static_test is up to date', () {
    var scriptPath = Platform.script.path;
    var testDir = path.dirname(path.dirname(scriptPath));
    var commonPath = path.join(testDir, 'common.dart');
    var testCode = new File('$commonPath').readAsStringSync();
    var lib = initAnalyzer({'common.dart' : testCode})
        .libraryFor('common.dart');
    var coreLib = lib.visibleLibraries.firstWhere(
        (l) => l.displayName == 'dart.core');
    var generator = new SmokeCodeGenerator();
    var recorder = new Recorder(generator, resolveImportUrl);

    // Record all getters and setters we use in the tests.
    generator.addGetter("i");
    generator.addGetter("j");
    generator.addGetter("j2");
    generator.addGetter("inc0");
    generator.addGetter("inc1");
    generator.addGetter("inc2");
    generator.addSetter("i");
    generator.addSetter("j2");

    // Record symbol convertions.
    generator.addSymbol('i');

    /// Record all parent-class relations that we explicitly request for 
    recorder.lookupParent(lib.getType('AnnotB'));
    recorder.lookupParent(lib.getType('A'));
    recorder.lookupParent(lib.getType('B'));
    recorder.lookupParent(lib.getType('D'));
    recorder.lookupParent(lib.getType('H'));

    // Record members for which we implicitly request their declaration in
    // has-getter and has-setter tests.
    recorder.lookupMember(lib.getType('A'), "i", recursive: true);
    recorder.lookupMember(lib.getType('A'), "j2", recursive: true);
    recorder.lookupMember(lib.getType('A'), "inc2", recursive: true);
    recorder.lookupMember(lib.getType('B'), "a", recursive: true);
    recorder.lookupMember(lib.getType('B'), "f", recursive: true);
    recorder.lookupMember(lib.getType('D'), "i", recursive: true);
    recorder.lookupMember(lib.getType('E'), "y", recursive: true);

    // Record also lookups for non-exisiting members.
    recorder.lookupMember(lib.getType('B'), "i", recursive: true);
    recorder.lookupMember(lib.getType('E'), "x", recursive: true);
    recorder.lookupMember(lib.getType('E'), "z", recursive: true);

    // Record members for which we explicitly request their declaration.
    recorder.lookupMember(lib.getType('B'), "a");
    recorder.lookupMember(lib.getType('B'), "w");
    recorder.lookupMember(lib.getType('A'), "inc1");
    recorder.lookupMember(lib.getType('F'), "staticMethod");
    recorder.lookupMember(lib.getType('G'), "b");
    recorder.lookupMember(lib.getType('G'), "d");

    // Lookups from no-such-method test.
    recorder.lookupMember(lib.getType('A'), "noSuchMethod", recursive: true);
    recorder.lookupMember(lib.getType('E'), "noSuchMethod", recursive: true);
    recorder.lookupMember(lib.getType('E2'), "noSuchMethod", recursive: true);

    // Lookups from has-instance-method and has-static-method tests.
    recorder.lookupMember(lib.getType('A'), "inc0", recursive: true);
    recorder.lookupMember(lib.getType('A'), "inc3", recursive: true);
    recorder.lookupMember(lib.getType('C'), "inc", recursive: true);
    recorder.lookupMember(lib.getType('D'), "inc", recursive: true);
    recorder.lookupMember(lib.getType('D'), "inc0", recursive: true);
    recorder.lookupMember(lib.getType('F'), "staticMethod", recursive: true);
    recorder.lookupMember(lib.getType('F2'), "staticMethod", recursive: true);

    // Record all queries done by the test.
    recorder.runQuery(lib.getType('A'), new QueryOptions());
    recorder.runQuery(lib.getType('D'),
        new QueryOptions(includeInherited: true));

    var vars = lib.definingCompilationUnit.topLevelVariables;
    expect(vars[0].name, 'a1');
    expect(vars[1].name, 'a2');
    var options = new QueryOptions(includeInherited: true,
        withAnnotations: [vars[0], vars[1], lib.getType('Annot')]);
    recorder.runQuery(lib.getType('H'), options);

    var code = _createEntrypoint(generator);
    var staticTestFile = new File(path.join(testDir, 'static_test.dart'));
    var existingCode = staticTestFile.readAsStringSync();
    if (!updateStaticTest) {
      expect(code, existingCode);
    } else if (code == existingCode) {
      print('static_test.dart is already up to date');
    } else {
      staticTestFile.writeAsStringSync(code);
      print('static_test.dart has been updated.');
    }
  });
}

_createEntrypoint(SmokeCodeGenerator generator) {
  var sb = new StringBuffer()
      ..writeln('/// ---- AUTOGENERATED: DO NOT EDIT THIS FILE --------------')
      ..writeln('/// To update this test file, call:')
      ..writeln('/// > dart codegen/end_to_end_test.dart --update_static_test')
      ..writeln('/// --------------------------------------------------------');
  sb.write('\nlibrary smoke.test.static_test;\n\n');
  sb.writeln("import 'package:unittest/unittest.dart';");
  generator.writeImports(sb);
  sb.writeln("import 'common.dart' as common show main;\n");
  generator.writeTopLevelDeclarations(sb);
  sb.writeln('\n_configure() {');
  generator.writeInitCall(sb);
  sb.writeln('}\n');
  sb.writeln('main() {');
  sb.writeln('  setUp(_configure);');
  sb.writeln('  common.main();');
  sb.writeln('}');
  return sb.toString();
}


resolveImportUrl(LibraryElement lib) {
  if (lib.isDartCore) return 'dart:core';
  if (lib.displayName == 'smoke.test.common') return 'common.dart';
  return 'unknown.dart';
}
