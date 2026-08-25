package com.biocentral.pycharm.ui;

import com.biocentral.pycharm.settings.BiocentralSettings;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.ui.ComboBox;
import com.intellij.openapi.ui.DialogWrapper;
import com.intellij.ui.components.JBCheckBox;
import com.intellij.ui.components.JBLabel;
import com.intellij.ui.components.JBTextField;
import com.intellij.util.ui.FormBuilder;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import javax.swing.JComponent;
import java.awt.Dimension;

/** Simple modal dialog to confirm embedding options before running the script. */
public final class EmbedOptionsDialog extends DialogWrapper {

    private final JBTextField embedderField;
    private final ComboBox<String> modeCombo;
    private final JBTextField apiUrlField;
    private final JBTextField deviceField;
    private final JBCheckBox reduceCheckbox;
    private final JBCheckBox halfPrecisionCheckbox;

    public EmbedOptionsDialog(@Nullable Project project, @NotNull BiocentralSettings settings) {
        super(project);
        this.embedderField = new JBTextField(settings.getEmbedderName());
        this.modeCombo = new ComboBox<>(new String[]{"api", "local"});
        this.modeCombo.setSelectedItem(settings.getMode());
        this.apiUrlField = new JBTextField(settings.getApiUrl());
        this.deviceField = new JBTextField(settings.getDevice());
        this.reduceCheckbox = new JBCheckBox("Reduce embeddings to per-sequence", settings.isReduce());
        this.halfPrecisionCheckbox = new JBCheckBox("Use half precision", settings.isHalfPrecision());

        setTitle("Embed FASTA Sequences");
        setOKButtonText("Embed");
        init();
    }

    @Override
    protected @Nullable JComponent createCenterPanel() {
        JComponent panel = FormBuilder.createFormBuilder()
                .addLabeledComponent(new JBLabel("Embedder name:"), embedderField, 1, false)
                .addLabeledComponent(new JBLabel("Execution mode:"), modeCombo, 1, false)
                .addLabeledComponent(new JBLabel("Custom API URL (api mode):"), apiUrlField, 1, false)
                .addLabeledComponent(new JBLabel("Device (local mode):"), deviceField, 1, false)
                .addComponent(reduceCheckbox, 1)
                .addComponent(halfPrecisionCheckbox, 1)
                .getPanel();
        panel.setPreferredSize(new Dimension(480, panel.getPreferredSize().height));
        return panel;
    }

    @Override
    protected @Nullable com.intellij.openapi.ui.ValidationInfo doValidate() {
        if (embedderField.getText().trim().isEmpty()) {
            return new com.intellij.openapi.ui.ValidationInfo(
                    "Embedder name is required.", embedderField);
        }
        return null;
    }

    /** Copy the current widget values back into the persistent settings. */
    public void persistTo(@NotNull BiocentralSettings settings) {
        settings.setEmbedderName(embedderField.getText().trim());
        Object mode = modeCombo.getSelectedItem();
        settings.setMode(mode == null ? "api" : mode.toString());
        settings.setApiUrl(apiUrlField.getText().trim());
        settings.setDevice(deviceField.getText().trim());
        settings.setReduce(reduceCheckbox.isSelected());
        settings.setHalfPrecision(halfPrecisionCheckbox.isSelected());
    }
}
