package com.biocentral.pycharm.ui;

import com.intellij.openapi.application.ApplicationManager;
import com.intellij.openapi.diagnostic.Logger;
import com.intellij.ui.jcef.JBCefApp;
import com.intellij.ui.jcef.JBCefBrowser;
import com.intellij.util.ui.JBUI;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.JComponent;
import javax.swing.JEditorPane;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.SwingConstants;
import java.awt.BorderLayout;
import java.awt.Desktop;
import java.awt.Font;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Chart tab of the Biocentral tool window. Displays saved Altair charts as HTML
 * in an embedded JCEF browser when available, or falls back to an
 * openable-in-external-browser label when JCEF is unavailable (e.g. headless
 * JBRE, remote dev host without JCEF).
 */
public final class ChartPanel {

    private static final Logger LOG = Logger.getInstance(ChartPanel.class);

    private final JPanel root;
    private final @org.jetbrains.annotations.Nullable JBCefBrowser browser;
    private final JLabel placeholder;

    public ChartPanel() {
        this.root = new JPanel(new BorderLayout());
        this.placeholder = new JLabel(
                "<html><div style='padding:24px; color:#888;'>"
                        + "No chart rendered yet.<br/>"
                        + "Open a <code>.fasta</code> file and pick a chart from the editor banner."
                        + "</div></html>",
                SwingConstants.CENTER);
        placeholder.setFont(placeholder.getFont().deriveFont(Font.PLAIN, 13f));

        if (JBCefApp.isSupported()) {
            this.browser = new JBCefBrowser();
        } else {
            this.browser = null;
            LOG.warn("JCEF is not available; falling back to plain-text chart preview.");
        }

        root.setBorder(JBUI.Borders.empty());
        root.add(placeholder, BorderLayout.CENTER);
    }

    public JComponent getComponent() {
        return root;
    }

    /**
     * Load the given HTML file into the browser. Called from the EDT (or dispatches
     * to it) and swaps out any placeholder / previous browser instance.
     */
    public void showHtml(Path htmlPath) {
        ApplicationManager.getApplication().invokeLater(() -> doShowHtml(htmlPath));
    }

    private void doShowHtml(Path htmlPath) {
        root.removeAll();

        if (browser != null) {
            try {
                // JCEF prefers URIs, but a plain file path works too. We use toUri()
                // so the "file://" scheme is applied consistently across OSes.
                browser.loadURL(htmlPath.toUri().toString());
                root.add(browser.getComponent(), BorderLayout.CENTER);
            } catch (RuntimeException e) {
                LOG.warn("Failed to load chart in JCEF; falling back to text preview.", e);
                root.add(fallbackPanel(htmlPath), BorderLayout.CENTER);
            }
        } else {
            root.add(fallbackPanel(htmlPath), BorderLayout.CENTER);
        }

        root.revalidate();
        root.repaint();
    }

    private JComponent fallbackPanel(Path htmlPath) {
        JPanel p = new JPanel();
        p.setLayout(new BoxLayout(p, BoxLayout.Y_AXIS));
        p.setBorder(BorderFactory.createEmptyBorder(16, 16, 16, 16));

        JEditorPane info = new JEditorPane("text/html",
                "<html><b>JCEF preview unavailable.</b><br/>"
                        + "Chart saved to:<br/><tt>" + htmlPath + "</tt></html>");
        info.setEditable(false);
        info.setOpaque(false);
        info.addHyperlinkListener(e -> {
            if (Desktop.isDesktopSupported()) {
                try {
                    Desktop.getDesktop().browse(htmlPath.toUri());
                } catch (IOException ioe) {
                    LOG.warn(ioe);
                }
            }
        });
        p.add(info);

        try {
            String preview = new String(Files.readAllBytes(htmlPath), StandardCharsets.UTF_8);
            if (preview.length() > 4096) {
                preview = preview.substring(0, 4096) + "\n...";
            }
            JEditorPane raw = new JEditorPane("text/plain", preview);
            raw.setEditable(false);
            p.add(raw);
        } catch (IOException e) {
            LOG.warn(e);
        }
        return p;
    }
}
