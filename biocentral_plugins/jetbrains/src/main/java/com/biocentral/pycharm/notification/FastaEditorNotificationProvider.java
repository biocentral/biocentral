package com.biocentral.pycharm.notification;

import com.biocentral.pycharm.fasta.FastaFiles;
import com.intellij.openapi.actionSystem.ActionManager;
import com.intellij.openapi.actionSystem.ActionPlaces;
import com.intellij.openapi.actionSystem.AnAction;
import com.intellij.openapi.actionSystem.AnActionEvent;
import com.intellij.openapi.actionSystem.CommonDataKeys;
import com.intellij.openapi.actionSystem.DataContext;
import com.intellij.openapi.actionSystem.impl.SimpleDataContext;
import com.intellij.openapi.fileEditor.FileEditor;
import com.intellij.openapi.options.ShowSettingsUtil;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.vfs.VirtualFile;
import com.intellij.ui.EditorNotificationPanel;
import com.intellij.ui.EditorNotificationProvider;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import javax.swing.JComponent;
import java.util.function.Function;

/**
 * Displays a compact banner at the top of every {@code .fasta} editor with
 * one-click access to the plugin's actions.
 *
 * <p>Actions are looked up by ID from {@link ActionManager} and dispatched with
 * a synthetic {@link AnActionEvent}, so the banner, editor context menu and any
 * key bindings all share the same implementation.
 */
public final class FastaEditorNotificationProvider implements EditorNotificationProvider {

    private static final String[] BANNER_ACTIONS = {
            "Biocentral.Visualize",
            "Biocentral.EmbedFasta",
    };

    @Override
    public @Nullable Function<? super FileEditor, ? extends JComponent> collectNotificationData(
            @NotNull Project project, @NotNull VirtualFile file) {
        if (!FastaFiles.isFasta(file)) {
            return null;
        }
        return editor -> buildPanel(project, file, editor);
    }

    private JComponent buildPanel(@NotNull Project project,
                                  @NotNull VirtualFile file,
                                  @NotNull FileEditor editor) {
        EditorNotificationPanel panel = new EditorNotificationPanel(editor,
                EditorNotificationPanel.Status.Info);
        panel.setText("Biocentral: recognized FASTA (" + file.getName() + ")");

        ActionManager am = ActionManager.getInstance();
        DataContext ctx = SimpleDataContext.builder()
                .add(CommonDataKeys.PROJECT, project)
                .add(CommonDataKeys.VIRTUAL_FILE, file)
                .build();

        for (String actionId : BANNER_ACTIONS) {
            AnAction action = am.getAction(actionId);
            if (action == null) continue;
            String templateText = action.getTemplateText();
            String label = (templateText == null || templateText.isBlank()) ? actionId : templateText;
            panel.createActionLabel(label, () -> {
                AnActionEvent event = AnActionEvent.createFromDataContext(
                        ActionPlaces.EDITOR_TOOLBAR,
                        action.getTemplatePresentation().clone(),
                        ctx);
                action.actionPerformed(event);
            });
        }

        panel.createActionLabel("Settings...", () ->
                ShowSettingsUtil.getInstance().showSettingsDialog(project, "Biocentral"));

        return panel;
    }
}
