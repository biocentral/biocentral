# Reusing the workspace UI

The components are exported by `package:biocentral/sdk/biocentral_sdk.dart`.
Protein engineering is the first consumer. Other plugins retain their current
appearance until deliberately migrated.

## Composition

Wrap the plugin root in `BiocentralWorkspaceTheme`, then compose a
`BiocentralWorkspace` from navigation and content. It requires bounded width and
height, as provided by a plugin tab. Each pane owns its scroll view.

```dart
BiocentralWorkspaceTheme(
  child: BiocentralWorkspace(
    navigation: ListView(children: [
      BiocentralNavigationSection(
        title: 'PROJECT',
        children: [
          BiocentralNavigationItem(
            label: 'Overview',
            selected: selectedPage == ProjectPage.overview,
            onTap: onOverviewSelected,
          ),
        ],
      ),
    ]),
    child: ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const BiocentralPageHeader(title: 'Overview'),
        BiocentralSectionCard(title: 'Results', child: results),
      ],
    ),
  ),
)
```

Use Flutter's `ColorScheme` and `TextTheme`. `BiocentralWorkspaceColors` adds
success, warning and muted colors. Read them from a context below the scoped
theme. Use a `Builder` below that theme when launching dialogs from its creator.

| Component | Responsibility |
| --- | --- |
| `BiocentralNavigationSection` | Label and group navigation entries. |
| `BiocentralNavigationItem` | Selection and trailing controls; null callback disables navigation. |
| `BiocentralPageHeader` | Page title, explanation and wrapping actions. |
| `BiocentralSectionCard` | Bordered content surface with optional title/actions. |
| `BiocentralMetricCard` | Formatted label, value and detail; caller calculates values. |
| `BiocentralStatusBadge` | Compact status text and semantic color. |
| `BiocentralEmptyState` | Missing-data explanation and optional recovery action. |
| `BiocentralNotice` | Inline guidance, validation or conflict notice. |
| `BiocentralFormSection` | Consistent form heading and content spacing. |
| `BiocentralWizard` | Controlled Flutter stepper with configurable final action label. |
| `BiocentralWorkspaceDialog` | Scrollable dialog frame and wrapping actions. |
| `showBiocentralConfirmation` | Explicit confirmation; dismissal returns false. |

Tables, structures, plots and domain calculations remain feature components.
Cards do not introduce scientific behavior or their own loading state.

## State and command ownership

Repositories own applied data. Hub Blocs observe repository snapshots and own
coordinated navigation. Widget state owns temporary input, inspection, sorting,
selection and drafts. Generic SDK widgets accept values/callbacks and never read
feature repositories or call the backend.

Engineering keeps campaign subtrees keyed by stable ID and pages in an
`IndexedStack`, preserving drafts during navigation. Revision/baseline checks
prevent drafts overwriting changed scientific inputs. Apply and Discard are
explicit; typing does not produce commands.

Dispatch applied changes through `BiocentralCommandBloc`. Busy includes results
awaiting manual acceptance. Disable conflicting controls while busy; the runner
also rejects concurrent submissions. Accept/discard events reference the exact
displayed log. Failure releases ownership and remains visible in Activity.

Reuse `BiocentralStatusIndicator` and Activity for progress/logging. The engineering
feedback listener displays command errors and an Activity link; it does not poll
or mutate data. `BiocentralTaskFailure` carries task failure details through stream
errors. FAILED and timeout end the async generator.

## Persistence

Engineering documents use `schemaVersion: 1` and reject legacy documents.
Campaign/round/input snapshots are immutable. Original CSV/mmCIF bytes and hashes
are retained, and each round captures its actual request and recorded restrictions.
The backend generates all mutants. Restriction settings are currently saved and
logged only; they are not enforced until backend support is implemented.
Exports are self-contained, so large inputs increase project/export size. There
is no external artifact store or compatibility migration in this version.
