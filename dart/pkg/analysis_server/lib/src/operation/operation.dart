// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library operation;

import 'package:analysis_server/src/analysis_server.dart';


/**
 * The class [ServerOperation] defines the behavior of objects used to perform
 * operations on a [AnalysisServer].
 */
abstract class ServerOperation {
  /**
   * Returns the priority of this operation.
   */
  ServerOperationPriority get priority;

  /**
   * Performs the operation implemented by this operation.
   */
  void perform(AnalysisServer server);
}


/**
 * The enumeration [ServerOperationPriority] defines the priority levels used
 * to organize [ServerOperation]s in an optimal order. A smaller ordinal value
 * equates to a higher priority.
 */
class ServerOperationPriority {
  static const int COUNT = 5;

  static const ServerOperationPriority ANALYSIS_NOTIFICATION =
      const ServerOperationPriority._(0, "ANALYSIS_NOTIFICATION");

  static const ServerOperationPriority PRIORITY_ANALYSIS_CONTINUE =
      const ServerOperationPriority._(1, "PRIORITY_ANALYSIS_CONTINUE");

  static const ServerOperationPriority PRIORITY_ANALYSIS =
      const ServerOperationPriority._(2, "PRIORITY_ANALYSIS");

  static const ServerOperationPriority ANALYSIS_CONTINUE =
      const ServerOperationPriority._(3, "ANALYSIS_CONTINUE");

  static const ServerOperationPriority ANALYSIS =
      const ServerOperationPriority._(4, "ANALYSIS");

  final int ordinal;
  final String name;

  const ServerOperationPriority._(this.ordinal, this.name);

  @override
  String toString() => name;
}
