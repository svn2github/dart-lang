// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library instrumentation;

/**
 * The interface used by client code to communicate with an instrumentation
 * server.
 */
abstract class InstrumentationServer {
  /**
   * Pass the given [message] to the instrumentation server so that it will be
   * logged with other messages.
   *
   * This method should be used for most logging.
   */
  void log(String message);

  /**
   * Pass the given [message] to the instrumentation server so that it will be
   * logged with other messages.
   *
   * This method should only be used for logging high priority messages, such as
   * exceptions that cause the server to shutdown.
   */
  void logWithPriority(String message);

  /**
   * Signal that the client is done communicating with the instrumentation
   * server. This method should be invoked exactly one time and no other methods
   * should be invoked on this instance after this method has been invoked.
   */
  void shutdown();
}

/**
 * The interface used by client code to communicate with an instrumentation
 * server by wrapping an [InstrumentationServer].
 */
class InstrumentationService {
  /**
   * An instrumentation service that will not log any instrumentation data.
   */
  static final InstrumentationService NULL_SERVICE =
      new InstrumentationService(null);

  static const String TAG_ERROR = 'Err';
  static const String TAG_EXCEPTION = 'Ex';
  static const String TAG_LOG_ENTRY = 'Log';
  static const String TAG_NOTIFICATION = 'Noti';
  static const String TAG_REQUEST = 'Req';
  static const String TAG_RESPONSE = 'Res';
  static const String TAG_VERSION = 'Ver';

  /**
   * The instrumentation server used to communicate with the server, or `null`
   * if instrumentation data should not be logged.
   */
  InstrumentationServer _instrumentationServer;

  /**
   * Initialize a newly created instrumentation service to comunicate with the
   * given [instrumentationServer].
   */
  InstrumentationService(this._instrumentationServer);

  /**
   * The current time, expressed as a decimal encoded number of milliseconds.
   */
  String get _timestamp => new DateTime.now().millisecondsSinceEpoch.toString();

  /**
   * Log the fact that an error, described by the given [message], has occurred.
   */
  void logError(String message) {
    _log(TAG_ERROR, message);
  }

  /**
   * Log that the given non-priority [exception] was thrown, with the given
   * [stackTrace].
   */
  void logException(dynamic exception, StackTrace stackTrace) {
    if (_instrumentationServer != null) {
      String message = _toString(exception);
      String trace = _toString(stackTrace);
      _instrumentationServer.log(_join([TAG_EXCEPTION, message, trace]));
    }
  }

  /**
   * Log a log entry that was written to the analysis engine's log.
   */
  void logLogEntry(String level, DateTime time, String message) {
    if (_instrumentationServer != null) {
      String timeStamp = _toString(time);
      _instrumentationServer.log(
          _join([TAG_LOG_ENTRY, level, timeStamp, message]));
    }
  }

  /**
   * Log that a notification has been sent to the client.
   */
  void logNotification(String notification) {
    _log(TAG_NOTIFICATION, notification);
  }

  /**
   * Log that the given priority [exception] was thrown, with the given
   * [stackTrace].
   */
  void logPriorityException(dynamic exception, StackTrace stackTrace) {
    if (_instrumentationServer != null) {
      String message = _toString(exception);
      String trace = _toString(stackTrace);
      _instrumentationServer.logWithPriority(
          _join([TAG_EXCEPTION, message, trace]));
    }
  }

  /**
   * Log that a request has been sent to the client.
   */
  void logRequest(String request) {
    _log(TAG_REQUEST, request);
  }

  /**
   * Log that a response has been sent to the client.
   */
  void logResponse(String response) {
    _log(TAG_RESPONSE, response);
  }

  /**
   * Signal that the client is done communicating with the instrumentation
   * server. This method should be invoked exactly one time and no other methods
   * should be invoked on this instance after this method has been invoked.
   */
  void shutdown() {
    if (_instrumentationServer != null) {
      _instrumentationServer.shutdown();
      _instrumentationServer = null;
    }
  }

  /**
   * Write an escaped version of the given [field] to the given [buffer].
   */
  void _escape(StringBuffer buffer, String field) {
    int index = field.indexOf(':');
    if (index < 0) {
      buffer.write(field);
      return;
    }
    int start = 0;
    while (index >= 0) {
      buffer.write(field.substring(start, index));
      buffer.write('::');
      start = index + 1;
      index = field.indexOf(':', start);
    }
    buffer.write(field.substring(start));
  }

  /**
   * Return the result of joining the values of the given fields, escaping the
   * separator character by doubling it.
   */
  String _join(List<String> fields) {
    StringBuffer buffer = new StringBuffer();
    buffer.write(_timestamp);
    for (String field in fields) {
      buffer.write(':');
      _escape(buffer, field);
    }
    return buffer.toString();
  }

  /**
   * Log the given message with the given tag.
   */
  void _log(String tag, String message) {
    if (_instrumentationServer != null) {
      _instrumentationServer.log(_join([tag, message]));
    }
  }

  /**
   * Convert the given [object] to a string.
   */
  String _toString(Object object) {
    if (object == null) {
      return 'null';
    }
    return object.toString();
  }
}

/**
 * An [InstrumentationServer] that sends messages to multiple instances.
 */
class MulticastInstrumentationServer implements InstrumentationServer {
  final List<InstrumentationServer> _servers;

  MulticastInstrumentationServer(this._servers);

  @override
  void log(String message) {
    for (InstrumentationServer server in _servers) {
      server.log(message);
    }
  }

  @override
  void logWithPriority(String message) {
    for (InstrumentationServer server in _servers) {
      server.logWithPriority(message);
    }
  }

  @override
  void shutdown() {
    for (InstrumentationServer server in _servers) {
      server.shutdown();
    }
  }
}
