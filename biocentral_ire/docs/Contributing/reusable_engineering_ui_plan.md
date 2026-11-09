# Reusable UI and protein engineering implementation plan

Status: implementation plan; application implementation has not started.
Prepared and revised 2026-11-09. This document records the user's decisions and the fresh-base investigation.

## 1. Objective and approved scope

Introduce reusable SDK presentation components reflecting the current protein engineering design, and rebuild the engineering plugin using them. Apply the new theme only within engineering in this PR. Other plugins adopt it later. Preserve the reference's user-visible workflows, except for explicitly approved changes. Use the existing active learning plugin as the architectural reference, not the engineering prototype's widget internals.

Approved changes:

- Standard Flutter theming plus a small theme extension.
- Shared workspace/navigation, content, form, and dialog components.
- Repository-driven hub Bloc and the existing command execution/logging architecture.
- Immutable campaign snapshots, stable campaign IDs, and immutable per-round input snapshots.
- Versioned campaign persistence with no legacy loader.
- Commands for every applied change to scientific inputs or outcomes.
- Apply/Discard for mutation restrictions instead of immediate persistence.
- Preserve original imported measurements and uploaded structures for provenance.
- Global protection against overlapping command lifecycles, rejecting rather than queueing submissions.
- Typed terminal task failure and immediate termination of polling on FAILED.

Web support is temporarily suspended by explicit user instruction. Target desktop only; do not spend implementation or verification effort on web compatibility, browser downloads, or browser storage. FVM preview Flutter is explicitly approved.

Do not migrate other plugin UIs, invent settings, introduce a generic workflow framework, implement legacy compatibility, or redesign scientific algorithms. Bench export need not become a logged command. The user explicitly deferred writing tests; do not add a test-writing phase now. Formatting, analysis, source inspection, and manual verification remain useful implementation checks.

## 2. Git baseline and reference preservation

- Upstream remote: `origin`, https://github.com/biocentral/biocentral.git.
- PR target: upstream `develop`.
- Fresh base: `1f0448fa` (make generated engineering mutations reproducible across workers).
- Implementation branch: `biocentral/feature/reusable-engineering-ui`.
- Worktree: `/private/tmp/biocentral-reusable-engineering-ui`.
- Reference checkout: `/Users/aeneastews/work/hiwi_rostlab/projects/biocentral_mono`.
- Reference branch: `gui-rebuild`; committed HEAD `1e98cda` plus its staged, unstaged, and untracked changes.
- `git fetch origin develop` completed, including the referenced biotrainer submodule fetch. No merge/pull was performed into the dirty reference branch. A new worktree was created directly at updated `origin/develop`, which provides the requested current upstream base without disturbing the reference.
- Branch naming follows root `Contributing.md`. Future commits must follow its sign-off requirements. This task creates the plan, not a commit or PR.

The reference includes an untracked mutations page, action bus, CSV/seed helpers, and seed field; it also deletes campaign settings and renames the box plot. Inspect the actual working files, not just HEAD. Do not stash, reset, clean, cherry-pick the entire prototype branch, or apply its whole diff. The reference is a behavior/design source, not the new implementation base. Before later implementation, confirm the reference has not changed and preserve any needed source snapshot deliberately. The temporary worktree path is local working storage, not a permanent artifact guarantee.

### Upstream activity verification (2026-11-09)

Ran `git fetch origin`, checked all fetched branch tips, and verified the live branch list with `git ls-remote --heads origin`. The fetch refspec covers every upstream branch.

| Branch | Tip | Commit date | Interpretation |
| --- | --- | --- | --- |
| develop | 1f0448fa | 2026-11-06 | Newest upstream tip; active application/backend development. |
| main | d1eb4a3a | 2026-11-02 | One unique docs-site Next dependency update. |
| deploy | 45c7ce2a | 2026-10-02 | Older deployment tip. |
| fix/post-v201 | 45c7ce2a | 2026-10-02 | Same older tip. |

`git rev-list --left-right --count origin/develop...origin/main` reports 59 / 1. Develop is not a strict superset of main, but is the appropriate active development base and the documented PR target. Do not merge main's unrelated docs dependency change for this task. The implementation branch remains correctly based on 1f0448fa; no rebase is needed. This conclusion concerns upstream branches, not unpublished work or all forks.

