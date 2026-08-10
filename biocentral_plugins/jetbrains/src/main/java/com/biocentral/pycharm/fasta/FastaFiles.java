package com.biocentral.pycharm.fasta;

import com.intellij.openapi.vfs.VirtualFile;
import org.jetbrains.annotations.Nullable;

import java.util.Set;

public final class FastaFiles {

    private static final Set<String> EXTENSIONS = Set.of("fasta", "fa", "faa", "fna");

    private FastaFiles() {
    }

    /**
     * Non-strict recognition based on extension. Uses lowercased extension so
     * arbitrary casing (e.g. {@code .FASTA}) still matches.
     */
    public static boolean isFasta(@Nullable VirtualFile file) {
        if (file == null || file.isDirectory()) {
            return false;
        }
        String ext = file.getExtension();
        if (ext == null) {
            return false;
        }
        return EXTENSIONS.contains(ext.toLowerCase());
    }
}
