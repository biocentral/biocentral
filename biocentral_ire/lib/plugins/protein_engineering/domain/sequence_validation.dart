const Set<String> standardAminoAcids = {
  'A', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', //
  'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'Y',
};

/// The 0-indexed position of the first character outside the standard 20 amino acids, or null
/// if [sequence] is valid.
int? findInvalidResidueIndex(String sequence) {
  for (var i = 0; i < sequence.length; i++) {
    if (!standardAminoAcids.contains(sequence[i])) {
      return i;
    }
  }
  return null;
}
