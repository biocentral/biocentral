import numpy as np
from biocentral import CommonEmbedder


def test_embed_equivalence_one_hot_reduced(bc_local, bc_api):
    sequence_data = {
        "Seq1": "MMALSLALM",
        "Seq2": "PRTEIN",
        "Seq3": "PRT",
        "Seq4": "SEQWENCE",
        "Seq5": "MMPRTEINSEQWENCE",
    }

    local_res = bc_local.embed(
        embedder_name=CommonEmbedder.ONE_HOT_ENCODING,
        sequence_data=sequence_data,
        reduce=True,
    )
    api_res = bc_api.embed(
        embedder_name=CommonEmbedder.ONE_HOT_ENCODING,
        sequence_data=sequence_data,
        reduce=True,
    )

    local_dict = local_res.to_dict()
    api_dict = api_res.to_dict()

    assert set(local_dict.keys()) == set(sequence_data.keys())
    assert set(api_dict.keys()) == set(sequence_data.keys())

    for seq_id in sequence_data:
        np.testing.assert_allclose(
            local_dict[seq_id], api_dict[seq_id], rtol=1e-4, atol=1e-4
        )


def test_embed_equivalence_one_hot_per_residue(bc_local, bc_api):
    sequence_data = {
        "Seq1": "MMALSLALM",
        "Seq2": "PRTEIN",
    }

    local_res = bc_local.embed(
        embedder_name=CommonEmbedder.ONE_HOT_ENCODING,
        sequence_data=sequence_data,
        reduce=False,
    )
    api_res = bc_api.embed(
        embedder_name=CommonEmbedder.ONE_HOT_ENCODING,
        sequence_data=sequence_data,
        reduce=False,
    )

    local_dict = local_res.to_dict()
    api_dict = api_res.to_dict()

    assert set(local_dict.keys()) == set(sequence_data.keys())
    assert set(api_dict.keys()) == set(sequence_data.keys())

    for seq_id in sequence_data:
        np.testing.assert_allclose(
            local_dict[seq_id], api_dict[seq_id], rtol=1e-4, atol=1e-4
        )
