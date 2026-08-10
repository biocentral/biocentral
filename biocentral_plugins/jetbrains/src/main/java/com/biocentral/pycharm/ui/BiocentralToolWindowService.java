package com.biocentral.pycharm.ui;

import com.intellij.openapi.application.ApplicationManager;
import com.intellij.openapi.components.Service;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.wm.ToolWindow;
import com.intellij.openapi.wm.ToolWindowManager;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

/**
 * Project-scoped holder for the tool-window panels so actions can push new
 * content into them without going through the ToolWindow lifecycle.
 *
 * <p>Panels are constructed lazily (on the EDT) the first time they're asked for.
 * Actions call {@link #activate()} to bring the tool window forward after pushing
 * new content.
 */
@Service(Service.Level.PROJECT)
public final class BiocentralToolWindowService {

    public static final String TOOL_WINDOW_ID = "Biocentral";

    private final Project project;
    private volatile @Nullable ChartPanel chartPanel;
    private volatile @Nullable EmbeddingsPanel embeddingsPanel;

    public BiocentralToolWindowService(@NotNull Project project) {
        this.project = project;
    }

    public static BiocentralToolWindowService get(@NotNull Project project) {
        return project.getService(BiocentralToolWindowService.class);
    }

    public synchronized @NotNull ChartPanel getChartPanel() {
        ChartPanel p = chartPanel;
        if (p == null) {
            p = new ChartPanel();
            chartPanel = p;
        }
        return p;
    }

    public synchronized @NotNull EmbeddingsPanel getEmbeddingsPanel() {
        EmbeddingsPanel p = embeddingsPanel;
        if (p == null) {
            p = new EmbeddingsPanel();
            embeddingsPanel = p;
        }
        return p;
    }

    public void activate() {
        ApplicationManager.getApplication().invokeLater(() -> {
            ToolWindow tw = ToolWindowManager.getInstance(project).getToolWindow(TOOL_WINDOW_ID);
            if (tw != null) {
                tw.activate(null, true);
            }
        });
    }

    public void selectChartTab() {
        ApplicationManager.getApplication().invokeLater(() -> {
            ToolWindow tw = ToolWindowManager.getInstance(project).getToolWindow(TOOL_WINDOW_ID);
            if (tw == null) return;
            for (var content : tw.getContentManager().getContents()) {
                if ("Charts".equals(content.getDisplayName())) {
                    tw.getContentManager().setSelectedContent(content);
                    break;
                }
            }
            tw.activate(null, true);
        });
    }

    public void selectEmbeddingsTab() {
        ApplicationManager.getApplication().invokeLater(() -> {
            ToolWindow tw = ToolWindowManager.getInstance(project).getToolWindow(TOOL_WINDOW_ID);
            if (tw == null) return;
            for (var content : tw.getContentManager().getContents()) {
                if ("Embeddings".equals(content.getDisplayName())) {
                    tw.getContentManager().setSelectedContent(content);
                    break;
                }
            }
            tw.activate(null, true);
        });
    }
}