No AGENTS.md was found in the inspected repository trees. Read any newly introduced guidance before implementation.

## 3. Fresh-base findings and required adjustments

| Area | Fresh develop | Adjustment |
| --- | --- | --- |
| Engineering IRE plugin | Absent | Build and register the plugin, not merely refactor existing base files. |
| Engineering backend | Endpoint and pipeline present | Preserve existing implementation and seed fixes. |
| Dart API | Generated models and high-level `alEngineeringIteration` already exist in ActiveLearningClient and high_level_api.dart | Reuse the upstream method and client; adapt prototype call sites instead of adding EngineeringClient. |
| Explicit candidate sequences | Absent in base engineering iteration contract | Add the narrow contract/pipeline support needed to enforce restrictions, and regenerate affected API artifacts. |
| Command runner | Single current command, no overlap guard | Implement shared lifecycle ownership. |
| Task polling | FAILED yields an empty tuple then continues | Deliver typed failure and return immediately. |
| Seed defaults | `biocentralDefaultSeed = 43` | Reuse the SDK constant; do not restore prototype defaults. |
| Structure viewer | Reference resolves the Git feature branch to ae19684f34db2a872860c9277dee4af144d74822 | Adopt that inspected revision and its preview requirements; see exact setup below. |
| Flutter | Reference actually resolves FVM revision cf97bfbcb9f508a35cfdc451f4c2d19e30ad6b7c, Flutter 3.50.0-0.1.pre | Use the approved FVM preview pin and align metadata/tooling with it; do not mistake the older pubspec constraint for the resolved SDK. |
| Other dependencies | Reference changes archive and serious_python and removes a companion asset | Do not import these unrelated changes. Evaluate only necessary transitive compatibility. |
| Project storage | Desktop project file APIs available | Use desktop storage; keep campaign exports self-contained for reproducibility. Web is out of scope. |

Upstream's mutation generator sorts amino-acid alternatives and preserves insertion order. The reference candidate-support diff also reverts those improvements. Implement candidate bypass on top of develop, retaining upstream determinism. Preserve upstream training, embedding, and per-round inference seeding. Do not change screening simulation models as collateral generated-code churn.

### Inspected reference structure-viewer setup

- `biocentral_ire/pubspec.yaml`: Git URL `https://github.com/AeneasTews/bio_flutter.git`, ref `feat/protein-structure-viewer`.
- Reference lockfile and package_config resolve that dependency to `ae19684f34db2a872860c9277dee4af144d74822`; cached package source was inspected directly.
- That revision requires Dart `^3.14.0-111.0.dev`, Flutter `>=3.48.0-1.0.pre`, and `flutter_scene: 0.20.0`.
- `.fvmrc` pins `cf97bfbcb9f508a35cfdc451f4c2d19e30ad6b7c`. Its installed SDK metadata identifies Flutter `3.50.0-0.1.pre`, master channel, and Dart `3.14.0-111.0.dev`. The reference package_config points into this FVM SDK even though a local `.fvm` symlink is absent.
- Desktop runner changes enable Impeller and Flutter GPU in Linux and Windows, and include the macOS Impeller configuration. Review/carry the exact relevant native settings from the reference along with its macOS deployment-target adjustments, rather than expecting a pubspec dependency change alone to enable rendering.

Implementation: pin bio_flutter to the inspected immutable Git revision, use the exact approved FVM SDK revision, and resolve dependencies under that SDK. Align pubspec SDK requirements, IDE instructions and CI SDK selection; use `fvm flutter` / `fvm dart` consistently. Do not replace the reproducible revision with an unpinned moving preview channel. Preserve upstream's Windows-build intent when adapting its stable SDK pin. Check preview compatibility with the existing desktop companion and archive dependencies; change those only where necessary and explain the reason. The existing cached metadata establishes the setup, not proof that the clean worktree builds or renders successfully.

Remaining dependency gates before UI implementation: verify required chart APIs, direct `built_collection` usage, preview SDK/native runner compatibility, and API generation tooling. Initialize the clean worktree's biotrainer submodule only if backend/schema tooling needs it; fetching its object does not initialize the new worktree.

