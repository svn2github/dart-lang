// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library _foreign_helper;

/**
 * Emits a JavaScript code fragment parameterized by arguments.
 *
 * Hash characters `#` in the [codeTemplate] are replaced in left-to-right order
 * with expressions that contain the values of, or evaluate to, the arguments.
 * The number of hash marks must match the number or arguments.  Although
 * declared with arguments [arg0] through [arg2], the form actually has no limit
 * on the number of arguments.
 *
 * The [typeDescription] argument is interpreted as a description of the
 * behavior of the JavaScript code.  Currently it describes the types that may
 * be returned by the expression, with the additional behavior that the returned
 * values may be fresh instances of the types.  The type information must be
 * correct as it is trusted by the compiler in optimizations, and it must be
 * precise as possible since it is used for native live type analysis to
 * tree-shake large parts of the DOM libraries.  If poorly written, the
 * [typeDescription] will cause unnecessarily bloated programs.  (You can check
 * for this by compiling with `--verbose`; there is an info message describing
 * the number of native (DOM) types that can be removed, which usually should be
 * greater than zero.)
 *
 * The [typeDescription] is a [String] which contains a union of types separated
 * by vertical bar `|` symbols, e.g.  `"num|String"` describes the union of
 * numbers and Strings.  There is no type in Dart that is this precise.  The
 * Dart alternative would be `Object` or `dynamic`, but these types imply that
 * the JS-code might also be creating instances of all the DOM types.  If `null`
 * is possible, it must be specified explicitly, e.g. `"String|Null"`.
 * [typeDescription] has several extensions to help describe the behavior more
 * accurately.  In addition to the union type already described:
 *
 *  + `=Object` is a plain JavaScript object.  Some DOM methods return instances
 *     that have no corresponing Dart type (e.g. cross-frame documents),
 *     `=Object` can be used to describe these untyped' values.
 *
 *  + `var`.  If the entire [typeDescription] is `var` then the type is
 *    `dynamic` but the code is known to not create any instances.
 *
 * Examples:
 *
 *     // Parent window might be an opaque cross-frame window.
 *     var thing = JS('=Object|Window', '#.parent', myWindow);
 *
 * Guidelines:
 *
 *  + Do not use any parameter, local, method or field names in the
 *    [codeTemplate].  These names are all subject to arbitrary renaming by the
 *    compiler.  Pass the values in via `#` substition, and test with the
 *    `--minify` dart2js command-line option.
 *
 *  + The substituted expressions are values, not locations.
 *
 *        JS('void', '# += "x"', this.field);
 *
 *    `this.field` might not be a substituted as a reference to the field.  The
 *    generated code might accidentally work as intended, but it also might be
 *
 *        var t1 = this.field;
 *        t1 += "x";
 *
 *    or
 *
 *        this.get$field() += "x";
 *
 *    The remedy in this case is to expand the `+=` operator, leaving all
 *    references to the Dart field as Dart code:
 *
 *        this.field = JS('String', '# + "x"', this.field);
 *
 *
 * Additional notes.
 *
 * In the future we may extend [typeDescription] to include other aspects of the
 * behavior, for example, separating the returned types from the instantiated
 * types, or including effects to allow the compiler to perform more
 * optimizations around the code.  This might be an extension of [JS] or a new
 * function similar to [JS] with additional arguments for the new information.
 */
// Add additional optional arguments if needed. The method is treated internally
// as a variable argument method.
JS(String typeDescription, String codeTemplate,
    [arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11])
{}

/**
 * Returns the isolate in which this code is running.
 */
IsolateContext JS_CURRENT_ISOLATE_CONTEXT() {}

abstract class IsolateContext {
  /// Holds a (native) JavaScript instance of Isolate, see
  /// finishIsolateConstructorFunction in emitter.dart.
  get isolateStatics;
}

/**
 * Invokes [function] in the context of [isolate].
 */
JS_CALL_IN_ISOLATE(isolate, Function function) {}

/**
 * Converts the Dart closure [function] into a JavaScript closure.
 */
DART_CLOSURE_TO_JS(Function function) {}

/**
 * Returns a raw reference to the JavaScript function which implements
 * [function].
 *
 * Warning: this is dangerous, you should probably use
 * [DART_CLOSURE_TO_JS] instead. The returned object is not a valid
 * Dart closure, does not store the isolate context or arity.
 *
 * A valid example of where this can be used is as the second argument
 * to V8's Error.captureStackTrace. See
 * https://code.google.com/p/v8/wiki/JavaScriptStackTraceApi.
 */
RAW_DART_FUNCTION_REF(Function function) {}

/**
 * Sets the current isolate to [isolate].
 */
void JS_SET_CURRENT_ISOLATE(isolate) {}

/**
 * Creates an isolate and returns it.
 */
JS_CREATE_ISOLATE() {}

/**
 * Returns the JavaScript constructor function for Dart's Object class.
 * This can be used for type tests, as in
 *
 *     if (JS('bool', '# instanceof #', obj, JS_DART_OBJECT_CONSTRUCTOR()))
 *       ...
 */
JS_DART_OBJECT_CONSTRUCTOR() {}

/**
 * Returns the prefix used for generated is checks on classes.
 */
String JS_OPERATOR_IS_PREFIX() {}

/**
 * Returns the prefix used for generated type argument substitutions on classes.
 */
String JS_OPERATOR_AS_PREFIX() {}

/// Returns the name of the class `Object` in the generated code.
String JS_OBJECT_CLASS_NAME() {}

/// Returns the name of the class `Function` in the generated code.
String JS_FUNCTION_CLASS_NAME() {}

/**
 * Returns the field name used for determining if an object or its
 * interceptor has JavaScript indexing behavior.
 */
String JS_IS_INDEXABLE_FIELD_NAME() {}

/**
 * Returns the object corresponding to Namer.CURRENT_ISOLATE.
 */
JS_CURRENT_ISOLATE() {}

/// Returns the name used for generated function types on classes and methods.
String JS_SIGNATURE_NAME() {}

/// Returns the name used to tag function type representations in JavaScript.
String JS_FUNCTION_TYPE_TAG() {}

/**
 * Returns the name used to tag void return in function type representations
 * in JavaScript.
 */
String JS_FUNCTION_TYPE_VOID_RETURN_TAG() {}

/**
 * Returns the name used to tag return types in function type representations
 * in JavaScript.
 */
String JS_FUNCTION_TYPE_RETURN_TYPE_TAG() {}

/**
 * Returns the name used to tag required parameters in function type
 * representations in JavaScript.
 */
String JS_FUNCTION_TYPE_REQUIRED_PARAMETERS_TAG() {}

/**
 * Returns the name used to tag optional parameters in function type
 * representations in JavaScript.
 */
String JS_FUNCTION_TYPE_OPTIONAL_PARAMETERS_TAG() {}

/**
 * Returns the name used to tag named parameters in function type
 * representations in JavaScript.
 */
String JS_FUNCTION_TYPE_NAMED_PARAMETERS_TAG() {}

/**
 * Returns the global object, usually called encoded as [: $ :].
 */
JS_GLOBAL_OBJECT() {}
