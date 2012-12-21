// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library validator_test;

import 'dart:io';
import 'dart:json';

import 'test_pub.dart';
import '../../../pkg/unittest/lib/unittest.dart';
import '../../../pkg/http/lib/http.dart' as http;
import '../../../pkg/http/lib/testing.dart';
import '../../pub/entrypoint.dart';
import '../../pub/io.dart';
import '../../pub/validator.dart';
import '../../pub/validator/dependency.dart';
import '../../pub/validator/lib.dart';
import '../../pub/validator/license.dart';
import '../../pub/validator/name.dart';
import '../../pub/validator/pubspec_field.dart';

void expectNoValidationError(ValidatorCreator fn) {
  expectLater(schedulePackageValidation(fn), pairOf(isEmpty, isEmpty));
}

void expectValidationError(ValidatorCreator fn) {
  expectLater(schedulePackageValidation(fn), pairOf(isNot(isEmpty), anything));
}

void expectValidationWarning(ValidatorCreator fn) {
  expectLater(schedulePackageValidation(fn), pairOf(isEmpty, isNot(isEmpty)));
}

Validator dependency(Entrypoint entrypoint) =>
  new DependencyValidator(entrypoint);

Validator lib(Entrypoint entrypoint) => new LibValidator(entrypoint);

Validator license(Entrypoint entrypoint) => new LicenseValidator(entrypoint);

Validator name(Entrypoint entrypoint) => new NameValidator(entrypoint);

Validator pubspecField(Entrypoint entrypoint) =>
  new PubspecFieldValidator(entrypoint);

void scheduleNormalPackage() => normalPackage.scheduleCreate();