## 4. Behavior inventory to preserve

### Workspace and navigation

Campaign list with creation and deletion; selected campaign's Overview, Rounds, History, Lineage, and Mutations pages; Activity access; campaign import/export; plugin settings placeholder. Sidebar shortcuts invoke the same feature action as page controls. Selecting a campaign returns to overview and clears obsolete round selection. Opening a lineage/overview round targets the correct round. No nonexistent campaign-settings page should be restored from the committed prototype.

### Campaign creation

Multi-step wizard accepts wildtype information, sequence/structure and seed data using the actual reference options, measurement name/unit and initial fitness, model/embedder, maximize/minimize direction, seed, and restrictions. Creation-from-existing prefills a fresh draft and creates a distinct ID. Keep temporary wizard edits local until launch. Validate sequence, substitution, fitness and structure inputs before creating a command; do not silently drop scientifically meaningful invalid rows. If stricter validation changes a visible prototype behavior, present it for approval before implementing that interaction.

### Overview, rounds, history and lineage

Overview composes summary metrics, trends, recent measurements and round links. Rounds show suggestions, predictions, uncertainties/plots, measurements, and structure inspection with round selection. Preserve batch measurement entry, CSV preview/import, corrections, did-not-express handling, and bench export. History filters measured variants without modifying data. Lineage preserves parent relationships and links to rounds. Reuse domain calculations after review; do not move biological logic into generic SDK widgets.

### Mutations and structure

Global exclusions and position-specific exclusions, manual position expressions, structure-based position selection, and rule addition/removal remain available. Keep an immutable applied restriction value and a separate editable draft. Apply dispatches one command; Discard restores applied values. Disable Apply for invalid/unchanged drafts. Structure picking changes the draft, not the campaign. Decide draft retention on navigation consistently; do not silently persist or discard a meaningful draft. Ask before adding a new leave-page confirmation interaction.

Raw structure input must exactly match the intended wildtype chain under existing matching rules. Camera movement, residue inspection and candidate selection are UI state. Upload/replacement is a scientific command.

## 5. Proposed source boundaries

Use existing `lib/sdk/presentation/{style,widgets,dialogs,displays}` directories and exports in `biocentral_sdk.dart`. Group related private declarations within a library; no requirement for one file per tiny type.

| Public component | Contract and responsibility |
| --- | --- |
| `BiocentralWorkspaceTheme` | Build scoped ThemeData using ColorScheme, TextTheme, button/input/dialog themes; own only remaining semantic tokens in a ThemeExtension with copyWith/lerp. Avoid a static-only widget factory class. |
| `BiocentralWorkspace` | Sidebar/content layout and bounded scrolling; takes child widgets, not repositories or campaigns. |
| `BiocentralNavigationSection` | Heading and grouped items. |
| `BiocentralNavigationItem` | Label, optional leading/trailing content, selected/enabled state, callback and disabled explanation. |
| `BiocentralPageHeader` | Title, optional description and actions; consistent alignment and spacing. |
| `BiocentralSectionCard` | Surface, border, padding, optional header/actions, arbitrary child. |
| `BiocentralMetricCard` | Label, formatted value and optional supporting content; no domain calculations. |
| `BiocentralStatusBadge` | Semantic tone plus text; meaning must not depend on color alone. |
| `BiocentralEmptyState` | Explanation and optional action for absent content. |
| `BiocentralNotice` | Persistent inline information, warning or error with optional action. |
| `BiocentralFormSection` | Field grouping and explanatory text; feature owns validators/controllers. |
| `BiocentralWizard` | Step navigation/content presentation driven by caller-supplied state and callbacks. |
| Dialog frame/helper | Title, subtitle, scrollable content, bounded size and actions; generic typed dialog result and confirmation helper. |

Names are proposed API names, not a mandate to duplicate an existing suitable widget. Review `BiocentralDialog`, `BiocentralDiscreteSelection`, status/task displays and buttons first. Prefer themed Flutter controls over thin wrappers. Do not introduce a generic table or scientific chart framework without actual shared requirements.

