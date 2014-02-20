/*
 * Copyright (c) 2011, the Dart project authors.
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
package com.google.dart.tools.core.internal.model;

import com.google.dart.engine.utilities.source.SourceRange;
import com.google.dart.tools.core.buffer.Buffer;
import com.google.dart.tools.core.internal.model.info.DartElementInfo;
import com.google.dart.tools.core.internal.util.Messages;
import com.google.dart.tools.core.model.CompilationUnit;
import com.google.dart.tools.core.model.DartElement;
import com.google.dart.tools.core.model.DartModelException;
import com.google.dart.tools.core.model.OpenableElement;
import com.google.dart.tools.core.model.SourceReference;

import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;

import java.util.HashMap;

/**
 * Instances of the class <code>SourceReferenceImpl</code>.
 * 
 * @coverage dart.tools.core.model
 */
public abstract class SourceReferenceImpl extends DartElementImpl implements SourceReference {
  /*
   * A count to uniquely identify this element in the case that a duplicate named element exists.
   * For example, if there are two fields in a compilation unit with the same name, the occurrence
   * count is used to distinguish them. The occurrence count starts at 1 (thus the first occurrence
   * is occurrence 1, not occurrence 0).
   */
  public int occurrenceCount = 1;

  protected SourceReferenceImpl(DartElementImpl parent) {
    super(parent);
  }

  /**
   * @see ISourceManipulation
   */
  public void copy(DartElement container, DartElement sibling, String rename, boolean force,
      IProgressMonitor monitor) throws DartModelException {
    if (container == null) {
      throw new IllegalArgumentException(Messages.operation_nullContainer);
    }
    DartElement[] elements = new DartElement[] {this};
    DartElement[] containers = new DartElement[] {container};
    DartElement[] siblings = null;
    if (sibling != null) {
      siblings = new DartElement[] {sibling};
    }
    String[] renamings = null;
    if (rename != null) {
      renamings = new String[] {rename};
    }
    getDartModel().copy(elements, containers, siblings, renamings, force, monitor);
  }

  /**
   * @see ISourceManipulation
   */
  public void delete(boolean force, IProgressMonitor monitor) throws DartModelException {
    DartElement[] elements = new DartElement[] {this};
    getDartModel().delete(elements, force, monitor);
  }

  @Override
  public boolean equals(Object o) {
    if (!(o instanceof SourceReferenceImpl)) {
      return false;
    }
    return occurrenceCount == ((SourceReferenceImpl) o).occurrenceCount && super.equals(o);
  }

  @Override
  public CompilationUnit getCompilationUnit() {
    return getAncestor(CompilationUnit.class);
  }

  /**
   * Elements within compilation units have no corresponding resource.
   */
  @Override
  public IResource getCorrespondingResource() throws DartModelException {
    if (!exists()) {
      throw newNotPresentException();
    }
    return null;
  }

  public final SourceRange getDartDocRange() {

    return null;
  }

  /**
   * Return the occurrence count of this element. The occurrence count is used to distinguish two
   * elements that would otherwise be indistinguishable, such as two fields with the same name.
   * 
   * @return the occurrence count of this element
   */
  public int getOccurrenceCount() {
    return occurrenceCount;
  }

  @Override
  public OpenableElement getOpenableParent() {
    DartElement current = getParent();
    while (current != null) {
      if (current instanceof OpenableElement) {
        return (OpenableElement) current;
      }
      current = current.getParent();
    }
    return null;
  }

  @Override
  public IPath getPath() {
    return getParent().getPath();
  }

  @Override
  public String getSource() throws DartModelException {
    OpenableElement openable = getOpenableParent();
    Buffer buffer = openable.getBuffer();
    if (buffer == null) {
      return null;
    }
    SourceRange range = getSourceRange();
    int offset = range.getOffset();
    int length = range.getLength();
    if (offset == -1 || length == 0) {
      return null;
    }
    try {
      return buffer.getText(offset, length);
    } catch (RuntimeException e) {
      return null;
    }
  }

