/*
 * Copyright (c) 2012, the Dart project authors.
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
package com.google.dart.engine.internal.context;

import com.google.dart.engine.EngineTestCase;
import com.google.dart.engine.ast.ClassDeclaration;
import com.google.dart.engine.ast.CompilationUnit;
import com.google.dart.engine.context.AnalysisContextFactory;
import com.google.dart.engine.context.ChangeResult;
import com.google.dart.engine.context.ChangeSet;
import com.google.dart.engine.element.Element;
import com.google.dart.engine.element.ElementLocation;
import com.google.dart.engine.error.AnalysisError;
import com.google.dart.engine.error.GatheringErrorListener;
import com.google.dart.engine.html.scanner.HtmlScanResult;
import com.google.dart.engine.internal.element.ElementLocationImpl;
import com.google.dart.engine.scanner.Token;
import com.google.dart.engine.source.FileBasedSource;
import com.google.dart.engine.source.FileUriResolver;
import com.google.dart.engine.source.Source;
import com.google.dart.engine.source.SourceContainer;
import com.google.dart.engine.source.SourceFactory;
import com.google.dart.engine.source.TestSource;

import static com.google.dart.engine.utilities.io.FileUtilities2.createFile;

import java.io.File;
import java.util.Iterator;

public class AnalysisContextImplTest extends EngineTestCase {

  public void fail_getElement_location() {
    AnalysisContextImpl context = new AnalysisContextImpl();
    ElementLocation location = new ElementLocationImpl("dart:core;Object");
    Element element = context.getElement(location);
    assertNotNull(element);
    assertEquals(location, element.getLocation());
  }

  public void fail_getErrors_none() throws Exception {
    AnalysisContextImpl context = new AnalysisContextImpl();
    SourceFactory sourceFactory = new SourceFactory();
    context.setSourceFactory(sourceFactory);
    Source source = new FileBasedSource(sourceFactory, createFile("/lib.dart"));
    sourceFactory.setContents(source, "library lib;");
    AnalysisError[] errors = context.getErrors(source);
    assertNotNull(errors);
    assertLength(0, errors);
  }

  public void fail_getErrors_some() throws Exception {
    AnalysisContextImpl context = new AnalysisContextImpl();
    SourceFactory sourceFactory = new SourceFactory();
    context.setSourceFactory(sourceFactory);
    Source source = new FileBasedSource(sourceFactory, createFile("/lib.dart"));
    sourceFactory.setContents(source, "library lib;");
    AnalysisError[] errors = context.getErrors(source);
    assertNotNull(errors);
    assertTrue(errors.length > 0);
  }

  public void fail_parse_non_existent_source() throws Exception {
    AnalysisContextImpl context = new AnalysisContextImpl();
    SourceFactory sourceFactory = new SourceFactory(new FileUriResolver());
    context.setSourceFactory(sourceFactory);
    Source source = new FileBasedSource(sourceFactory, new File("/does/not/exist.dart"));
    CompilationUnit unit = context.parse(source);
    assertNotNull(unit);
  }

  public void fail_sourcesToResolve() throws Exception {
    AnalysisContextImpl context = new AnalysisContextImpl();
    SourceFactory sourceFactory = new SourceFactory();
    context.setSourceFactory(sourceFactory);
    Source source = new FileBasedSource(sourceFactory, createFile("/lib.dart"));
    // TODO (danrubel): Replace this placeholder with a real test once resolution is in place
    Iterable<Source> sourcesToResolve = context.sourcesToResolve(new Source[] {source});
    Iterator<Source> iter = sourcesToResolve.iterator();
    for (int i = 0; i < 23; i++) {
      assertTrue(iter.hasNext());
      assertNotNull(iter.next());
    }
  }

  public void test_changed() throws Exception {
    ChangeSet changes = new ChangeSet();
    TestSource added = new TestSource();
    changes.added(added);
    TestSource changed = new TestSource();
    changes.changed(changed);
    TestSource removed = new TestSource();
    changes.removed(removed);
    SourceContainer removedContainer = new SourceContainer() {
      @Override
      public boolean contains(Source source) {
        return false;
      }
    };
    changes.removedContainer(removedContainer);

    // TODO (danrubel): update once changed is properly implemented
    final Object[] args = new Object[4];
    AnalysisContextImpl context = new AnalysisContextImpl() {
      @Override
      public void sourceAvailable(Source source) {
        assign(0, source);
      }

      @Override
      public void sourceChanged(Source source) {
        assign(1, source);
      }

      @Override
      public void sourceDeleted(Source source) {
        assign(2, source);
      }

      @Override
      public void sourcesDeleted(SourceContainer container) {
        assign(3, container);
      }

      private void assign(int index, Object value) {
        if (args[index] != null) {
          fail("unexpected invocation");
        }
        args[index] = value;
      }
    };

    ChangeResult result = context.changed(changes);

    assertNotNull(result);
    assertSame(added, args[0]);
    assertSame(changed, args[1]);
    assertSame(removed, args[2]);
    assertSame(removedContainer, args[3]);
  }

  public void test_creation() {
    assertNotNull(new AnalysisContextImpl());
  }

  public void test_parse_no_errors() throws Exception {
    AnalysisContextImpl context = new AnalysisContextImpl();
    SourceFactory sourceFactory = new SourceFactory();
    context.setSourceFactory(sourceFactory);
    Source source = new TestSource(sourceFactory, createFile("/lib.dart"), "library lib;");
    CompilationUnit compilationUnit = context.parse(source);
    assertLength(0, compilationUnit.getParsingErrors());
    // TODO (danrubel): assert no semantic errors
//    assertEquals(null, compilationUnit.getSemanticErrors());
//    assertEquals(null, compilationUnit.getErrors());
  }

  public void test_parse_with_errors() throws Exception {
    AnalysisContextImpl context = new AnalysisContextImpl();
    SourceFactory sourceFactory = new SourceFactory();
    context.setSourceFactory(sourceFactory);
    Source source = new TestSource(sourceFactory, createFile("/lib.dart"), "library {");
    CompilationUnit compilationUnit = context.parse(source);
    assertTrue("Expected syntax errors", compilationUnit.getParsingErrors().length > 0);
    // TODO (danrubel): assert no semantic errors
//  assertEquals(null, compilationUnit.getSemanticErrors());
//  assertEquals(null, compilationUnit.getErrors());
  }

  public void test_parse_with_listener() throws Exception {
    AnalysisContextImpl context = new AnalysisContextImpl();
    SourceFactory sourceFactory = new SourceFactory();
    context.setSourceFactory(sourceFactory);
    Source source = new FileBasedSource(sourceFactory, createFile("/lib.dart"));
    sourceFactory.setContents(source, "library lib;");
    GatheringErrorListener listener = new GatheringErrorListener();
    CompilationUnit compilationUnit = context.parse(source, listener);
    assertNotNull(compilationUnit);
  }

  public void test_resolve() throws Exception {
    AnalysisContextImpl context = AnalysisContextFactory.contextWithCore();
    SourceFactory sourceFactory = context.getSourceFactory();
    Source source = new FileBasedSource(sourceFactory, createFile("/lib.dart"));
    sourceFactory.setContents(source, "library lib;");
    CompilationUnit compilationUnit = context.resolve(source, null);
    assertNotNull(compilationUnit);
    assertLength(0, compilationUnit.getParsingErrors());
    assertLength(0, compilationUnit.getResolutionErrors());
    assertLength(0, compilationUnit.getErrors());
  }

  public void test_scan() throws Exception {
    AnalysisContextImpl context = new AnalysisContextImpl();
    SourceFactory sourceFactory = new SourceFactory();
    context.setSourceFactory(sourceFactory);
    Source source = new FileBasedSource(sourceFactory, createFile("/lib.dart"));;
    sourceFactory.setContents(source, "library lib;");
    GatheringErrorListener listener = new GatheringErrorListener();
    Token token = context.scan(source, listener);
    assertNotNull(token);
  }

  public void test_scanHtml() throws Exception {
    AnalysisContextImpl context = new AnalysisContextImpl();
    SourceFactory sourceFactory = new SourceFactory();
    context.setSourceFactory(sourceFactory);
    Source source = new FileBasedSource(sourceFactory, createFile("/lib.dart"));;
    sourceFactory.setContents(source, "<!DOCTYPE html><html><body>foo</body></html>");
    HtmlScanResult result = context.scanHtml(source);
    assertNotNull(result.getToken());
    assertNotNull(result.getLineStarts());
  }

  public void test_setSourceFactory() {
    AnalysisContextImpl context = new AnalysisContextImpl();
    SourceFactory sourceFactory = new SourceFactory();
    context.setSourceFactory(sourceFactory);
    assertEquals(sourceFactory, context.getSourceFactory());
  }

  public void test_sourceChanged() throws Exception {
    AnalysisContextImpl context = new AnalysisContextImpl();
    SourceFactory sourceFactory = new SourceFactory();
    context.setSourceFactory(sourceFactory);
    Source source = new FileBasedSource(sourceFactory, createFile("/lib.dart"));

    sourceFactory.setContents(source, "class A {}");
    CompilationUnit unit = context.parse(source, new GatheringErrorListener());
    assertEquals("A", ((ClassDeclaration) unit.getDeclarations().get(0)).getName().getName());

    sourceFactory.setContents(source, "class B {}");
    context.sourceChanged(source);
    unit = context.parse(source, new GatheringErrorListener());
    assertEquals("B", ((ClassDeclaration) unit.getDeclarations().get(0)).getName().getName());
  }
}