Command presentation reuses `BiocentralStatusIndicator`, task/log displays and Activity. Restyle through scoped theme where possible. A feedback listener is presentation-only: observe command lifecycle, show one notification, link to Activity; never call the backend. Keep it feature-local unless a clear shared owner prevents duplication across mounted plugin tabs. Generic SDK components have no engineering imports.

Engineering structure:

- `model/`: campaign, round, measured variant, input artifact/reference, request snapshot and draft value types.
- `domain/`: repository, serialization, restriction validation/candidate preparation, measurement import/export, structure matching, insights and lineage calculations.
- `bloc/`: hub events/state/Bloc and scientific commands. Split command files by cohesive responsibility if the file becomes difficult to navigate.
- `presentation/views/`: thin page composition and Bloc adapters.
- `presentation/commands/`: parameter forms/dialogs and wizard.
- `presentation/widgets/`: protein-specific editor, table, plot and structure components.

## 6. State ownership and data flow

Repository -> immutable snapshot stream -> EngineeringHubBloc -> BlocBuilder/BlocSelector -> composed view. UI submission -> validated command -> BiocentralCommandBloc -> API or local computation -> acceptResult -> repository replacement -> autosave and stream.

Hub state contains campaigns, selected stable ID, active section and selected round identity/index with bounds validation. Initial state must load the repository's current snapshot before listening, so a preloaded repository is visible. Retain selection by ID across updates; clear/reset on deletion. Store/cancel subscriptions in close. Do not inject another Bloc into the hub; shared command UI observes command state at the presentation boundary.

Drafts, focus, text controllers, filters and camera state remain local unless multiple components genuinely coordinate them. Immutable collection copies and meaningful equality replace edit counters/config snapshots. On campaign replacement, preserve same-campaign drafts intentionally rather than resetting based on object identity. Dispose controllers and subscriptions. Async UI callbacks check lifecycle before accessing context.

Command preparation captures immutable inputs at submission. Do not read mutable campaign objects later in an async operation. Use a campaign revision to reject a stale commit when necessary; stable identity and revision are distinct concepts. No direct campaign mutation from widget callbacks.

## 7. Complete command mapping and provenance

| Action | Command | Recorded scientific data |
| --- | --- | --- |
| Create / create from existing | NewEngineeringCampaignCommand | New ID, optional source ID, complete resolved config, wildtype, units, initial measurements, seed, restrictions, artifact references. |
| Apply exclusions or position rules | UpdateEngineeringRestrictionsCommand | Campaign ID/revision and complete before/after restriction values. Structure-picked positions use this same command. |
| Submit/correct measurements or mark did-not-express | AddEngineeringMeasurementsCommand (rename if needed) | Sequence identities and previous/new measurement states, source round and provenance. |
| Confirm CSV import | Same measurement update operation | Original input artifact, parsing/mapping choices and accepted rows; record overwritten values. |
| Upload/replace structure | UploadWildtypeStructureCommand | Previous/new content reference and matching information. Retain prior original input. |
| Suggest round | RunEngineeringRoundCommand | Immutable campaign/iteration snapshots, actual training data, parent sequence, explicit candidates when used, seed/restrictions, task ID when available and result. |
| Delete campaign | DeleteEngineeringCampaignCommand | Stable identity and sufficient deleted campaign information to explain the operation; no automatic undo feature. |
| Import campaigns | LoadEngineeringCampaignCommand | Format version, source provenance, affected IDs and conflict resolution; validate entire import before committing. |
| Export campaigns | ExportEngineeringCampaignCommand | Campaign IDs/revisions and output destination/result. |

No scientific command for navigation, sorting/filtering, structure rotation, inspection, opening Activity or unsubmitted drafts. Bench export stays an export helper. Empty rule insertion is a draft change; only applied scientific changes are commands. No-op Apply does not create a log entry.

Logs use JSON-serializable structured fields, never opaque toString config dumps. Distinguish untested, expressed numeric measurement and did-not-express; preserve the reference's scientific meaning of these states. Commands fail without partially mutating the repository. Commit snapshots in acceptResult consistent with the established command lifecycle. Project loading retains existing suppression of user command logging/autosave.

## 8. Versioned persistence and original inputs

One current schema only. Envelope includes `schemaVersion: 1`, `campaigns`, and an artifact collection if inputs are embedded. No unversioned loader or migrations now. Reject missing/unknown versions and malformed fields with actionable messages before altering existing data.

