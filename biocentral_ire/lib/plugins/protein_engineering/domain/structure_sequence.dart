import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/plugins/protein_engineering/domain/mutation_descriptor.dart';
import 'package:biocentral/plugins/protein_engineering/model/engineering_campaign.dart';
import 'package:flutter/painting.dart' show Color;

/// mmCIF three-letter residue codes to their one-letter amino acid code.
const Map<String, String> _threeLetterToOneLetter = {
  'ALA': 'A',
  'ARG': 'R',
  'ASN': 'N',
  'ASP': 'D',
  'CYS': 'C',
  'GLN': 'Q',
  'GLU': 'E',
  'GLY': 'G',
  'HIS': 'H',
  'ILE': 'I',
  'LEU': 'L',
  'LYS': 'K',
  'MET': 'M',
  'PHE': 'F',
  'PRO': 'P',
  'SER': 'S',
  'THR': 'T',
  'TRP': 'W',
  'TYR': 'Y',
  'VAL': 'V',
};

/// A chain's residues in entity-sequence order, with the one-letter sequence they spell out.
class ChainSequence {
  final Chain chain;
  final List<Residue> orderedResidues;
  final String sequence;

  ChainSequence({required this.chain, required this.orderedResidues, required this.sequence});
}

/// Extracts [chain]'s one-letter sequence, ordered by `labelSeqId` when every residue has one.
/// Falls back to file order otherwise. Residues with an unrecognized three-letter code become 'X'.
ChainSequence extractChainSequence(Chain chain) {
  final residues = [...chain.residues];
  if (residues.every((residue) => residue.labelSeqId != null)) {
    residues.sort((a, b) => a.labelSeqId!.compareTo(b.labelSeqId!));
  }
  final sequence = residues.map((residue) => _threeLetterToOneLetter[residue.name.toUpperCase()] ?? 'X').join();
  return ChainSequence(chain: chain, orderedResidues: residues, sequence: sequence);
}

/// A chain of [structure] whose extracted sequence exactly matches a campaign's wildtype sequence.
class WildtypeStructureMatch {
  final MolecularStructure structure;
  final ChainSequence chainSequence;

  WildtypeStructureMatch({required this.structure, required this.chainSequence});

  /// The residue key for a 1-indexed position in the campaign's wildtype sequence, or null if out of range.
  ResidueKey? residueKeyForPosition(int position) {
    final index = position - 1;
    if (index < 0 || index >= chainSequence.orderedResidues.length) {
      return null;
    }
    final residue = chainSequence.orderedResidues[index];
    return ResidueKey(chainSequence.chain.id, residue.id);
  }
}

/// Finds the first chain in [structure] whose sequence exactly matches [wildtypeSequence].
WildtypeStructureMatch? matchWildtypeStructure(MolecularStructure structure, String wildtypeSequence) {
  for (final chain in structure.chains) {
    final chainSequence = extractChainSequence(chain);
    if (chainSequence.sequence == wildtypeSequence) {
      return WildtypeStructureMatch(structure: structure, chainSequence: chainSequence);
    }
  }
  return null;
}

/// Residue highlights for [candidateSequence] against [wildtypeSequence], all in [color].
/// Diffs the full sequences rather than chaining per-round substitutions, so this is correct
/// even for a round that was re-based onto a non-wildtype parent.
Map<ResidueKey, Color> highlightsForCandidate({
  required WildtypeStructureMatch match,
  required String wildtypeSequence,
  required String candidateSequence,
  required Color color,
}) {
  final highlights = <ResidueKey, Color>{};
  if (candidateSequence.length != wildtypeSequence.length) {
    return highlights;
  }
  for (var i = 0; i < wildtypeSequence.length; i++) {
    if (candidateSequence[i] != wildtypeSequence[i]) {
      final key = match.residueKeyForPosition(i + 1);
      if (key != null) {
        highlights[key] = color;
      }
    }
  }
  return highlights;
}

/// One structure-viewer dropdown entry: a display label and the mutant's full resolved sequence.
class StructureCandidate {
  final String label;
  final String sequence;

  const StructureCandidate({required this.label, required this.sequence});

  @override
  bool operator ==(Object other) => other is StructureCandidate && other.label == label && other.sequence == sequence;

  @override
  int get hashCode => Object.hash(label, sequence);
}

/// Resolvable suggestions from one round, for the structure viewer's dropdown.
List<StructureCandidate> structureCandidatesForRound(EngineeringRound round) {
  final suggestionSet = round.result.suggestions.toSet();
  final candidates = <StructureCandidate>[];
  for (final entityId in suggestionSet) {
    try {
      final substitutions = parseMutationDescriptor(entityId);
      final sequence = applySubstitutions(round.parentSequence, substitutions);
      if (sequence != null) {
        candidates.add(StructureCandidate(label: formatSubstitutions(substitutions), sequence: sequence));
      }
    } on UnresolvableVariantException {
      // Skip candidates the current server can't resolve to a sequence yet.
    }
  }
  return candidates;
}

/// Resolvable suggestions across every round so far, deduplicated by sequence.
List<StructureCandidate> structureCandidatesForAllRounds(List<EngineeringRound> rounds) {
  final bySequence = <String, StructureCandidate>{};
  for (final round in rounds) {
    for (final candidate in structureCandidatesForRound(round)) {
      bySequence[candidate.sequence] = candidate;
    }
  }
  return bySequence.values.toList();
}
