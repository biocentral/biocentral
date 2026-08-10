package com.biocentral.pycharm.ui;

import com.intellij.openapi.project.Project;
import com.intellij.openapi.wm.ToolWindow;
import com.intellij.openapi.wm.ToolWindowFactory;
import com.intellij.ui.content.Content;
import com.intellij.ui.content.ContentFactory;
import org.jetbrains.annotations.NotNull;

/**
 * Registers a "Biocentral" tool window with two tabs:
 * <ul>
 *     <li>Charts — HTML preview of {@code BiocentralChart} output rendered via JCEF.</li>
 *     <li>Embeddings — tabular summary of {@code Biocentral.embed()} output.</li>
 * </ul>
 */
public final class BiocentralToolWindowFactory implements ToolWindowFactory {

    @Override
    public void createToolWindowContent(@NotNull Project project, @NotNull ToolWindow toolWindow) {
        ContentFactory factory = ContentFactory.getInstance();

        ChartPanel chartPanel = BiocentralToolWindowService.get(project).getChartPanel();
        Content chartContent = factory.createContent(chartPanel.getComponent(), "Charts", false);
        chartContent.setCloseable(false);
        toolWindow.getContentManager().addContent(chartContent);

        EmbeddingsPanel embeddingsPanel = BiocentralToolWindowService.get(project).getEmbeddingsPanel();
        Content embeddingsContent = factory.createContent(embeddingsPanel.getComponent(), "Embeddings", false);
        embeddingsContent.setCloseable(false);
        toolWindow.getContentManager().addContent(embeddingsContent);
    }

    @Override
    public boolean shouldBeAvailable(@NotNull Project project) {
        return true;
    }
}