Campaign fields: stable ID, revision, display/config metadata, wildtype sequence/identifier, measurement name/unit, measurements, rounds, restrictions, active structure reference, and provenance references. IDs are created once and serialized; never derived from a mutable name or hashCode. Cloning creates a new identity and records its source.

Round fields: stable round identity/number, started/finished timestamps, immutable submitted campaign configuration and iteration configuration, parent sequence, applied restrictions, input artifact references, returned results and task identifier when available. Corrections to current measurements cannot rewrite past training snapshots.

Input artifact fields: SHA-256 over original bytes, original filename, media/format information, immutable bytes (base64 for JSON), and import metadata. Deduplicate by content hash. Retain original CSV bytes before decoding and original structure bytes before parsing. Hash the original bytes, not re-encoded normalized text. Preserve previous structure artifacts after replacement. The existing crypto dependency can supply hashing.

Portable storage recommendation: an embedded content-addressed artifact map in the versioned campaign document, shared by reference within that document. This keeps campaign exports self-contained for reproducibility; it is not a web compatibility requirement. Desktop project APIs may also store original input files by content hash. If project storage uses file references, exports must embed the referenced original bytes and imports must restore them; never export machine-specific absolute paths as the sole input record. No browser storage or download handling is required. Confirm document size remains practical with real structures; seek approval before changing export format to an archive.

Campaign export includes the referenced artifacts, including historical round references. Import checks content hashes and resolves all references. Preserve conflict preview behavior, now comparing stable IDs; identical display names are not identities. Honor the selected import mode rather than merely logging it. Deletion must not erase provenance required by retained rounds/logs; avoid automatic artifact garbage collection in the first implementation.

## 9. Shared command lifecycle repair

Files: `sdk/bloc/biocentral_command_bloc.dart`, command types/logging as necessary, shared command controls, Activity acceptance/discard controls, direct callers across all plugins.

Model one active lifecycle with explicit idle, running and awaiting-decision semantics. Terminal error releases the execution slot but retains/logs error information for presentation. Successful manual commands remain occupied until acceptance/discard. Do not use the old isBusy implementation, which treats finished-but-unaccepted work as free, or old isIdle semantics, which consider an initial command with no log idle.

Execution algorithm:

1. Atomically claim execution ownership before the first await.
2. If occupied, report a rejected submission without replacing the active command/log. Do not silently drop or queue it.
3. Give each accepted execution a unique token. Associate progress and internal completion/auto-accept with that token.
4. Stream updates only while the execution owns the slot. Convert uncaught execution errors into terminal logs; release ownership reliably.
5. Auto-accept only successful results for the matching execution. Never apply failed output.
6. Manual accept/discard must target the current execution. Ignore stale/duplicate actions safely; accept exactly once.
7. Preserve logging of successful accepted commands and failed attempts without duplicate entries. Determine existing discarded-result semantics before changing them; no unrelated audit-policy redesign.
8. Reject accept/discard while running unless an existing supported cancellation operation is explicitly being invoked. Discard is not server cancellation.
9. Close cancels owned subscriptions; late callbacks cannot emit into a closed Bloc.

A sequential transformer on execute events alone is insufficient: it neither protects awaiting-decision state nor binds acceptance to the originating execution. Keep backwards-compatible event construction where sensible, but update internal callers to include ownership when needed. Review `isBusy/isIdle/isFinished/isErrored` usages and document their final meanings. Shared availability combines domain prerequisites, API health where required, and runner availability. Central rejection remains mandatory even when buttons are disabled.

## 10. Shared API task failure contract

Files: `biocentral_api/dart/lib/src/clients/tasks/biocentral_server_task.dart`, a hand-written failure type, public export, and every consumer of task.run().

The base polls every two seconds for up to 10,000 attempts. TaskDTO already has nullable `error`. It emits all DTOs, attempts result extraction, then yields `(null, null)` for FAILED without returning. Its broad catch also risks swallowing a newly thrown terminal failure.