main() {
  group('should consider a package valid if it', () {
    setUp(scheduleNormalPackage);

    test('looks normal', () {
      dir(appPath, [libPubspec("test_pkg", "1.0.0")]).scheduleCreate();
      expectNoValidationError(dependency);
      expectNoValidationError(lib);
      expectNoValidationError(license);
      expectNoValidationError(name);
      expectNoValidationError(pubspecField);
      run();
    });

    test('has a COPYING file', () {
      file(join(appPath, 'LICENSE'), '').scheduleDelete();
      file(join(appPath, 'COPYING'), '').scheduleCreate();
      expectNoValidationError(license);
      run();
    });

    test('has a prefixed LICENSE file', () {
      file(join(appPath, 'LICENSE'), '').scheduleDelete();
      file(join(appPath, 'MIT_LICENSE'), '').scheduleCreate();
      expectNoValidationError(license);
      run();
    });

    test('has a suffixed LICENSE file', () {
      file(join(appPath, 'LICENSE'), '').scheduleDelete();
      file(join(appPath, 'LICENSE.md'), '').scheduleCreate();
      expectNoValidationError(license);
      run();
    });

    test('has "authors" instead of "author"', () {
      var package = package("test_pkg", "1.0.0");
      package["authors"] = [package.remove("author")];
      dir(appPath, [pubspec(package)]).scheduleCreate();
      expectNoValidationError(pubspecField);
      run();
    });

    test('has a badly-named library in lib/src', () {
      dir(appPath, [
        libPubspec("test_pkg", "1.0.0"),
        dir("lib", [
          file("test_pkg.dart", "int i = 1;"),
          dir("src", [file("8ball.dart", "int j = 2;")])
        ])
      ]).scheduleCreate();
      expectNoValidationError(name);
      run();
    });

    test('has a non-Dart file in lib', () {
      dir(appPath, [
        libPubspec("test_pkg", "1.0.0"),
        dir("lib", [
          file("thing.txt", "woo hoo")
        ])
      ]).scheduleCreate();
      expectNoValidationError(lib);
      run();
    });

    test('has an unconstrained dependency on "unittest"', () {
      dir(appPath, [
        libPubspec("test_pkg", "1.0.0", [
          {'hosted': 'unittest'}
        ])
      ]).scheduleCreate();
      expectNoValidationError(dependency);
      run();
    });
  });

  group('should consider a package invalid if it', () {
    setUp(scheduleNormalPackage);

    test('is missing the "homepage" field', () {
      var package = package("test_pkg", "1.0.0");
      package.remove("homepage");
      dir(appPath, [pubspec(package)]).scheduleCreate();

      expectValidationError(pubspecField);
      run();
    });

    test('is missing the "description" field', () {
      var package = package("test_pkg", "1.0.0");
      package.remove("description");
      dir(appPath, [pubspec(package)]).scheduleCreate();

      expectValidationError(pubspecField);
      run();
    });

    test('is missing the "author" field', () {
      var package = package("test_pkg", "1.0.0");
      package.remove("author");
      dir(appPath, [pubspec(package)]).scheduleCreate();

      expectValidationError(pubspecField);
      run();
    });

    test('has a single author without an email', () {
      var package = package("test_pkg", "1.0.0");
      package["author"] = "Nathan Weizenbaum";
      dir(appPath, [pubspec(package)]).scheduleCreate();

      expectValidationWarning(pubspecField);
      run();
    });

    test('has one of several authors without an email', () {
      var package = package("test_pkg", "1.0.0");
      package.remove("author");
      package["authors"] = [
        "Bob Nystrom <rnystrom@google.com>",
        "Nathan Weizenbaum",
        "John Messerly <jmesserly@google.com>"
      ];
      dir(appPath, [pubspec(package)]).scheduleCreate();

      expectValidationWarning(pubspecField);
      run();
    });

    test('has a single author without a name', () {
      var package = package("test_pkg", "1.0.0");
      package["author"] = "<nweiz@google.com>";
      dir(appPath, [pubspec(package)]).scheduleCreate();

      expectValidationWarning(pubspecField);
      run();
    });

    test('has one of several authors without a name', () {
      var package = package("test_pkg", "1.0.0");
      package.remove("author");
      package["authors"] = [
        "Bob Nystrom <rnystrom@google.com>",
        "<nweiz@google.com>",
        "John Messerly <jmesserly@google.com>"
      ];
      dir(appPath, [pubspec(package)]).scheduleCreate();

      expectValidationWarning(pubspecField);
      run();
    });

    test('has no LICENSE file', () {
      file(join(appPath, 'LICENSE'), '').scheduleDelete();
      expectValidationError(license);
      run();
    });

    test('has an empty package name', () {
      dir(appPath, [libPubspec("", "1.0.0")]).scheduleCreate();
      expectValidationError(name);
      run();
    });

    test('has a package name with an invalid character', () {
      dir(appPath, [libPubspec("test-pkg", "1.0.0")]).scheduleCreate();
      expectValidationError(name);
      run();
    });

    test('has a package name that begins with a number', () {
      dir(appPath, [libPubspec("8ball", "1.0.0")]).scheduleCreate();
      expectValidationError(name);
      run();
    });

    test('has a package name that contains upper-case letters', () {
      dir(appPath, [libPubspec("TestPkg", "1.0.0")]).scheduleCreate();
      expectValidationWarning(name);
      run();
    });

    test('has a package name that is a Dart reserved word', () {
      dir(appPath, [libPubspec("operator", "1.0.0")]).scheduleCreate();
      expectValidationError(name);
      run();
    });

    test('has a library name with an invalid character', () {
      dir(appPath, [
        libPubspec("test_pkg", "1.0.0"),
        dir("lib", [file("test-pkg.dart", "int i = 0;")])
      ]).scheduleCreate();
      expectValidationError(name);
      run();
    });

    test('has a library name that begins with a number', () {
      dir(appPath, [
        libPubspec("test_pkg", "1.0.0"),
        dir("lib", [file("8ball.dart", "int i = 0;")])
      ]).scheduleCreate();
      expectValidationError(name);
      run();
    });

    test('has a library name that contains upper-case letters', () {
      dir(appPath, [
        libPubspec("test_pkg", "1.0.0"),
        dir("lib", [file("TestPkg.dart", "int i = 0;")])
      ]).scheduleCreate();
      expectValidationWarning(name);
      run();
    });

    test('has a library name that is a Dart reserved word', () {
      dir(appPath, [
        libPubspec("test_pkg", "1.0.0"),
        dir("lib", [file("operator.dart", "int i = 0;")])
      ]).scheduleCreate();
      expectValidationError(name);
      run();
    });

    test('has a single library named differently than the package', () {
      file(join(appPath, "lib", "test_pkg.dart"), '').scheduleDelete();
      dir(appPath, [
        dir("lib", [file("best_pkg.dart", "int i = 0;")])
      ]).scheduleCreate();
      expectValidationWarning(name);
      run();
    });

    test('has no lib directory', () {
      dir(join(appPath, "lib")).scheduleDelete();
      expectValidationError(lib);
      run();
    });

    test('has an empty lib directory', () {
      file(join(appPath, "lib", "test_pkg.dart"), '').scheduleDelete();
      expectValidationError(lib);
      run();
    });

    test('has a lib directory containing only src', () {
      file(join(appPath, "lib", "test_pkg.dart"), '').scheduleDelete();
      dir(appPath, [
        dir("lib", [
          dir("src", [file("test_pkg.dart", "int i = 0;")])
        ])
      ]).scheduleCreate();
      expectValidationError(lib);
      run();
    });

    group('has a dependency with a non-hosted source', () {
      group('where a hosted version of that dependency exists', () {
        test("and should suggest the hosted package's primary version", () {
          useMockClient(new MockClient((request) {
            expect(request.method, equals("GET"));
            expect(request.url.path, equals("/packages/foo.json"));

            return new Future.immediate(new http.Response(JSON.stringify({
              "name": "foo",
              "uploaders": ["nweiz@google.com"],
              "versions": ["3.0.0-pre", "2.0.0", "1.0.0"]
            }), 200));
          }));

          dir(appPath, [
            libPubspec("test_pkg", "1.0.0", [
              {'git': 'git://github.com/dart-lang/foo'}
            ])
          ]).scheduleCreate();

          expectLater(schedulePackageValidation(dependency),
              pairOf(isEmpty, someElement(contains(
                  '  foo: ">=2.0.0 <3.0.0"'))));

          run();
        });

        test("and should suggest the hosted package's prerelease version if "
            "it's the only version available", () {
          useMockClient(new MockClient((request) {
            expect(request.method, equals("GET"));
            expect(request.url.path, equals("/packages/foo.json"));

            return new Future.immediate(new http.Response(JSON.stringify({
              "name": "foo",
              "uploaders": ["nweiz@google.com"],
              "versions": ["3.0.0-pre", "2.0.0-pre"]
            }), 200));
          }));

          dir(appPath, [
            libPubspec("test_pkg", "1.0.0", [
              {'git': 'git://github.com/dart-lang/foo'}
            ])
          ]).scheduleCreate();

          expectLater(schedulePackageValidation(dependency),
              pairOf(isEmpty, someElement(contains(
                  '  foo: ">=3.0.0-pre <4.0.0"'))));

          run();
        });

        test("and should suggest a tighter constraint if the primary version "
            "is pre-1.0.0", () {
          useMockClient(new MockClient((request) {
            expect(request.method, equals("GET"));
            expect(request.url.path, equals("/packages/foo.json"));

            return new Future.immediate(new http.Response(JSON.stringify({
              "name": "foo",
              "uploaders": ["nweiz@google.com"],
              "versions": ["0.0.1", "0.0.2"]
            }), 200));
          }));

          dir(appPath, [
            libPubspec("test_pkg", "1.0.0", [
              {'git': 'git://github.com/dart-lang/foo'}
            ])
          ]).scheduleCreate();

          expectLater(schedulePackageValidation(dependency),
              pairOf(isEmpty, someElement(contains(
                  '  foo: ">=0.0.2 <0.0.3"'))));

          run();
        });
      });

      group('where no hosted version of that dependency exists', () {
        test("and should use the other source's version", () {
          useMockClient(new MockClient((request) {
            expect(request.method, equals("GET"));
            expect(request.url.path, equals("/packages/foo.json"));

            return new Future.immediate(new http.Response("not found", 404));
          }));

          dir(appPath, [
            libPubspec("test_pkg", "1.0.0", [
              {
                'git': {'url': 'git://github.com/dart-lang/foo'},
                'version': '>=1.0.0 <2.0.0'
              }
            ])
          ]).scheduleCreate();

          expectLater(schedulePackageValidation(dependency),
              pairOf(isEmpty, someElement(contains(
                  '  foo: ">=1.0.0 <2.0.0"'))));

          run();
        });

        test("and should use the other source's unquoted version if it's "
            "concrete", () {
          useMockClient(new MockClient((request) {
            expect(request.method, equals("GET"));
            expect(request.url.path, equals("/packages/foo.json"));

            return new Future.immediate(new http.Response("not found", 404));
          }));

          dir(appPath, [
            libPubspec("test_pkg", "1.0.0", [
              {
                'git': {'url': 'git://github.com/dart-lang/foo'},
                'version': '0.2.3'
              }
            ])
          ]).scheduleCreate();

          expectLater(schedulePackageValidation(dependency),
              pairOf(isEmpty, someElement(contains('  foo: 0.2.3'))));

          run();
        });
      });
    });

    group('has an unconstrained dependency', () {
      group('and it should not suggest a version', () {
        test("if there's no lockfile", () {
          dir(appPath, [
            libPubspec("test_pkg", "1.0.0", [
              {'hosted': 'foo'}
            ])
          ]).scheduleCreate();

          expectLater(schedulePackageValidation(dependency),
              pairOf(isEmpty, everyElement(isNot(contains("\n  foo:")))));

          run();
        });

        test("if the lockfile doesn't have an entry for the dependency", () {
          dir(appPath, [
            libPubspec("test_pkg", "1.0.0", [
              {'hosted': 'foo'}
            ]),
            file("pubspec.lock", JSON.stringify({
              'packages': {
                'bar': {
                  'version': '1.2.3',
                  'source': 'hosted',
                  'description': {
                    'name': 'bar',
                    'url': 'http://pub.dartlang.org'
                  }
                }
              }
            }))
          ]).scheduleCreate();

          expectLater(schedulePackageValidation(dependency),
              pairOf(isEmpty, everyElement(isNot(contains("\n  foo:")))));

          run();
        });
      });

      group('with a lockfile', () {
        test('and it should suggest a constraint based on the locked '
            'version', () {
          dir(appPath, [
            libPubspec("test_pkg", "1.0.0", [
              {'hosted': 'foo'}
            ]),
            file("pubspec.lock", JSON.stringify({
              'packages': {
                'foo': {
                  'version': '1.2.3',
                  'source': 'hosted',
                  'description': {
                    'name': 'foo',
                    'url': 'http://pub.dartlang.org'
                  }
                }
              }
            }))
          ]).scheduleCreate();

          expectLater(schedulePackageValidation(dependency),
              pairOf(isEmpty, someElement(contains(
                  '  foo: ">=1.2.3 <2.0.0"'))));

          run();
        });

        test('and it should suggest a concrete constraint if the locked '
            'version is pre-1.0.0', () {
          dir(appPath, [
            libPubspec("test_pkg", "1.0.0", [
              {'hosted': 'foo'}
            ]),
            file("pubspec.lock", JSON.stringify({
              'packages': {
                'foo': {
                  'version': '0.1.2',
                  'source': 'hosted',
                  'description': {
                    'name': 'foo',
                    'url': 'http://pub.dartlang.org'
                  }
                }
              }
            }))
          ]).scheduleCreate();

          expectLater(schedulePackageValidation(dependency),
              pairOf(isEmpty, someElement(contains(
                  '  foo: ">=0.1.2 <0.1.3"'))));

          run();
        });
      });
    });
  });
}
