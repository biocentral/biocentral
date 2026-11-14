from biocentral import Biocentral

bc = Biocentral(mode="api")
pseudoperplexity = bc.perplexity(sequence_data={"Seq1": "MQPLLLHHHH"},
                                   plm_name="facebook/esm2_t6_8M_UR50D")

print(pseudoperplexity)
