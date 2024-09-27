# File Storage Concept

```text
Base Directory -> User ID -> Database Hash
storage/
 +- user_id/
 |   +- db_hash_proteins_1/ (Protein database 1)
    |   +- fasta_files/ (Here go all fasta files)
        |   +- sequences.fasta (Sequence file)
        |   +- labels.fasta (Labels file for residue_to_class)
        |   +- mask.fasta (Mask file for residue_to_class)
    |   +- embeddings/ (Here go all computed embedding files)
        |   +- reduced_embeddings_file_one_hot_encoding.h5/ ({reduced_}?embeddings_file_{embedder_name}.h5)
        |   +- embeddings_file_one_hot_encoding.h5/ (Non reduced embeddings)
    |   +- models/ (Here go all trained models)
        |   +- model_hash_1/ (Model 1)
            |   +- CNN/ (model_choice in biotrainer)
                |   +- one_hot_encoding/ (embedder_name in biotrainer, all checkpoints are found here.)
                    |   +- hold_out_checkpoint.pt (Name depends on cross_validation method)            
            |   +- logger_out.log (Logging output from biotrainer)
            |   +- out.yml (Result file from biotrainer)
            |   +- config_file.yml (Config file for biotrainer)
 |   +- db_hash_proteins_2/ (Protein database 2)
 |   +- db_hash_interactions_1/ (Interaction database 1)
```

## List of required files and types for functions and output files

* HVI-Toolkit - Dataset Tests: 
  * Input: Interaction database as fasta file
  * Output: Server: /, Client: Text data
* Embedding calculation
  * Input: Protein database as fasta file
  * Output: Server: .h5 file, Client: .json 
* Umap calculation - Proteins: 
  * Input: Per-sequence embeddings of proteins as json (via client) or h5 (on server)
  * Output: Server: /, Client: UMAP-coordinates
* Umap calculation - Interactions (TODO, wip):
  * Input: Concatenated/Multiplied embeddings of interacting proteins 
  * Output: Server: /, Client: UMAP-coordinates
* Biotrainer - Model Training:
  * Input: Sequence file, Label file, Mask file (fasta files), Config file (.yaml/dict)
  * Output: out.yml, logger_out.log, embeddings as .h5 file, checkpoints as .pt file(s)