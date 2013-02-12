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
package com.google.dart.engine.internal.element.handle;

import com.google.dart.engine.element.ElementKind;
import com.google.dart.engine.element.FunctionElement;
import com.google.dart.engine.element.VariableElement;
import com.google.dart.engine.type.Type;
import com.google.dart.engine.utilities.source.SourceRange;

/**
 * Instances of the class {@code VariableElementHandle} implement a handle to a
 * {@code VariableElement}.
 */
public class VariableElementHandle extends ElementHandle implements VariableElement {
  /**
   * Initialize a newly created element handle to represent the given element.
   * 
   * @param element the element being represented
   */
  public VariableElementHandle(VariableElement element) {
    super(element);
  }

  @Override
  public FunctionElement getInitializer() {
    return getActualElement().getInitializer();
  }

  @Override
  public ElementKind getKind() {
    return ElementKind.VARIABLE;
  }

  @Override
  public Type getType() {
    return getActualElement().getType();
  }

  @Override
  public SourceRange getVisibleRange() {
    return getActualElement().getVisibleRange();
  }

  @Override
  public boolean isConst() {
    return getActualElement().isConst();
  }

  @Override
  public boolean isFinal() {
    return getActualElement().isFinal();
  }

  @Override
  protected VariableElement getActualElement() {
    return (VariableElement) super.getActualElement();
  }
}
