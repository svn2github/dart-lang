// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// Class for intrinsifying functions.

#ifndef VM_INTRINSIFIER_H_
#define VM_INTRINSIFIER_H_

#include "vm/allocation.h"

namespace dart {

// List of intrinsics:
// (class-name, function-name, intrinsification method, fingerprint).
//
// When adding a new function for intrinsification add a 0 as fingerprint,
// build and run to get the correct fingerprint from the mismatch error.
#define CORE_LIB_INTRINSIC_LIST(V)                                             \
  V(_Smi, ~, Smi_bitNegate, 2098673794)                                        \
  V(_Double, >, Double_greaterThan, 498448864)                                 \
  V(_Double, >=, Double_greaterEqualThan, 1322959863)                          \
  V(_Double, <, Double_lessThan, 1595326820)                                   \
  V(_Double, <=, Double_lessEqualThan, 1322930072)                             \
  V(_Double, ==, Double_equal, 1012968674)                                     \
  V(_Double, +, Double_add, 407090160)                                         \
  V(_Double, -, Double_sub, 1801868246)                                        \
  V(_Double, *, Double_mul, 984784342)                                         \
  V(_Double, /, Double_div, 1399344917)                                        \
  V(_Double, get:isNaN, Double_getIsNaN, 54462366)                             \
  V(_Double, get:isNegative, Double_getIsNegative, 54462366)                   \
  V(_Double, _mulFromInteger, Double_mulFromInteger, 550294258)                \
  V(_Double, .fromInteger, Double_fromInteger, 881555713)                      \
  V(_ObjectArray, ., ObjectArray_Allocate, 1149848530)                         \
  V(_ObjectArray, get:length, Array_getLength, 405297088)                      \
  V(_ObjectArray, [], Array_getIndexed, 1573881683)                            \
  V(_ObjectArray, []=, Array_setIndexed, 1644545484)                           \
  V(_GrowableObjectArray, .withData, GrowableArray_Allocate, 569069682)        \
  V(_GrowableObjectArray, get:length, GrowableArray_getLength, 725548050)      \
  V(_GrowableObjectArray, get:_capacity, GrowableArray_getCapacity, 725548050) \
  V(_GrowableObjectArray, [], GrowableArray_getIndexed, 1889032295)            \
  V(_GrowableObjectArray, []=, GrowableArray_setIndexed, 934874427)            \
  V(_GrowableObjectArray, _setLength, GrowableArray_setLength, 279007375)      \
  V(_GrowableObjectArray, _setData, GrowableArray_setData, 588108129)          \
  V(_GrowableObjectArray, add, GrowableArray_add, 112207566)                   \
  V(_ImmutableArray, [], ImmutableArray_getIndexed, 1456194617)                \
  V(_ImmutableArray, get:length, ImmutableArray_getLength, 433698233)          \
  V(Object, ==, Object_equal, 2126867222)                                      \
  V(_StringBase, get:hashCode, String_getHashCode, 320803993)                  \
  V(_StringBase, get:isEmpty, String_getIsEmpty, 110631520)                    \
  V(_StringBase, get:length, String_getLength, 320803993)                      \
  V(_StringBase, codeUnitAt, String_codeUnitAt, 1574843871)                    \
  V(_OneByteString, get:hashCode, OneByteString_getHashCode, 682660413)        \
  V(_OneByteString, _substringUncheckedNative,                                 \
      OneByteString_substringUnchecked, 756784624)                             \
  V(_OneByteString, _setAt, OneByteString_setAt, 1038132016)                   \
  V(_OneByteString, _allocate, OneByteString_allocate, 716379334)              \


#define CORE_INTEGER_LIB_INTRINSIC_LIST(V)                                     \
  V(_IntegerImplementation, _addFromInteger, Integer_addFromInteger,           \
    1074291215)                                                                \
  V(_IntegerImplementation, +, Integer_add, 25837296)                          \
  V(_IntegerImplementation, _subFromInteger, Integer_subFromInteger,           \
    1074291215)                                                                \
  V(_IntegerImplementation, -, Integer_sub, 1697139934)                        \
  V(_IntegerImplementation, _mulFromInteger, Integer_mulFromInteger,           \
    1074291215)                                                                \
  V(_IntegerImplementation, *, Integer_mul, 110370751)                         \
  V(_IntegerImplementation, %, Integer_modulo, 980686435)                      \
  V(_IntegerImplementation, remainder, Integer_remainder, 1536426035)          \
  V(_IntegerImplementation, ~/, Integer_truncDivide, 2059401166)               \
  V(_IntegerImplementation, unary-, Integer_negate, 675709702)                 \
  V(_IntegerImplementation, _bitAndFromInteger,                                \
    Integer_bitAndFromInteger, 1074291215)                                     \
  V(_IntegerImplementation, &, Integer_bitAnd, 759019505)                      \
  V(_IntegerImplementation, _bitOrFromInteger,                                 \
    Integer_bitOrFromInteger, 1074291215)                                      \
  V(_IntegerImplementation, |, Integer_bitOr, 1280367298)                      \
  V(_IntegerImplementation, _bitXorFromInteger,                                \
    Integer_bitXorFromInteger, 1074291215)                                     \
  V(_IntegerImplementation, ^, Integer_bitXor, 686827811)                      \
  V(_IntegerImplementation,                                                    \
    _greaterThanFromInteger,                                                   \
    Integer_greaterThanFromInt, 2056270230)                                    \
  V(_IntegerImplementation, >, Integer_greaterThan, 866987265)                 \
  V(_IntegerImplementation, ==, Integer_equal, 1763184121)                     \
  V(_IntegerImplementation, _equalToInteger, Integer_equalToInteger,           \
    2056270230)                                                                \
  V(_IntegerImplementation, <, Integer_lessThan, 1423913958)                   \
  V(_IntegerImplementation, <=, Integer_lessEqualThan, 1087447066)             \
  V(_IntegerImplementation, >=, Integer_greaterEqualThan, 1087476857)          \
  V(_IntegerImplementation, <<, Integer_shl, 1600590181)                       \
  V(_IntegerImplementation, >>, Integer_sar, 237416447)                        \
  V(_Double, toInt, Double_toInt, 630286253)


#define MATH_LIB_INTRINSIC_LIST(V)                                             \
  V(::, sqrt, Math_sqrt, 1662640002)                                           \
  V(::, sin, Math_sin, 1273932041)                                             \
  V(::, cos, Math_cos, 1749547468)                                             \
  V(_Random, _nextState, Random_nextState, 287494804)                          \


#define TYPED_DATA_LIB_INTRINSIC_LIST(V)                                       \
  V(_TypedList, get:length, TypedData_getLength, 1004567191)                   \
  V(_Int8Array, _new, TypedData_Int8Array_new, 1708300323)                     \
  V(_Uint8Array, _new, TypedData_Uint8Array_new, 280387497)                    \
  V(_Uint8ClampedArray, _new, TypedData_Uint8ClampedArray_new, 1035267417)     \
  V(_Int16Array, _new, TypedData_Int16Array_new, 1460383283)                   \
  V(_Uint16Array, _new, TypedData_Uint16Array_new, 737997883)                  \
  V(_Int32Array, _new, TypedData_Int32Array_new, 1608749233)                   \
  V(_Uint32Array, _new, TypedData_Uint32Array_new, 1955293459)                 \
  V(_Int64Array, _new, TypedData_Int64Array_new, 1992227270)                   \
  V(_Uint64Array, _new, TypedData_Uint64Array_new, 291118076)                  \
  V(_Float32Array, _new, TypedData_Float32Array_new, 962527805)                \
  V(_Float64Array, _new, TypedData_Float64Array_new, 1871142667)               \
  V(_Float32x4Array, _new, TypedData_Float32x4Array_new, 1873359556)           \
  V(_Int8Array, ., TypedData_Int8Array_factory, 1139775342)                    \
  V(_Uint8Array, ., TypedData_Uint8Array_factory, 2065936658)                  \
  V(_Uint8ClampedArray, ., TypedData_Uint8ClampedArray_factory, 1420655937)    \
  V(_Int16Array, ., TypedData_Int16Array_factory, 1401847016)                  \
  V(_Uint16Array, ., TypedData_Uint16Array_factory, 967612741)                 \
  V(_Int32Array, ., TypedData_Int32Array_factory, 332168564)                   \
  V(_Uint32Array, ., TypedData_Uint32Array_factory, 966424258)                 \
  V(_Int64Array, ., TypedData_Int64Array_factory, 541618991)                   \
  V(_Uint64Array, ., TypedData_Uint64Array_factory, 1085703705)                \
  V(_Float32Array, ., TypedData_Float32Array_factory, 1691006880)              \
  V(_Float64Array, ., TypedData_Float64Array_factory, 1867705160)              \
  V(_Float32x4Array, ., TypedData_Float32x4Array_factory, 1739837241)          \

// TODO(srdjan): Implement _FixedSizeArrayIterator, get:current and
//   _FixedSizeArrayIterator, moveNext.

// Forward declarations.
class Assembler;
class Function;

class Intrinsifier : public AllStatic {
 public:
  // Try to intrinsify 'function'. Returns true if the function intrinsified
  // completely and the code does not need to be generated (i.e., no slow
  // path possible).
  static bool Intrinsify(const Function& function, Assembler* assembler);
  static bool CanIntrinsify(const Function& function);
  static void InitializeState();

 private:
#define DECLARE_FUNCTION(test_class_name, test_function_name, destination, fp) \
  static bool destination(Assembler* assembler);

  CORE_LIB_INTRINSIC_LIST(DECLARE_FUNCTION)
  CORE_INTEGER_LIB_INTRINSIC_LIST(DECLARE_FUNCTION)
  MATH_LIB_INTRINSIC_LIST(DECLARE_FUNCTION)
  TYPED_DATA_LIB_INTRINSIC_LIST(DECLARE_FUNCTION)

#undef DECLARE_FUNCTION
};

}  // namespace dart

#endif  // VM_INTRINSIFIER_H_
