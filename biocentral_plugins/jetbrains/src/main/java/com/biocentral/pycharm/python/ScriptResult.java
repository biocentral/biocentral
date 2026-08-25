package com.biocentral.pycharm.python;

import com.google.gson.JsonObject;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

/**
 * Structured result of a Biocentral helper script.
 *
 * <p>Scripts emit a JSON envelope prefixed with {@link #MARKER}; everything else on
 * stdout/stderr (tqdm progress bars, deprecation warnings, ...) is captured as the
 * raw log for diagnostics but ignored for control flow.
 */
public final class ScriptResult {

    public static final String MARKER = "__BIOCENTRAL_RESULT__";

    private final boolean ok;
    private final @Nullable JsonObject envelope;
    private final @NotNull String stdout;
    private final @NotNull String stderr;
    private final int exitCode;

    public ScriptResult(boolean ok,
                        @Nullable JsonObject envelope,
                        @NotNull String stdout,
                        @NotNull String stderr,
                        int exitCode) {
        this.ok = ok;
        this.envelope = envelope;
        this.stdout = stdout;
        this.stderr = stderr;
        this.exitCode = exitCode;
    }

    public boolean isOk() {
        return ok;
    }

    public @Nullable JsonObject getEnvelope() {
        return envelope;
    }

    public @NotNull String getStdout() {
        return stdout;
    }

    public @NotNull String getStderr() {
        return stderr;
    }

    public int getExitCode() {
        return exitCode;
    }

    /**
     * Best-effort error message: the {@code error.message} field from the envelope
     * when present, otherwise the last non-empty stderr line, otherwise a stock
     * "process exited with code N".
     */
    public @NotNull String describeError() {
        if (envelope != null && envelope.has("error")) {
            JsonObject err = envelope.getAsJsonObject("error");
            if (err.has("message")) {
                return err.get("message").getAsString();
            }
        }
        String[] lines = stderr.split("\\R");
        for (int i = lines.length - 1; i >= 0; i--) {
            if (!lines[i].isBlank()) {
                return lines[i].trim();
            }
        }
        return "Biocentral script exited with code " + exitCode;
    }
}
