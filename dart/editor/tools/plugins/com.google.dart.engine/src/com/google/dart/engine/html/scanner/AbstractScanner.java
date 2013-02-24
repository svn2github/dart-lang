/*
 * Copyright (c) 2013, the Dart project authors.
 * 
 * Licensed under the Eclipse Public License v1.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.google.dart.engine.html.scanner;

import com.google.dart.engine.source.Source;
import com.google.dart.engine.utilities.collection.IntList;
import com.google.dart.engine.utilities.instrumentation.Instrumentation;

import static com.google.dart.engine.html.scanner.TokenType.COMMENT;
import static com.google.dart.engine.html.scanner.TokenType.DIRECTIVE;
import static com.google.dart.engine.html.scanner.TokenType.EOF;
import static com.google.dart.engine.html.scanner.TokenType.EQ;
import static com.google.dart.engine.html.scanner.TokenType.GT;
import static com.google.dart.engine.html.scanner.TokenType.LT;
import static com.google.dart.engine.html.scanner.TokenType.LT_SLASH;
import static com.google.dart.engine.html.scanner.TokenType.SLASH_GT;
import static com.google.dart.engine.html.scanner.TokenType.STRING;
import static com.google.dart.engine.html.scanner.TokenType.TAG;
import static com.google.dart.engine.html.scanner.TokenType.TEXT;

/**
 * The abstract class {@code AbstractScanner} implements a scanner for HTML code. Subclasses are
 * required to implement the interface used to access the characters being scanned.
 */
public abstract class AbstractScanner {
  /**
   * The source being scanned.
   */
  private final Source source;

  /**
   * The token pointing to the head of the linked list of tokens.
   */
  private Token tokens;

  /**
   * The last token that was scanned.
   */
  private Token tail;

  /**
   * A list containing the offsets of the first character of each line in the source code.
   */
  private IntList lineStarts = new IntList();

  /**
   * An array of element tags for which the content between tags should be consider a single token.
   */
  private String[] passThroughElements;

  /**
   * Initialize a newly created scanner.
   * 
   * @param source the source being scanned
   */
  public AbstractScanner(Source source) {
    this.source = source;
    tokens = new Token(EOF, -1);
    tokens.setNext(tokens);
    tail = tokens;
    recordStartOfLine();
  }

  /**
   * Return an array containing the offsets of the first character of each line in the source code.
   * 
   * @return an array containing the offsets of the first character of each line in the source code
   */
  public int[] getLineStarts() {
    return lineStarts.toArray();
  }

  /**
   * Return the current offset relative to the beginning of the file. Return the initial offset if
   * the scanner has not yet scanned the source code, and one (1) past the end of the source code if
   * the source code has been scanned.
   * 
   * @return the current offset of the scanner in the source
   */
  public abstract int getOffset();

  /**
   * Answer the source being scanned.
   * 
   * @return the source or {@code null} if undefined
   */
  public Source getSource() {
    return source;
  }

  /**
   * Set array of element tags for which the content between tags should be consider a single token.
   */
  public void setPassThroughElements(String[] passThroughElements) {
    this.passThroughElements = passThroughElements;
  }

  /**
   * Scan the source code to produce a list of tokens representing the source.
   * 
   * @return the first token in the list of tokens that were produced
   */
  public Token tokenize() {
    long startTime = System.currentTimeMillis();
    scan();
    appendEofToken();
    long endTime = System.currentTimeMillis();
    Instrumentation.metric("Engine-Html-Scanner", endTime - startTime).with("chars", getOffset()).log();
    return firstToken();
  }

  /**
   * Advance the current position and return the character at the new current position.
   * 
   * @return the character at the new current position
   */
  protected abstract int advance();

  /**
   * Return the substring of the source code between the start offset and the modified current
   * position. The current position is modified by adding the end delta.
   * 
   * @param start the offset to the beginning of the string, relative to the start of the file
   * @param endDelta the number of character after the current location to be included in the
   *          string, or the number of characters before the current location to be excluded if the
   *          offset is negative
   * @return the specified substring of the source code
   */
  protected abstract String getString(int start, int endDelta);

  /**
   * Return the character at the current position without changing the current position.
   * 
   * @return the character at the current position
   */
  protected abstract int peek();

  /**
   * Record the fact that we are at the beginning of a new line in the source.
   */
  protected void recordStartOfLine() {
    lineStarts.add(getOffset());
  }

  private void appendEofToken() {
    Token eofToken = new Token(EOF, getOffset());
    // The EOF token points to itself so that there is always infinite look-ahead.
    eofToken.setNext(eofToken);
    tail = tail.setNext(eofToken);
  }

  private Token emit(Token token) {
    tail.setNext(token);
    tail = token;
    return token;
  }

