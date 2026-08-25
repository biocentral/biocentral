package com.biocentral.pycharm.ui;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.intellij.icons.AllIcons;
import com.intellij.openapi.application.ApplicationManager;
import com.intellij.openapi.diagnostic.Logger;
import com.intellij.openapi.fileChooser.FileChooserFactory;
import com.intellij.openapi.fileChooser.FileSaverDescriptor;
import com.intellij.openapi.fileChooser.FileSaverDialog;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.ui.Messages;
import com.intellij.openapi.vfs.VirtualFileWrapper;
import com.intellij.ui.ScrollPaneFactory;
import com.intellij.ui.components.JBLabel;
import com.intellij.ui.table.JBTable;
import com.intellij.util.ui.JBUI;

import javax.swing.BorderFactory;
import javax.swing.Box;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JToolBar;
import javax.swing.SwingConstants;
import javax.swing.table.DefaultTableModel;
import java.awt.BorderLayout;
import java.awt.Font;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

/**
 * Table view of computed embeddings: seq_id | shape | preview (first values).
 *
 * <p>The full embeddings live in a separate JSON file (produced by the embed
 * script) — we keep the tool window responsive by only showing the shape and a
 * preview of the first values per sequence, and provide a save button so the
 * user can persist the raw data elsewhere.
 */
public final class EmbeddingsPanel {

    private static final Logger LOG = Logger.getInstance(EmbeddingsPanel.class);

    private final JPanel root;
    private final JToolBar toolbar;
    private final DefaultTableModel model;
    private final JBTable table;
    private final JLabel summary;
    private final JButton saveButton;

    private Path resultsFile;

    public EmbeddingsPanel() {
        this.root = new JPanel(new BorderLayout());
        root.setBorder(JBUI.Borders.empty());

        this.summary = new JBLabel(" ");
        summary.setFont(summary.getFont().deriveFont(Font.PLAIN, 12f));
        summary.setBorder(BorderFactory.createEmptyBorder(6, 8, 6, 8));

        this.toolbar = new JToolBar();
        toolbar.setFloatable(false);
        toolbar.add(summary);
        toolbar.add(Box.createHorizontalGlue());
        this.saveButton = new JButton("Save embeddings as JSON...", AllIcons.Actions.MenuSaveall);
        saveButton.setEnabled(false);
        saveButton.addActionListener(e -> saveAs());
        toolbar.add(saveButton);

        this.model = new DefaultTableModel(new Object[]{"seq_id", "shape", "preview"}, 0) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };
        this.table = new JBTable(model);
        table.setShowGrid(false);
        table.setRowHeight(22);

        JLabel placeholder = new JBLabel(
                "<html><div style='padding:24px; color:#888;'>"
                        + "No embeddings computed yet.<br/>"
                        + "Right-click a <code>.fasta</code> file and select <b>Embed Sequences...</b>."
                        + "</div></html>",
                SwingConstants.CENTER);
        placeholder.setBorder(BorderFactory.createEmptyBorder(32, 16, 32, 16));

        root.add(toolbar, BorderLayout.NORTH);
        root.add(placeholder, BorderLayout.CENTER);
    }

    public JComponent getComponent() {
        return root;
    }

    /** Show the results contained in the given JSON file produced by embed_fasta.py. */
    public void showResults(Path jsonPath, Project project) {
        ApplicationManager.getApplication().invokeLater(() -> doShow(jsonPath, project));
    }

    private void doShow(Path jsonPath, Project project) {
        try {
            String raw = Files.readString(jsonPath, StandardCharsets.UTF_8);
            JsonObject payload = JsonParser.parseString(raw).getAsJsonObject();

            model.setRowCount(0);
            JsonArray entries = payload.getAsJsonArray("entries");
            for (JsonElement el : entries) {
                JsonObject entry = el.getAsJsonObject();
                String seqId = entry.get("seq_id").getAsString();
                String shape = entry.get("shape").toString();
                String preview = previewOf(entry.get("embedding"));
                model.addRow(new Object[]{seqId, shape, preview});
            }

            String embedder = payload.has("embedder") ? payload.get("embedder").getAsString() : "?";
            String mode = payload.has("mode") ? payload.get("mode").getAsString() : "?";
            summary.setText(String.format(" %d sequences  |  embedder=%s  |  mode=%s",
                    entries.size(), embedder, mode));

            this.resultsFile = jsonPath;
            saveButton.setEnabled(true);

            root.removeAll();
            root.add(toolbar, BorderLayout.NORTH);
            root.add(ScrollPaneFactory.createScrollPane(table), BorderLayout.CENTER);
            root.revalidate();
            root.repaint();
        } catch (Exception e) {
            LOG.warn("Failed to load embeddings JSON", e);
            if (project != null) {
                Messages.showErrorDialog(project,
                        "Failed to load embeddings: " + e.getMessage(),
                        "Biocentral");
            }
        }
    }

    private static String previewOf(JsonElement el) {
        if (el == null || el.isJsonNull()) {
            return "(none)";
        }
        JsonElement cur = el;
        while (cur.isJsonArray() && !cur.getAsJsonArray().isEmpty()
                && cur.getAsJsonArray().get(0).isJsonArray()) {
            cur = cur.getAsJsonArray().get(0);
        }
        if (!cur.isJsonArray()) {
            return cur.toString();
        }
        JsonArray a = cur.getAsJsonArray();
        int n = Math.min(6, a.size());
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < n; i++) {
            if (i > 0) sb.append(", ");
            sb.append(formatNumber(a.get(i)));
        }
        if (a.size() > n) sb.append(", ...");
        sb.append("]");
        return sb.toString();
    }

    private static String formatNumber(JsonElement el) {
        try {
            double v = el.getAsDouble();
            return String.format("%.4f", v);
        } catch (RuntimeException e) {
            return el.toString();
        }
    }

    private void saveAs() {
        if (resultsFile == null) return;
        FileSaverDescriptor descriptor = new FileSaverDescriptor(
                "Save Embeddings", "Write the raw embedding JSON to disk", "json");
        FileSaverDialog dialog = FileChooserFactory.getInstance().createSaveFileDialog(descriptor, root);
        VirtualFileWrapper wrapper = dialog.save((Path) null, "embeddings.json");
        if (wrapper == null) return;
        try {
            Files.copy(resultsFile, Paths.get(wrapper.getFile().getPath()), StandardCopyOption.REPLACE_EXISTING);
        } catch (Exception e) {
            LOG.warn(e);
        }
    }
}
