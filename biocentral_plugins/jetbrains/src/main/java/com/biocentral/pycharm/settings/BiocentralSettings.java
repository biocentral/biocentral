package com.biocentral.pycharm.settings;

import com.intellij.openapi.components.PersistentStateComponent;
import com.intellij.openapi.components.Service;
import com.intellij.openapi.components.State;
import com.intellij.openapi.components.Storage;
import com.intellij.openapi.project.Project;
import com.intellij.util.xmlb.XmlSerializerUtil;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

/**
 * Project-level persistent settings for the Biocentral plugin.
 *
 * <p>Stored in <code>.idea/biocentral.xml</code> alongside other project state so
 * per-project preferences (embedder name, backend URL) travel with the repository
 * checkout.
 */
@Service(Service.Level.PROJECT)
@State(name = "BiocentralSettings", storages = @Storage("biocentral.xml"))
public final class BiocentralSettings implements PersistentStateComponent<BiocentralSettings.State> {

    public static final class State {
        public String embedderName = "one_hot_encoding";
        public String mode = "api";
        public String apiUrl = "";
        public String device = "";
        public boolean reduce = true;
        public boolean halfPrecision = false;
    }

    private State state = new State();

    public static BiocentralSettings get(@NotNull Project project) {
        return project.getService(BiocentralSettings.class);
    }

    @Override
    public @Nullable State getState() {
        return state;
    }

    @Override
    public void loadState(@NotNull State loaded) {
        XmlSerializerUtil.copyBean(loaded, this.state);
    }

    // Convenience accessors — keeps call sites tidy and lets us evolve storage
    // without rewriting the whole plugin.

    public String getEmbedderName() {
        return state.embedderName;
    }

    public void setEmbedderName(String value) {
        state.embedderName = value;
    }

    public String getMode() {
        return state.mode;
    }

    public void setMode(String value) {
        state.mode = value;
    }

    public String getApiUrl() {
        return state.apiUrl;
    }

    public void setApiUrl(String value) {
        state.apiUrl = value;
    }

    public String getDevice() {
        return state.device;
    }

    public void setDevice(String value) {
        state.device = value;
    }

    public boolean isReduce() {
        return state.reduce;
    }

    public void setReduce(boolean value) {
        state.reduce = value;
    }

    public boolean isHalfPrecision() {
        return state.halfPrecision;
    }

    public void setHalfPrecision(boolean value) {
        state.halfPrecision = value;
    }
}
