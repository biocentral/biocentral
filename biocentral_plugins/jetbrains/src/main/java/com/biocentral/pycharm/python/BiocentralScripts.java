package com.biocentral.pycharm.python;

import com.intellij.openapi.diagnostic.Logger;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.List;

/**
 * Extracts bundled {@code .py} scripts from the plugin classpath onto disk so the
 * project's Python interpreter can execute them.
 *
 * <p>Scripts live in <code>src/main/resources/scripts/</code>. We extract all of
 * them into a single temp directory on first use so relative imports (e.g. every
 * script pulls helpers from <code>_bootstrap.py</code>) work without any
 * additional {@code PYTHONPATH} juggling on the Java side.
 */
public final class BiocentralScripts {

    private static final Logger LOG = Logger.getInstance(BiocentralScripts.class);

    /**
     * The complete set of scripts we ship. Kept here as an explicit list rather
     * than scanned dynamically so the build failing loudly (missing resource)
     * beats a silent runtime NPE.
     */
    private static final List<String> BUNDLED = List.of(
            "_bootstrap.py",
            "render_chart.py",
            "embed_fasta.py",
            "check_env.py"
    );

    public static final String RENDER_CHART = "render_chart.py";
    public static final String EMBED_FASTA = "embed_fasta.py";
    public static final String CHECK_ENV = "check_env.py";

    private static volatile Path scriptDir;

    private BiocentralScripts() {
    }

    /** Returns the on-disk directory containing all extracted scripts. */
    public static synchronized Path directory() throws IOException {
        Path dir = scriptDir;
        if (dir != null && Files.isDirectory(dir)) {
            return dir;
        }
        dir = Files.createTempDirectory("biocentral-plugin-scripts-");
        for (String name : BUNDLED) {
            copyResource(name, dir.resolve(name));
        }
        scriptDir = dir;
        LOG.info("Extracted Biocentral plugin scripts to " + dir);
        return dir;
    }

    public static Path scriptPath(String name) throws IOException {
        return directory().resolve(name);
    }

    private static void copyResource(String name, Path target) throws IOException {
        String resource = "/scripts/" + name;
        try (InputStream in = BiocentralScripts.class.getResourceAsStream(resource)) {
            if (in == null) {
                throw new IOException("Bundled script missing from plugin jar: " + resource);
            }
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        }
    }
}
