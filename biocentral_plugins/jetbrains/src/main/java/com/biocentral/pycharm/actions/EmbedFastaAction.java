package com.biocentral.pycharm.actions;

import com.biocentral.pycharm.fasta.FastaFiles;
import com.biocentral.pycharm.python.BiocentralPythonRunner;
import com.biocentral.pycharm.python.BiocentralScripts;
import com.biocentral.pycharm.python.ScriptResult;
import com.biocentral.pycharm.settings.BiocentralSettings;
import com.biocentral.pycharm.ui.BiocentralToolWindowService;
import com.biocentral.pycharm.ui.EmbedOptionsDialog;
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
import java.util.ArrayList;
import java.util.List;

/**
 * Computes embeddings for a FASTA file using {@code Biocentral().embed()}.
 *
 * <p>The action opens a small dialog to confirm the embedder / mode / options
 * (defaulted from {@link BiocentralSettings}), then runs the {@code embed_fasta.py}
 * helper in the background and pushes the results into the tool window.
 */
public final class EmbedFastaAction extends AnAction {

    @Override
    public @NotNull ActionUpdateThread getActionUpdateThread() {
        return ActionUpdateThread.BGT;
    }

    @Override
    public void update(@NotNull AnActionEvent e) {
        VirtualFile file = e.getData(CommonDataKeys.VIRTUAL_FILE);
        e.getPresentation().setEnabledAndVisible(e.getProject() != null && FastaFiles.isFasta(file));
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

        BiocentralSettings settings = BiocentralSettings.get(project);
        EmbedOptionsDialog dialog = new EmbedOptionsDialog(project, settings);
        if (!dialog.showAndGet()) {
            return;
        }
        dialog.persistTo(settings);

        Path jsonOut;
        try {
            jsonOut = Files.createTempFile("biocentral-embeddings-", ".json");
        } catch (IOException ex) {
            showNotification(project, NotificationType.ERROR, "Could not create temp file: " + ex.getMessage());
            return;
        }

        List<String> args = new ArrayList<>();
        args.add("--fasta");
        args.add(file.getPath());
        args.add("--embedder");
        args.add(settings.getEmbedderName());
        args.add("--mode");
        args.add(settings.getMode());
        if (!settings.getApiUrl().isBlank()) {
            args.add("--api-url");
            args.add(settings.getApiUrl());
        }
        if (!settings.getDevice().isBlank()) {
            args.add("--device");
            args.add(settings.getDevice());
        }
        if (!settings.isReduce()) {
            args.add("--no-reduce");
        }
        if (settings.isHalfPrecision()) {
            args.add("--half-precision");
        }
        args.add("--out");
        args.add(jsonOut.toString());

        ProgressManager.getInstance().run(new Task.Backgroundable(project,
                "Computing embeddings via Biocentral", true) {
            @Override
            public void run(@NotNull ProgressIndicator indicator) {
                indicator.setIndeterminate(true);
                ScriptResult result = runner.run(BiocentralScripts.EMBED_FASTA, args);
                if (result.isOk()) {
                    BiocentralToolWindowService svc = BiocentralToolWindowService.get(project);
                    svc.getEmbeddingsPanel().showResults(jsonOut, project);
                    svc.selectEmbeddingsTab();
                } else {
                    showNotification(project, NotificationType.ERROR,
                            "Embedding failed: " + result.describeError());
                }
            }
        });
    }

    private static void showNotification(@NotNull Project project, @NotNull NotificationType type, @NotNull String msg) {
        NotificationGroupManager.getInstance()
                .getNotificationGroup("Biocentral")
                .createNotification(msg, type)
                .notify(project);
    }
}
