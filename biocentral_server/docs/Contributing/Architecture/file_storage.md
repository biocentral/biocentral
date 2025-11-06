# File Storage Concept

```text
Base Directory -> User ID -> Database Hash
storage/
 +- user_id/
    |   +- models/ (Here go all trained models)
        |   +- model_hash_1/ (Model 1)
            |   +- CNN/ (model_choice in biotrainer)
                |   +- one_hot_encoding/ (embedder_name in biotrainer, all checkpoints are found here.)
                    |   +- hold_out_checkpoint.pt (Name depends on cross_validation method)
            |   +- logger_out.log (Logging output from biotrainer)
            |   +- out.yml (Result file from biotrainer)
            |   +- config_file.yml (Config file for biotrainer)
```

## List of required files and types for functions and output files

* Biotrainer - Model Training:
  * Input: Sequence file, Label file, Mask file (fasta files), Config file (.yaml/dict)
  * Output: out.yml, logger_out.log, embeddings as .h5 file, checkpoints as .pt file(s)