Implement a typed terminal failure carrying task ID, terminal status and available error details. Keep the success/progress tuple interface if feasible: emit a typed stream error followed by explicit `return` from the async generator (for example a one-error stream delegated with yield*, then return). Do not throw inside a broad catch that treats every error as transient. Narrow the network-fetch catch or place terminal handling outside it. A consumer that continues after a stream error must still receive done, never another poll.

Detect a terminal FAILED DTO before trying to treat the response as success. Preserve useful progress/error DTO visibility without duplicate user notifications. Return before delay or the next HTTP fetch. This stops client polling, not a server process. Keep transient transport retries distinct; do not rewrite retry policy incidentally. Exhaustion must remain terminal and intelligible rather than leave the command operating indefinitely.

Audit every `.run()` consumer in the Dart API and IRE. Handle typed failure in commands, directly or through the shared runner's error conversion, preserving server details in logs. Direct consumers must not receive an unhandled error accidentally. Failure notification belongs to presentation; the API has no BuildContext or Flutter imports.

## 11. Engineering backend/API integration

Existing endpoint: POST `/api/v1/active_learning_service/engineering_iteration`, returns task ID; status polling returns TaskDTO with ActiveLearningIterationResult. Preserve this protocol.

Reuse the existing `ActiveLearningClient.alEngineeringIteration` and high-level `alEngineeringIteration` method with typed generated request models. Inspect and extend existing exports/serialization only as needed for new fields. Do not add the prototype's separate EngineeringClient or duplicate high-level method. The earlier plan's claim that this client support was absent was incorrect; it had been renamed/reorganized upstream. Add optional `candidate_sequences` to the server iteration model and pipeline context so restrictions can supply explicit permitted candidates. Preserve null meaning server-generated mutations; empty explicit candidates must not silently fall back to unrestricted generation. Validate nonempty/unique candidates and applicable sequence invariants at the appropriate boundary.

Reference paths for the narrow server change: `active_learning/al_config.py`, `pipelines/protein_engineering/engineering_pipeline.py`, `engineering_pipeline_context.py`, and `steps/mutation_generation_step.py`. Carry candidate input through each layer. Retain upstream deterministic ordering and seeding. Do not copy the old mutation-generation implementation wholesale.

Update `biocentral_api/openapi_spec/openapi.json` through the repository's generation workflow; regenerate affected Dart models/serializers/docs and any checked-in Python generated artifacts required by that workflow. Discover exact generator commands/configuration before running them. Avoid manual edits to generated files and unrelated generator-version churn.

Frontend request preparation is a pure domain operation: require valid measured numeric training data; exclude did-not-express entries from numeric training while retaining their recorded status; select the approved parent source; create stable sequence IDs; sample restrictions deterministically using the actual campaign seed and documented round derivation; capture the actual candidate list. Display preview and submission must use the same prepared inputs, not independently sampled lists.

## 12. Implementation order and checkpoints

1. Reconfirm clean branch/base and reference inventory. Inspect dependency/generator gates. Do not update all dependencies.
2. Repair shared command ownership and polling failure handling; audit existing consumers so the new contract is usable globally.
3. Add minimal engineering backend/API contract support on top of develop, retaining seed fixes.
4. Implement immutable engineering models, versioned codec, artifact storage, repository and domain preparation/import/export helpers.
5. Implement scientific commands with complete structured logging and guarded commit semantics.
6. Implement scoped theme and reusable components, documenting ownership and composition APIs.
7. Register engineering in core plugin exports/manager, repository directories and Bloc providers using current base conventions.
8. Implement hub and wizard, then overview/rounds, history/lineage, mutations/structure flows; connect shared sidebar/page actions.
9. Adapt existing command presentation and Activity integration; ensure one error notification and matching execution ownership.
10. Review every user action against section 7 and every shared dependency against section 3.
11. Format/analyze changed code with the selected SDK; manually exercise agreed flows. No new tests in this phase per user instruction.
12. Review final diff against develop for accidental prototype/environment changes. Prepare PR targeting develop only when implementation is complete and requested workflow permits.

Do not implement visual/workflow changes beyond approvals. Stop for a design decision if dependency limitations require dropping structure functionality, or if provenance storage requires a substantially different user export flow. Routine class/file factoring does not require repeated approval.

## 13. Manual verification and completion criteria