  private Token emit(TokenType type, int start) {
    return emit(new Token(type, start));
  }

  private Token emit(TokenType type, int start, int count) {
    return emit(new Token(type, getString(start, count), start));
  }

  private Token firstToken() {
    return tokens.getNext();
  }

  private int recordStartOfLineAndAdvance(int c) {
    if (c == '\r') {
      c = advance();
      if (c == '\n') {
        c = advance();
      }
      recordStartOfLine();
    } else if (c == '\n') {
      c = advance();
      recordStartOfLine();
    } else {
      c = advance();
    }
    return c;
  }

  private void scan() {
    boolean inBrackets = false;
    boolean passThrough = false;

    // <--, -->, <?, <, >, =, "***", '***', in brackets, normal

    int c = advance();
    while (c >= 0) {
      final int start = getOffset();

      if (c == '<') {
        c = advance();

        if (c == '!') {
          c = advance();

          if (c == '-' && peek() == '-') {
            // handle a comment
            c = advance();
            int dashCount = 1;
            while (c >= 0) {
              if (c == '-') {
                dashCount++;
              } else if (c == '>' && dashCount >= 2) {
                c = advance();
                break;
              } else {
                dashCount = 0;
              }
              c = recordStartOfLineAndAdvance(c);
            }
            emit(COMMENT, start, -1);
            // Capture <!--> and <!---> as tokens but report an error
            if (tail.getLength() < 7) {
              // TODO (danrubel): Report invalid HTML comment
            }

          } else {
            // handle a directive
            while (c >= 0) {
              if (c == '>') {
                c = advance();
                break;
              }
              c = recordStartOfLineAndAdvance(c);
            }
            emit(DIRECTIVE, start, -1);
            if (!tail.getLexeme().endsWith(">")) {
              // TODO (danrubel): Report missing '>' in directive
            }
          }

        } else if (c == '?') {
          // handle a directive
          while (c >= 0) {
            if (c == '?') {
              c = advance();
              if (c == '>') {
                c = advance();
                break;
              }
            } else {
              c = recordStartOfLineAndAdvance(c);
            }
          }
          emit(DIRECTIVE, start, -1);
          if (tail.getLength() < 4) {
            // TODO (danrubel): Report invalid directive
          }

        } else if (c == '/') {
          emit(LT_SLASH, start);
          inBrackets = true;
          c = advance();

        } else {
          inBrackets = true;
          emit(LT, start);
          // ignore whitespace in braces
          while (Character.isWhitespace(c)) {
            c = recordStartOfLineAndAdvance(c);
          }
          // get tag
          if (Character.isLetterOrDigit(c)) {
            int tagStart = getOffset();
            c = advance();
            while (Character.isLetterOrDigit(c) || c == '-' || c == '_') {
              c = advance();
            }
            emit(TAG, tagStart, -1);
            // check tag against passThrough elements
            String tag = tail.getLexeme();
            for (String str : passThroughElements) {
              if (str.equals(tag)) {
                passThrough = true;
                break;
              }
            }
          }

        }

      } else if (c == '>') {
        emit(GT, start);
        inBrackets = false;
        c = advance();

        // if passThrough != null, read until we match it
        if (passThrough) {
          while (c >= 0 && (c != '<' || peek() != '/')) {
            c = recordStartOfLineAndAdvance(c);
          }
          if (start + 1 < getOffset()) {
            emit(TEXT, start + 1, -1);
          }
          passThrough = false;
        }

      } else if (c == '/' && peek() == '>') {
        advance();
        emit(SLASH_GT, start);
        inBrackets = false;
        c = advance();

      } else if (!inBrackets) {
        c = recordStartOfLineAndAdvance(c);
        while (c != '<' && c >= 0) {
          c = recordStartOfLineAndAdvance(c);
        }
        emit(TEXT, start, -1);

      } else if (c == '"' || c == '\'') {
        // read a string
        int endQuote = c;
        c = advance();
        while (c >= 0) {
          if (c == endQuote) {
            c = advance();
            break;
          }
          c = recordStartOfLineAndAdvance(c);
        }
        emit(STRING, start, -1);

      } else if (c == '=') {
        // a non-char token
        emit(EQ, start);
        c = advance();

      } else if (Character.isWhitespace(c)) {
        // ignore whitespace in braces
        do {
          c = recordStartOfLineAndAdvance(c);
        } while (Character.isWhitespace(c));

      } else if (Character.isLetterOrDigit(c)) {
        c = advance();
        while (Character.isLetterOrDigit(c) || c == '-' || c == '_') {
          c = advance();
        }
        emit(TAG, start, -1);

      } else {
        // a non-char token
        emit(TEXT, start, 0);
        c = advance();

      }
    }
  }
}
