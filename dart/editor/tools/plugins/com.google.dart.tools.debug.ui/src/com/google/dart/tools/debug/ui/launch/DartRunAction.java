/*
 * Copyright 2012 Dart project authors.
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

package com.google.dart.tools.debug.ui.launch;

import com.google.dart.engine.utilities.instrumentation.InstrumentationBuilder;
import com.google.dart.tools.core.model.DartModelException;
import com.google.dart.tools.debug.ui.internal.DartDebugUIPlugin;
import com.google.dart.tools.debug.ui.internal.DartUtil;
import com.google.dart.tools.debug.ui.internal.DebugErrorHandler;
import com.google.dart.tools.debug.ui.internal.util.LaunchUtils;

import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.ui.ILaunchShortcut;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.IViewActionDelegate;
import org.eclipse.ui.IViewPart;
import org.eclipse.ui.IWorkbenchWindow;

import java.util.List;

/**
 * A toolbar action to enumerate a launch debug launch configurations.
 */
public class DartRunAction extends DartRunAbstractAction implements IViewActionDelegate {

  public DartRunAction() {
    this(null, false);
  }

  public DartRunAction(IWorkbenchWindow window) {
    this(window, false);
  }

  public DartRunAction(IWorkbenchWindow window, boolean noMenu) {
    super(window, "Run", noMenu ? IAction.AS_PUSH_BUTTON : IAction.AS_DROP_DOWN_MENU);

    setActionDefinitionId("com.google.dart.tools.debug.ui.run.selection");
    setImageDescriptor(DartDebugUIPlugin.getImageDescriptor("obj16/run_exc.gif"));
    setToolTipText("Run");

//    window.getSelectionService().addSelectionListener(this);
//    window.addPageListener(this);
  }

  @Override
  public void dispose() {
//    getWindow().removePageListener(this);
//    getWindow().getSelectionService().removeSelectionListener(this);

    super.dispose();
  }

  @Override
  public void init(IViewPart view) {

  }

//  @Override
//  public void pageActivated(IWorkbenchPage page) {
//    selectionChanged((IWorkbenchPart) null, getWindow().getSelectionService().getSelection());
//  }
//
//  @Override
//  public void pageClosed(IWorkbenchPage page) {
//
//  }
//
//  @Override
//  public void pageOpened(IWorkbenchPage page) {
//
//  }

  @Override
  protected void doLaunch(InstrumentationBuilder instrumentation) {
    try {
      IResource resource = LaunchUtils.getSelectedResource(window);

      if (resource != null) {
        instrumentation.metric("Resource-Class", resource.getClass().toString());
        instrumentation.data("Resource-Name", resource.getName());

        launchResource(resource, instrumentation);
      } else {
        List<ILaunchConfiguration> launches = LaunchUtils.getAllLaunches();

        instrumentation.metric("Launches-Count", launches.size());

        if (launches.size() == 0) {
          instrumentation.metric(
              "Problem",
              "Unable to run, not a library with a main, showing dialog");
          MessageDialog.openInformation(
              getWindow().getShell(),
              "Unable to Run",
              "Unable to run the current selection. Please choose a file in a library with a main() function.");
        } else {
          chooseAndLaunch(launches, instrumentation);
        }
      }
    } catch (CoreException ce) {
      instrumentation.metric("Problem", "Exception launching " + ce.getClass().toString());
      instrumentation.data("Problem", "Exception launching " + ce.toString());

      DartUtil.logError(ce);

      DebugErrorHandler.errorDialog(
          window.getShell(),
          "Error Launching Application",
          ce.getStatus().getMessage(),
          ce.getStatus());
    } catch (Throwable exception) {
      instrumentation.metric("Problem", "Exception launching " + exception.getClass().toString());
      instrumentation.data("Problem", "Exception launching " + exception.toString());

      DartUtil.logError(exception);

      DebugErrorHandler.errorDialog(
          window.getShell(),
          "Error Launching Application",
          exception.getMessage(),
          exception);
    }
  }

//  @Override
//  public void selectionChanged(IWorkbenchPart part, ISelection selection) {
//    setToolTipText("Run");
//
//    IResource resource = LaunchUtils.getSelectedResource(window);
//
//    if (resource != null) {
//      ILaunchConfiguration config = null;
//
//      try {
//        config = LaunchUtils.getLaunchFor(resource);
//      } catch (DartModelException e) {
//
//      }
//
//      if (config == null) {
//        config = LaunchUtils.chooseLatest(LaunchUtils.getAllLaunches());
//      }
//
//      if (config != null) {
//        setToolTipText(LaunchUtils.getLongLaunchName(config));
//      }
//    }
//  }

  protected void launchResource(IResource resource, InstrumentationBuilder instrumentation)
      throws DartModelException {
    ILaunchConfiguration config = LaunchUtils.getLaunchFor(resource);

    if (config != null) {
      launch(config, instrumentation);
    } else {
      List<ILaunchShortcut> candidates = LaunchUtils.getApplicableLaunchShortcuts(resource);

      if (candidates.size() == 0) {
        // Selection is neither a server or browser app.
        DartRunLastAction runLastAction = new DartRunLastAction();
        runLastAction.run();
      } else {
        ISelection sel = new StructuredSelection(resource);

        launch(candidates.get(0), sel, instrumentation);
      }
    }
  }

  private boolean chooseAndLaunch(List<ILaunchConfiguration> launches,
      InstrumentationBuilder instrumentation) {
    if (launches.size() == 0) {
      return false;
    } else if (launches.size() == 1) {
      launch(launches.get(0), instrumentation);

      return true;
    } else {
      ILaunchConfiguration config = LaunchUtils.chooseConfiguration(launches);

      if (config != null) {
        launch(config, instrumentation);

        return true;
      } else {
        instrumentation.metric("Problem", "Config was null");
        return false;
      }
    }
  }

}
