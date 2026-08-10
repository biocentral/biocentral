package com.biocentral.pycharm.python;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.intellij.execution.ExecutionException;
import com.intellij.execution.configurations.GeneralCommandLine;
import com.intellij.execution.process.CapturingProcessHandler;
import com.intellij.execution.process.ProcessOutput;
import com.intellij.openapi.diagnostic.Logger;
import com.intellij.openapi.progress.ProgressIndicator;
import com.intellij.openapi.progress.ProgressManager;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.projectRoots.Sdk;
import com.intellij.openapi.roots.ProjectRootManager;
import com.jetbrains.python.sdk.PythonSdkUtil;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

/**
 * Runs bundled Biocentral scripts through the project's configured Python SDK.
 *
 * <p>We ask the Python plugin for the project's SDK ({@link PythonSdkUtil}) rather
 * than hardcoding an interpreter path so the plugin transparently picks up
 * whichever interpreter the user has configured — including virtualenvs, conda,
 * poetry, and PyCharm's targets/remote interpreters.
 *
 * <p>The execution itself uses {@link GeneralCommandLine}, IntelliJ's canonical
 * command-line abstraction. This is the same mechanism the Python plugin uses
 * internally for one-shot script invocations, so we inherit its environment
 * setup (PATH augmentation, venv activation via the interpreter binary, ...)
 * without reimplementing it.
 */
public final class BiocentralPythonRunner {

    private static final Logger LOG = Logger.getInstance(BiocentralPythonRunner.class);

    private final @NotNull Project project;

    public BiocentralPythonRunner(@NotNull Project project) {
        this.project = project;
    }

    /** @return the interpreter path or {@code null} if no Python SDK is configured. */
    public @Nullable String resolveInterpreterPath() {
        Sdk sdk = ProjectRootManager.getInstance(project).getProjectSdk();
        if (sdk == null || !PythonSdkUtil.isPythonSdk(sdk)) {
            return null;
        }
        String home = sdk.getHomePath();
        return (home == null || home.isBlank()) ? null : home;
    }

    /**
     * Execute {@code scriptName} (bundled in the plugin's <code>scripts/</code>
     * resource folder) with the given arguments and return its result.
     */
    public @NotNull ScriptResult run(@NotNull String scriptName, @NotNull List<String> args) {
        String interpreter = resolveInterpreterPath();
        if (interpreter == null) {
            return new ScriptResult(false, null, "",
                    "No Python SDK configured. Configure one in Settings | Project | Python Interpreter.",
                    -1);
        }

        Path scriptPath;
        try {
            scriptPath = BiocentralScripts.scriptPath(scriptName);
        } catch (IOException e) {
            LOG.warn("Failed to extract Biocentral script", e);
            return new ScriptResult(false, null, "", "Failed to prepare script: " + e.getMessage(), -1);
        }

        GeneralCommandLine cmd = new GeneralCommandLine(interpreter, scriptPath.toString());
        cmd.addParameters(args);
        cmd.setCharset(StandardCharsets.UTF_8);
        String base = project.getBasePath();
        if (base != null) {
            cmd.setWorkDirectory(base);
        }
        cmd.getEnvironment().put("PYTHONUNBUFFERED", "1");
        cmd.getEnvironment().put("PYTHONIOENCODING", "utf-8");

        CapturingProcessHandler handler;
        try {
            handler = new CapturingProcessHandler(cmd);
        } catch (ExecutionException e) {
            LOG.warn("Failed to start Python process", e);
            return new ScriptResult(false, null, "", "Failed to start Python: " + e.getMessage(), -1);
        }

        ProgressIndicator indicator = ProgressManager.getInstance().getProgressIndicator();
        ProcessOutput output = indicator != null
                ? handler.runProcessWithProgressIndicator(indicator)
                : handler.runProcess();

        return parseResult(output);
    }

    private static @NotNull ScriptResult parseResult(@NotNull ProcessOutput output) {
        String stdout = output.getStdout();
        String stderr = output.getStderr();

        JsonObject envelope = extractEnvelope(stdout);
        boolean ok = envelope != null
                && envelope.has("ok")
                && envelope.get("ok").getAsBoolean()
                && output.getExitCode() == 0;
        return new ScriptResult(ok, envelope, stdout, stderr, output.getExitCode());
    }

    private static @Nullable JsonObject extractEnvelope(@NotNull String stdout) {
        // Scan from the end: scripts may emit unrelated stdout (tqdm bars, ...)
        // before their final envelope line.
        int idx = stdout.lastIndexOf(ScriptResult.MARKER);
        if (idx < 0) {
            return null;
        }
        int start = idx + ScriptResult.MARKER.length();
        int end = stdout.indexOf('\n', start);
        String payload = end < 0 ? stdout.substring(start) : stdout.substring(start, end);
        try {
            return JsonParser.parseString(payload.trim()).getAsJsonObject();
        } catch (RuntimeException e) {
            LOG.warn("Malformed Biocentral envelope: " + payload, e);
            return null;
        }
    }

    /** True if a usable Python SDK is present. Cheap; safe to call from actions. */
    public boolean hasPythonSdk() {
        return resolveInterpreterPath() != null;
    }

    /**
     * Writes {@code content} to a temp file with the given suffix. Used by callers
     * that need to hand data to a script via a file rather than argv.
     */
    public static Path writeTempFile(@NotNull String content, @NotNull String suffix) throws IOException {
        Path tmp = Files.createTempFile("biocentral-", suffix);
        Files.writeString(tmp, content, StandardCharsets.UTF_8);
        return tmp;
    }
}
