# Engineering manual verification

Run `fvm flutter run -d macos` from this worktree's `biocentral_ire` directory.
Use a fresh project, a backend supporting this branch's iteration schema, and a
small protein with matching mmCIF. One-hot encoding plus the random model is
convenient for a quick backend check. Old unversioned campaigns are unsupported.

These are requested checks, not completed runtime test results. The user confirmed
application launch. Further computer-use verification is intentionally omitted.

## Setup and navigation

- Create from pasted sequence, project protein and FASTA. Check invalid sequence,
  non-finite fitness, required fields and invalid seed. Cancel file selection.
- Set measurement name/unit, maximize/minimize, embedder/model and seed. Add WT
  fitness, manual variants and seed CSV. Launch once: one creation command and
  one selected campaign should appear.
- Clone a campaign: expect a new stable ID, copied applied configuration/data and
  structure, no copied rounds, and independent subsequent changes.
- Visit Overview, Rounds, History, Lineage, Mutations and Settings; switch between
  campaigns and resize. Check dialogs, plots and narrow layouts. Other plugin
  themes should remain unchanged; Settings should have no invented controls.
- Open a round from Overview/Lineage and select another via the round tabs. Sidebar
  bench export should use the selected round. Activity opens the existing log.

## Restrictions and structures

- Toggle global exclusions; add positions/ranges. Invalid/out-of-range positions
  block Apply. Typing must change neither applied data nor Activity.
- Apply several edits once: one restriction command. Empty rules and unchanged
  drafts should not produce commands. Discard restores applied values.
- Navigate away/back and switch campaigns: drafts should survive and remain
  attached to the correct campaign.
- Upload matching mmCIF; rotate/inspect it, select positions and save them into a
  restriction draft. Apply records the restriction change; inspection alone does
  not. Try uploading from the position picker before any structure exists.
- Replace the structure: one upload command and working viewer. Malformed or
  nonmatching input should fail without replacing the applied structure.

## Rounds and measurements

- Suggest from WT, best, measured and custom parents. Check count/coefficient.
  Missing numeric training data or invalid parent should block submission.
- Check candidate decimals and missing values; sort/filter/select and inspect
  highlights. Missing values must not display as zero. UI actions add no commands.
- Draft numeric measurements/DNE, navigate away/back, then submit a batch once.
  Expect one command and updated overview/history/lineage. Correct an applied
  measurement: its discovery round stays unchanged. Try individual/all Discard.
- Export bench CSV, fill numeric/DNE values, import and inspect preview. Check
  quoted fields, decimals, blank rows and existing-measurement skip counts.
  Malformed/duplicate-header CSV fails without partial import. Correct existing
  measurements through the table.
- Run another round after applying restrictions. Inspect Activity and exported
  JSON: actual candidates obey restrictions; request, parent, seed, input IDs and
  restrictions remain captured after later edits. DNE is excluded from numeric
  training data.

## Persistence and command lifecycle

- Export, close/reopen project, and reimport. Check stable IDs, measurements,
  rounds and structure. JSON has `schemaVersion: 1`, source bytes and hashes.
- Edit data, then import an older export over the same campaign. Confirm
  replacement; local revision advances. Drafts with changed underlying data must
  require discarding before submission.
- Reject unversioned/unknown-version documents, damaged hashes and invalid
  structures without partially imported campaigns.
- Delete: Cancel retains data; Confirm removes it, logs a command and survives
  project reopen. Other campaigns remain usable.
- Start a long command and attempt one from another plugin. The second must not
  replace the active command. A result awaiting manual acceptance must block new
  execution until accepted/discarded.
- Cause a backend FAILED response. Expect available server details in Activity,
  one engineering error notification, polling to stop and a new command to be
  possible. Also check connection failure/timeout recovery.
- Activity should record creation/clone, applied restrictions, measurement
  submission/correction/import, structure upload/replacement, rounds, deletion,
  campaign import/export. Navigation, sorting, inspection, draft edits and bench
  export should not create scientific commands.

Report the action, campaign/round, visible error and relevant Activity entry for
failures. Feedback on spacing, density and prototype parity is useful too; exact
visual parity has not been verified.

## Follow-up corrections

- Wizard steps should run horizontally. Check spacing between the two source
  dropdowns and between optimization direction and model selection, and matching
  Back/Continue corner radii.
- Advancing from Start without any numeric measurement should explain what is
  missing. A numeric WT measurement or measured mutant/CSV permits advancement;
  DNE alone does not. WT specifically remains optional.
- Overview metrics should have equal dimensions and metrics/plots should adapt to
  the available width. All three plots label rounds and the measured quantity or
  prediction error, including units where supplied.
- Run against localhost with one-hot encoding and the random model. A local API
  diagnostic returned 12 predictions and 8 suggestions; the Dart resolver recovered
  12 candidate rows including all 8 suggestions. Opaque identifiers and parent
  residue mismatches were rejected by the response validator. These checks do not
  constitute visual verification of the table.
- New unusable responses should fail the round command without applying it. Saved
  unusable rounds should show the specific response problem in Rounds/History;
  bench export should explain the problem instead of writing blank sequences.

- Follow-up visual checks: overview metric cards are 116 px high; expanded lineage
  sequence nodes match the reference at 156 × 42 px, with correctly attached edges.
  Round tabs should follow Overview/Lineage navigation and sidebar bench exports,
  compact and scroll with many rounds, and update after adding/importing rounds.
  Scientific table values display two decimals while editors and exports retain
  their original precision.
