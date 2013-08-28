// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * Code transform for @observable. The core transformation is relatively
 * straightforward, and essentially like an editor refactoring.
 */
library observe.transform;

import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:analyzer_experimental/src/generated/ast.dart';
import 'package:analyzer_experimental/src/generated/error.dart';
import 'package:analyzer_experimental/src/generated/parser.dart';
import 'package:analyzer_experimental/src/generated/scanner.dart';
import 'package:barback/barback.dart';
import 'package:source_maps/refactor.dart';
import 'package:source_maps/span.dart' show SourceFile;

/**
 * A [Transformer] that replaces observables based on dirty-checking with an
 * implementation based on change notifications.
 *
 * The transformation adds hooks for field setters and notifies the observation
 * system of the change.
 */
class ObservableTransformer extends Transformer {

  Future<bool> isPrimary(Asset input) {
    if (input.id.extension != '.dart') return new Future.value(false);
    // Note: technically we should parse the file to find accurately the
    // observable annotation, but that seems expensive. It would require almost
    // as much work as applying the transform. We rather have some false
    // positives here, and then generate no outputs when we apply this
    // transform.
    return input.readAsString().then((c) => c.contains("@observable"));
  }

  Future apply(Transform transform) {
    return transform.primaryInput.readAsString().then((content) {
      var id = transform.primaryInput.id;
      // TODO(sigmund): improve how we compute this url
      var url = id.path.startsWith('lib/')
            ? 'package:${id.package}/${id.path.substring(4)}' : id.path;
      var sourceFile = new SourceFile.text(url, content);
      var transaction = _transformCompilationUnit(
          content, sourceFile, transform.logger);
      if (!transaction.hasEdits) {
        transform.addOutput(input);
        return;
      }
      var printer = transaction.commit();
      // TODO(sigmund): emit source maps when barback supports it (see
      // dartbug.com/12340)
      printer.build(url);
      transform.addOutput(new Asset.fromString(id, printer.text));
    });
  }
}

TextEditTransaction _transformCompilationUnit(
    String inputCode, SourceFile sourceFile, TransformLogger logger) {
  var unit = _parseCompilationUnit(inputCode);
  return transformObservables(unit, sourceFile, inputCode, logger);
}

// TODO(sigmund): make this private. This is currently public so it can be used
// by the polymer.dart package which is not yet entirely migrated to use
// pub-serve and pub-deploy.
TextEditTransaction transformObservables(CompilationUnit unit,
    SourceFile sourceFile, String content, TransformLogger logger) {
  var code = new TextEditTransaction(content, sourceFile);
  for (var directive in unit.directives) {
    if (directive is LibraryDirective && _hasObservable(directive)) {
      logger.warning('@observable on a library no longer has any effect. '
          'It should be placed on individual fields.',
          _getSpan(sourceFile, directive));
      break;
    }
  }

  for (var declaration in unit.declarations) {
    if (declaration is ClassDeclaration) {
      _transformClass(declaration, code, sourceFile, logger);
    } else if (declaration is TopLevelVariableDeclaration) {
      if (_hasObservable(declaration)) {
        logger.warning('Top-level fields can no longer be observable. '
            'Observable fields should be put in an observable objects.',
            _getSpan(sourceFile, declaration));
      }
    }
  }
  return code;
}

/** Parse [code] using analyzer_experimental. */
CompilationUnit _parseCompilationUnit(String code) {
  var errorListener = new _ErrorCollector();
  var scanner = new StringScanner(null, code, errorListener);
  var token = scanner.tokenize();
  var parser = new Parser(null, errorListener);
  return parser.parseCompilationUnit(token);
}

class _ErrorCollector extends AnalysisErrorListener {
  final errors = <AnalysisError>[];
  onError(error) => errors.add(error);
}

_getSpan(SourceFile file, ASTNode node) => file.span(node.offset, node.end);

/** True if the node has the `@observable` annotation. */
bool _hasObservable(AnnotatedNode node) => _hasAnnotation(node, 'observable');

bool _hasAnnotation(AnnotatedNode node, String name) {
  // TODO(jmesserly): this isn't correct if the annotation has been imported
  // with a prefix, or cases like that. We should technically be resolving, but
  // that is expensive.
  return node.metadata.any((m) => m.name.name == name &&
      m.constructorName == null && m.arguments == null);
}

