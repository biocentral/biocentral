package com.biocentral.pycharm.actions;

import com.biocentral.pycharm.fasta.FastaFiles;
import com.biocentral.pycharm.python.BiocentralPythonRunner;
import com.biocentral.pycharm.python.BiocentralScripts;
import com.biocentral.pycharm.python.ScriptResult;
import com.biocentral.pycharm.ui.BiocentralToolWindowService;
import com.intellij.notification.NotificationGroupManager;
import com.intellij.notification.NotificationType;
import com.intellij.openapi.actionSystem.ActionUpdateThread;
import com.intellij.openapi.actionSystem.AnAction;
import com.intellij.openapi.actionSystem.AnActionEvent;
import com.intellij.openapi.actionSystem.CommonDataKeys;
import com.intellij.openapi.progress.ProgressIndicator;
import com.intellij.openapi.progress.ProgressManager;
import com.intellij.openapi.progress.Task;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.vfs.VirtualFile;
import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

/**
 * Renders every BiocentralChart the plugin knows about into a single stacked
 * HTML page and displays it in the Biocentral tool window.
 *
 * <p>Individual chart failures don't sink the whole run — the Python side
 * emits whichever charts it could produce and reports the failures in the
 * envelope's {@code failed} field.
 */
public final class VisualizeAction extends AnAction {

    @Override
    public @NotNull ActionUpdateThread getActionUpdateThread() {
        return ActionUpdateThread.BGT;
    }

    @Override
    public void update(@NotNull AnActionEvent e) {
        VirtualFile file = e.getData(CommonDataKeys.VIRTUAL_FILE);
        e.getPresentation().setEnabledAndVisible(
                e.getProject() != null && FastaFiles.isFasta(file));
    }

    @Override
    public void actionPerformed(@NotNull AnActionEvent e) {
        Project project = e.getProject();
        VirtualFile file = e.getData(CommonDataKeys.VIRTUAL_FILE);
        if (project == null || !FastaFiles.isFasta(file)) {
            return;
        }
        BiocentralPythonRunner runner = new BiocentralPythonRunner(project);
        if (!runner.hasPythonSdk()) {
            showNotification(project, NotificationType.WARNING,
                    "No Python SDK configured for this project. "
                            + "Configure one in Settings | Project | Python Interpreter.");
            return;
        }

        Path htmlOut;
        try {
            htmlOut = Files.createTempFile("biocentral-charts-", ".html");
        } catch (IOException ex) {
            showNotification(project, NotificationType.ERROR,
                    "Could not create temp file: " + ex.getMessage());
            return;
        }

        ProgressManager.getInstance().run(new Task.Backgroundable(project,
                "Rendering Biocentral charts", true) {
            @Override
            public void run(@NotNull ProgressIndicator indicator) {
                indicator.setIndeterminate(true);
                // No --chart-type args => the script renders every known chart.
                List<String> args = List.of(
                        "--fasta", file.getPath(),
                        "--out", htmlOut.toString()
                );
                ScriptResult result = runner.run(BiocentralScripts.RENDER_CHART, args);
                if (result.isOk()) {
                    BiocentralToolWindowService svc = BiocentralToolWindowService.get(project);
                    svc.getChartPanel().showHtml(htmlOut);
                    svc.selectChartTab();

                    // Surface partial failures so the user knows charts were skipped.
                    if (result.getEnvelope() != null
                            && result.getEnvelope().has("failed")
                            && result.getEnvelope().getAsJsonArray("failed").size() > 0) {
                        showNotification(project, NotificationType.WARNING,
                                "Some charts could not be rendered: "
                                        + result.getEnvelope().get("failed"));
                    }
                } else {
                    showNotification(project, NotificationType.ERROR,
                            "Chart rendering failed: " + result.describeError());
                }
            }
        });
    }

    private static void showNotification(@NotNull Project project,
                                         @NotNull NotificationType type,
                                         @NotNull String msg) {
        NotificationGroupManager.getInstance()
                .getNotificationGroup("Biocentral")
                .createNotification(msg, type)
                .notify(project);
    }
}