- New theme confined to engineering; other plugins retain existing appearance. Desktop is the only supported verification target for this work; no web builds or browser smoke checks.
- Every engineering reference page/action remains reachable; empty states and narrow layouts are usable.
- Create, clone, select, delete, export and reimport version-1 campaigns.
- Unknown/unversioned documents fail without partial changes.
- Original measurement and structure bytes survive export/import; replacement retains historical originals.
- Restrictions remain drafts until Apply; Discard restores applied values; one Apply produces one command.
- Measurement corrections and did-not-express states are recorded accurately.
- Round requests use the displayed parameters and preserve immutable input snapshots.
- Sidebar actions work without requiring a target page's subscription to mount first.
- Overlapping commands from different plugins cannot overwrite one another; waiting acceptance blocks a new lifecycle; stale acceptance cannot apply a different result.
- FAILED produces a meaningful log, closes the polling stream, and releases command execution ownership.
- No repository writes from presentation callbacks; no engineering imports in generic SDK components.
- New shared APIs documented with meaningful contracts and examples. No claim of completed runtime verification unless actually performed.

## 14. Style and documentation requirements

Follow root Contributing.md: callbacks named on..., widget-state operational methods before build and rendering helpers, dialogs closed before dispatching events/callbacks. Prefer standalone widgets for reusable composition. Follow base analyzer rules and formatter configuration; do not copy prototype lint changes by default.

Use final fields and defensive immutable collections, typed callback signatures, explicit return types, const constructors where possible, consistent noun/property and verb/action names, and small public APIs. Avoid static-only utility classes, unnecessary interfaces, dynamic request-error introspection, and redundant wrappers. Use appropriate Dart class modifiers without restricting widget extensibility arbitrarily.

Public SDK APIs receive concise `///` comments: one-sentence summary, ownership/default/null/disabled behavior where relevant, identifier links, short examples. Explain parameters/returns/errors in prose rather than JavaDoc-style annotations. Use @override and @immutable where appropriate; comments precede metadata. Explain scientific invariants and reasons, not obvious widget construction. Existing package-import/line-width conventions take precedence over merely preferred alternatives in Effective Dart.

Official references consulted during planning:

- https://bloclibrary.dev/architecture/
- https://bloclibrary.dev/flutter-bloc-concepts/
- https://dart.dev/effective-dart/design
- https://dart.dev/effective-dart/documentation
- https://dart.dev/effective-dart/usage
- https://dart.dev/effective-dart/style

## 15. Remaining implementation-time checks

These are concrete discovery tasks, not permission to expand scope: verify the pinned structure viewer/preview SDK builds and renders on desktop; identify code-generation commands; inspect all task-stream and command-state consumers; inspect exact project close/autosave behavior; confirm imported artifact sizes; verify reference wizard/file/table details while implementing each page. No runnable UI was launched during this base-and-plan task, so pixel-level parity has not yet been verified. Any genuinely new user-facing choice is proposed before implementation.

## 16. Implementation status (2026-11-10)

Implemented on `biocentral/feature/reusable-engineering-ui`, based on upstream
develop, in `/private/tmp/biocentral-reusable-engineering-ui`. The original local
prototype checkout remains unchanged as reference.

The shared command lifecycle and terminating typed task failures, desktop SDK/
viewer dependencies, scoped workspace components, immutable versioned storage,
explicit candidate API/server contract, logged scientific commands, CSV flows,
wizard, overview, rounds/history, lineage, restriction Apply/Discard and structure
selection are implemented. Registration follows current plugin/repository/Bloc
conventions. Existing Activity/progress is reused. Imports advance local revisions;
draft baseline checks protect replaced data. Desktop CI specifies Python 3.12 and
a native app staging directory; the IRE web build is suspended. Other plugin UIs
have not been migrated.

See [component reuse guidance](reusable_workspace_components.md) and the
[manual acceptance checklist](engineering_manual_verification.md).

Engineering Dart analysis passes without findings. Full app analysis reports no
errors, with existing warnings/info elsewhere. A macOS build succeeded before the
final integration edits. The user subsequently confirmed launch after renaming an
old project. Final scientific workflows and visual acceptance await user manual
testing. No further computer-use verification or new automated tests are requested.
The branch has not been pushed and no PR has been opened.