void _transformClass(ClassDeclaration cls, TextEditTransaction code,
    SourceFile file, TransformLogger logger) {

  if (_hasObservable(cls)) {
    logger.warning('@observable on a class no longer has any effect. '
        'It should be placed on individual fields.',
        _getSpan(file, cls));
  }

  // We'd like to track whether observable was declared explicitly, otherwise
  // report a warning later below. Because we don't have type analysis (only
  // syntactic understanding of the code), we only report warnings that are
  // known to be true.
  var declaresObservable = false;
  if (cls.extendsClause != null) {
    var id = _getSimpleIdentifier(cls.extendsClause.superclass.name);
    if (id.name == 'ObservableBase') {
      code.edit(id.offset, id.end, 'ChangeNotifierBase');
      declaresObservable = true;
    } else if (id.name == 'ChangeNotifierBase') {
      declaresObservable = true;
    } else if (id.name != 'PolymerElement' && id.name != 'CustomElement'
        && id.name != 'Object') {
      // TODO(sigmund): this is conservative, consider using type-resolution to
      // improve this check.
      declaresObservable = true;
    }
  }

  if (cls.withClause != null) {
    for (var type in cls.withClause.mixinTypes) {
      var id = _getSimpleIdentifier(type.name);
      if (id.name == 'ObservableMixin') {
        code.edit(id.offset, id.end, 'ChangeNotifierMixin');
        declaresObservable = true;
        break;
      } else if (id.name == 'ChangeNotifierMixin') {
        declaresObservable = true;
        break;
      } else {
        // TODO(sigmund): this is conservative, consider using type-resolution
        // to improve this check.
        declaresObservable = true;
      }
    }
  }

  if (!declaresObservable && cls.implementsClause != null) {
    // TODO(sigmund): consider adding type-resolution to give a more precise
    // answer.
    declaresObservable = true;
  }

  // Track fields that were transformed.
  var instanceFields = new Set<String>();
  var getters = new List<String>();
  var setters = new List<String>();

  for (var member in cls.members) {
    if (member is FieldDeclaration) {
      bool isStatic = _hasKeyword(member.keyword, Keyword.STATIC);
      if (isStatic) {
        if (_hasObservable(member)){
          logger.warning('Static fields can no longer be observable. '
              'Observable fields should be put in an observable objects.',
              _getSpan(file, member));
        }
        continue;
      }
      if (_hasObservable(member)) {
        if (!declaresObservable) {
          logger.warning('Observable fields should be put in an observable'
              ' objects. Please declare that this class extends from '
              'ObservableBase, includes ObservableMixin, or implements '
              'Observable.',
              _getSpan(file, member));

        }
        _transformFields(member.fields, code, member.offset, member.end);

        var names = member.fields.variables.map((v) => v.name.name);

        getters.addAll(names);
        if (!_isReadOnly(member.fields)) {
          setters.addAll(names);
          instanceFields.addAll(names);
        }
      }
    }
    // TODO(jmesserly): this is a temporary workaround until we can remove
    // getValueWorkaround and setValueWorkaround.
    if (member is MethodDeclaration) {
      if (_hasKeyword(member.propertyKeyword, Keyword.GET)) {
        getters.add(member.name.name);
      } else if (_hasKeyword(member.propertyKeyword, Keyword.SET)) {
        setters.add(member.name.name);
      }
    }
  }

  // If nothing was @observable, bail.
  if (instanceFields.length == 0) return;

  // Fix initializers, because they aren't allowed to call the setter.
  for (var member in cls.members) {
    if (member is ConstructorDeclaration) {
      _fixConstructor(member, code, instanceFields);
    }
  }
}

SimpleIdentifier _getSimpleIdentifier(Identifier id) =>
    id is PrefixedIdentifier ? (id as PrefixedIdentifier).identifier : id;


bool _hasKeyword(Token token, Keyword keyword) =>
    token is KeywordToken && (token as KeywordToken).keyword == keyword;

String _getOriginalCode(TextEditTransaction code, ASTNode node) =>
    code.original.substring(node.offset, node.end);

void _fixConstructor(ConstructorDeclaration ctor, TextEditTransaction code,
    Set<String> changedFields) {

  // Fix normal initializers
  for (var initializer in ctor.initializers) {
    if (initializer is ConstructorFieldInitializer) {
      var field = initializer.fieldName;
      if (changedFields.contains(field.name)) {
        code.edit(field.offset, field.end, '__\$${field.name}');
      }
    }
  }

  // Fix "this." initializer in parameter list. These are tricky:
  // we need to preserve the name and add an initializer.
  // Preserving the name is important for named args, and for dartdoc.
  // BEFORE: Foo(this.bar, this.baz) { ... }
  // AFTER:  Foo(bar, baz) : __$bar = bar, __$baz = baz { ... }

  var thisInit = [];
  for (var param in ctor.parameters.parameters) {
    if (param is DefaultFormalParameter) {
      param = param.parameter;
    }
    if (param is FieldFormalParameter) {
      var name = param.identifier.name;
      if (changedFields.contains(name)) {
        thisInit.add(name);
        // Remove "this." but keep everything else.
        code.edit(param.thisToken.offset, param.period.end, '');
      }
    }
  }

  if (thisInit.length == 0) return;

  // TODO(jmesserly): smarter formatting with indent, etc.
  var inserted = thisInit.map((i) => '__\$$i = $i').join(', ');

  int offset;
  if (ctor.separator != null) {
    offset = ctor.separator.end;
    inserted = ' $inserted,';
  } else {
    offset = ctor.parameters.end;
    inserted = ' : $inserted';
  }

  code.edit(offset, offset, inserted);
}

bool _isReadOnly(VariableDeclarationList fields) {
  return _hasKeyword(fields.keyword, Keyword.CONST) ||
      _hasKeyword(fields.keyword, Keyword.FINAL);
}

void _transformFields(VariableDeclarationList fields, TextEditTransaction code,
    int begin, int end) {

  if (_isReadOnly(fields)) return;

  var indent = guessIndent(code.original, begin);
  var replace = new StringBuffer();

  // Unfortunately "var" doesn't work in all positions where type annotations
  // are allowed, such as "var get name". So we use "dynamic" instead.
  var type = 'dynamic';
  if (fields.type != null) {
    type = _getOriginalCode(code, fields.type);
  }

  for (var field in fields.variables) {
    var initializer = '';
    if (field.initializer != null) {
      initializer = ' = ${_getOriginalCode(code, field.initializer)}';
    }

    var name = field.name.name;

    // TODO(jmesserly): should we generate this one one line, so source maps
    // don't break?
    if (replace.length > 0) replace.write('\n\n$indent');
    replace.write('''
$type __\$$name$initializer;
$type get $name => __\$$name;
set $name($type value) {
  __\$$name = notifyPropertyChange(const Symbol('$name'), __\$$name, value);
}
'''.replaceAll('\n', '\n$indent'));
  }

  code.edit(begin, end, '$replace');
}
