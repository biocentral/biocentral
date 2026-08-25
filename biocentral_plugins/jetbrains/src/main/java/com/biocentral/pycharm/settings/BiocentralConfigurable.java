package com.biocentral.pycharm.settings;

import com.intellij.openapi.options.Configurable;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.ui.ComboBox;
import com.intellij.ui.components.JBCheckBox;
import com.intellij.ui.components.JBLabel;
import com.intellij.ui.components.JBTextField;
import com.intellij.util.ui.FormBuilder;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nls;
import org.jetbrains.annotations.Nullable;

import javax.swing.JComponent;
import javax.swing.JPanel;
import java.util.Objects;

/** Settings UI at File | Settings | Tools | Biocentral. */
public final class BiocentralConfigurable implements Configurable {

    private final Project project;

    private JBTextField embedderField;
    private ComboBox<String> modeCombo;
    private JBTextField apiUrlField;
    private JBTextField deviceField;
    private JBCheckBox reduceCheckbox;
    private JBCheckBox halfPrecisionCheckbox;

    public BiocentralConfigurable(@NotNull Project project) {
        this.project = project;
    }

    @Override
    public @Nls(capitalization = Nls.Capitalization.Title) String getDisplayName() {
        return "Biocentral";
    }

    @Override
    public @Nullable JComponent createComponent() {
        embedderField = new JBTextField();
        modeCombo = new ComboBox<>(new String[]{"api", "local"});
        apiUrlField = new JBTextField();
        deviceField = new JBTextField();
        reduceCheckbox = new JBCheckBox("Reduce embeddings to per-sequence");
        halfPrecisionCheckbox = new JBCheckBox("Use half precision");

        JPanel panel = FormBuilder.createFormBuilder()
                .addLabeledComponent(new JBLabel("Default embedder:"), embedderField, 1, false)
                .addLabeledComponent(new JBLabel("Execution mode:"), modeCombo, 1, false)
                .addLabeledComponent(new JBLabel("Custom API URL:"), apiUrlField, 1, false)
                .addLabeledComponent(new JBLabel("Device (local mode):"), deviceField, 1, false)
                .addComponent(reduceCheckbox, 1)
                .addComponent(halfPrecisionCheckbox, 1)
                .addComponentFillVertically(new JPanel(), 0)
                .getPanel();

        reset();
        return panel;
    }

    @Override
    public boolean isModified() {
        BiocentralSettings s = BiocentralSettings.get(project);
        return !Objects.equals(s.getEmbedderName(), embedderField.getText())
                || !Objects.equals(s.getMode(), modeCombo.getItem())
                || !Objects.equals(s.getApiUrl(), apiUrlField.getText())
                || !Objects.equals(s.getDevice(), deviceField.getText())
                || s.isReduce() != reduceCheckbox.isSelected()
                || s.isHalfPrecision() != halfPrecisionCheckbox.isSelected();
    }

    @Override
    public void apply() {
        BiocentralSettings s = BiocentralSettings.get(project);
        s.setEmbedderName(embedderField.getText().trim());
        s.setMode(Objects.requireNonNullElse(modeCombo.getItem(), "api"));
        s.setApiUrl(apiUrlField.getText().trim());
        s.setDevice(deviceField.getText().trim());
        s.setReduce(reduceCheckbox.isSelected());
        s.setHalfPrecision(halfPrecisionCheckbox.isSelected());
    }

    @Override
    public void reset() {
        BiocentralSettings s = BiocentralSettings.get(project);
        embedderField.setText(s.getEmbedderName());
        modeCombo.setSelectedItem(s.getMode());
        apiUrlField.setText(s.getApiUrl());
        deviceField.setText(s.getDevice());
        reduceCheckbox.setSelected(s.isReduce());
        halfPrecisionCheckbox.setSelected(s.isHalfPrecision());
    }
}
