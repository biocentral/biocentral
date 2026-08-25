import taxoniq


class Taxonomy:
    """
    Class to handle taxonomy data using taxoniq (original from https://github.com/Sebief/hvi_toolkit)

    Methods:
        get_name_from_id(taxonomy_id): Returns the name of the taxonomy with the given ID.
        get_family_from_id(taxonomy_id): Returns the family of the taxonomy with the given ID.

    Examples:
        >>> taxonomy = Taxonomy()
        >>> taxonomy.get_name_from_id(11293)
        'Rabies virus AV01'
        >>> taxonomy.get_family_from_id(11293)
        'Rhabdoviridae'
    """

    def get_name_from_id(self, taxonomy_id: int) -> str:
        """
        Returns the name of the species for a given taxonomy id.


        :param taxonomy_id: NCBI taxonomy id
        :return: Scientific name of the given taxonomy id
        """
        taxon = taxoniq.Taxon(taxonomy_id)
        return taxon.scientific_name

    def get_family_from_id(self, taxonomy_id: int) -> str:
        """
        Returns the family name for the given taxonomy id.

        "-aceae": fungal, algal, and botanical nomenclature
        "-idae": animals, viruses

        We need to iterate over the taxonomy tree for the given id to find the correct family name,
        because hierarchies may differ in length

        :param taxonomy_id: NCBI taxonomy id
        :return: Family name for the given taxonomy id
        """
        taxon = taxoniq.Taxon(taxonomy_id)
        for taxon in taxon.ranked_lineage:
            if taxon.rank == taxoniq.Rank["family"]:
                break
        return taxon.scientific_name