  @Override
  public SourceRange getSourceRange() throws DartModelException {
    return null;
  }

  @Override
  public IResource getUnderlyingResource() throws DartModelException {
    if (!exists()) {
      throw newNotPresentException();
    }
    return getParent().getUnderlyingResource();
  }

  @Override
  public boolean hasChildren() throws DartModelException {
    return getChildren().length > 0;
  }

  /**
   * Return <code>true</code> if the element is private to the library in which it is defined.
   * 
   * @return <code>true</code> if the element is private to the library in which it is defined
   */
  public boolean isPrivate() {
    //
    // This method implements the isPrivate method defined in both CompilationUnitElement and
    // TypeMember, but cannot be marked as overriding either.
    //
    String name = getElementName();
    return name != null && name.length() > 0 && name.charAt(0) == '_';
  }

  @Override
  public boolean isStructureKnown() throws DartModelException {
    // structure is always known inside an openable
    return true;
  }

  /**
   * @see ISourceManipulation
   */
  public void move(DartElement container, DartElement sibling, String rename, boolean force,
      IProgressMonitor monitor) throws DartModelException {
    if (container == null) {
      throw new IllegalArgumentException(Messages.operation_nullContainer);
    }
    DartElement[] elements = new DartElement[] {this};
    DartElement[] containers = new DartElement[] {container};
    DartElement[] siblings = null;
    if (sibling != null) {
      siblings = new DartElement[] {sibling};
    }
    String[] renamings = null;
    if (rename != null) {
      renamings = new String[] {rename};
    }
    getDartModel().move(elements, containers, siblings, renamings, force, monitor);
  }

  /**
   * @see ISourceManipulation
   */
  public void rename(String newName, boolean force, IProgressMonitor monitor)
      throws DartModelException {
    if (newName == null) {
      throw new IllegalArgumentException(Messages.element_nullName);
    }
    DartElement[] elements = new DartElement[] {this};
    DartElement[] dests = new DartElement[] {getParent()};
    String[] renamings = new String[] {newName};
    getDartModel().rename(elements, dests, renamings, force, monitor);
  }

  @Override
  public IResource resource() {
    return ((DartElementImpl) getParent()).resource();
  }

  /**
   * Set the occurrence count of this element to the given value. The occurrence count is used to
   * distinguish two elements that would otherwise be indistinguishable, such as two fields with the
   * same name.
   * 
   * @param count the new occurrence count of this element
   */
  public void setOccurrenceCount(int count) {
    occurrenceCount = count;
  }

  @Override
  protected void closing(DartElementInfo info) throws DartModelException {
    // Do any necessary cleanup
  }

  @Override
  protected DartElementInfo createElementInfo() {
    return null; // not used for source ref elements
  }

  // /**
  // * Returns the <code>ASTNode</code> that corresponds to this
  // <code>JavaElement</code>
  // * or <code>null</code> if there is no corresponding node.
  // */
  // public ASTNode findNode(CompilationUnit ast) {
  // DOMFinder finder = new DOMFinder(ast, this, false);
  // try {
  // return finder.search();
  // } catch (DartModelException e) {
  // // receiver doesn't exist
  // return null;
  // }
  // }

  @Override
  protected void generateInfos(DartElementInfo info,
      HashMap<DartElement, DartElementInfo> newElements, IProgressMonitor pm)
      throws DartModelException {
    OpenableElementImpl openableParent = (OpenableElementImpl) getOpenableParent();
    if (openableParent == null) {
      return;
    }

  }

  @Override
  protected void toStringName(StringBuilder builder) {
    super.toStringName(builder);
    if (occurrenceCount > 1) {
      builder.append("#"); //$NON-NLS-1$
      builder.append(occurrenceCount);
    }
  }
}
