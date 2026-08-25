package com.biocentral.pycharm.fasta;

import com.biocentral.pycharm.ui.BiocentralIcons;
import com.intellij.openapi.fileTypes.LanguageFileType;
import com.intellij.openapi.fileTypes.PlainTextLanguage;
import org.jetbrains.annotations.NonNls;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import javax.swing.Icon;

/**
 * Registers <code>.fasta</code> / <code>.fa</code> / <code>.faa</code> / <code>.fna</code>
 * (and {@code .fastq}) files with the IDE.
 *
 * <p>We deliberately reuse {@link PlainTextLanguage} — FASTA is line-oriented and does
 * not warrant a custom lexer/parser for the features this plugin ships. Editor
 * decorations (notification banner, actions) hook off the file type, not the language.
 */
public final class FastaFileType extends LanguageFileType {

    public static final FastaFileType INSTANCE = new FastaFileType();

    private FastaFileType() {
        super(PlainTextLanguage.INSTANCE, true);
    }

    @Override
    public @NonNls @NotNull String getName() {
        return "FASTA";
    }

    @Override
    public @NotNull String getDescription() {
        return "FASTA sequence file";
    }

    @Override
    public @NotNull String getDefaultExtension() {
        return "fasta";
    }

    @Override
    public @Nullable Icon getIcon() {
        return BiocentralIcons.FASTA;
    }
}
