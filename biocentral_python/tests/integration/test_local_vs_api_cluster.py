def test_cluster_equivalence(bc_local, bc_api):
    sequence_data = {
        "Seq1": "MMALSLALM",
        "Seq2": "MMALSLALV",
        "Seq3": "PRTEINSEQWENCE",
        "Seq4": "PRTEINSEQWENCI",
        "Seq5": "ACDEFGHIKLMNPQRSTVWY",
    }

    local_clusters = bc_local.cluster(sequence_data, sequence_identity_threshold=0.8)
    api_clusters = bc_api.cluster(sequence_data, sequence_identity_threshold=0.8)

    assert set(local_clusters.keys()) == set(api_clusters.keys())
    for cluster_id, seq_list in local_clusters.items():
        assert set(seq_list) == set(api_clusters[cluster_id])
