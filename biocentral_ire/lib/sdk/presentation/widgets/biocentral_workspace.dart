import 'package:flutter/material.dart';

/// A plugin workspace with independently scrollable navigation and content.
class BiocentralWorkspace extends StatelessWidget {
  final Widget navigation;
  final Widget child;
  final double navigationWidth;

  const BiocentralWorkspace({required this.navigation, required this.child, this.navigationWidth = 260, super.key});

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: navigationWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(right: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
          ),
          child: navigation,
        ),
        Expanded(child: child),
      ],
    ),
  );
}

/// A labeled group of navigation entries; the parent owns scrolling.
class BiocentralNavigationSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const BiocentralNavigationSection({required this.title, required this.children, super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 6),
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
      ...children,
    ],
  );
}

/// A selectable navigation entry with optional trailing controls.
///
/// A null [onTap] disables the entry; [disabledReason] explains why.
class BiocentralNavigationItem extends StatelessWidget {
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final VoidCallback? onTap;
  final String? disabledReason;

  const BiocentralNavigationItem({
    required this.label,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onTap,
    this.disabledReason,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final item = Material(
      color: selected ? scheme.primary.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: ListTile(
        dense: true,
        selected: selected,
        enabled: onTap != null,
        leading: leading,
        trailing: trailing,
        title: Text(label, overflow: TextOverflow.ellipsis),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        onTap: onTap,
      ),
    );
    return onTap == null && disabledReason != null ? Tooltip(message: disabledReason!, child: item) : item;
  }
}

/// A page title, optional explanation, and wrapping action area.
class BiocentralPageHeader extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> actions;

  const BiocentralPageHeader({required this.title, this.description, this.actions = const [], super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 24,
    runSpacing: 12,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(description!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
        ],
      ),
      if (actions.isNotEmpty) Wrap(spacing: 8, runSpacing: 8, children: actions),
    ],
  );
}

/// A bordered surface grouping related content without imposing feature behavior.
class BiocentralSectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  const BiocentralSectionCard({
    required this.child,
    this.title,
    this.actions = const [],
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null || actions.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: Text(title ?? '', style: Theme.of(context).textTheme.titleMedium)),
              ...actions,
            ],
          ),
          const SizedBox(height: 16),
        ],
        child,
      ],
    ),
  );
}

/// A formatted metric value and its label; callers perform domain calculations.
class BiocentralMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? detail;

  const BiocentralMetricCard({required this.label, required this.value, this.detail, super.key});

  @override
  Widget build(BuildContext context) => BiocentralSectionCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
        if (detail != null) Text(detail!),
      ],
    ),
  );
}

/// A compact status label with an explicit semantic color and readable text.
class BiocentralStatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const BiocentralStatusBadge({required this.label, required this.color, super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

/// An explanation and optional action when a page has no content.
class BiocentralEmptyState extends StatelessWidget {
  final String message;
  final Widget? action;

  const BiocentralEmptyState({required this.message, this.action, super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}

/// A persistent inline message with an optional recovery action.
class BiocentralNotice extends StatelessWidget {
  final String message;
  final IconData icon;
  final Widget? action;

  const BiocentralNotice({required this.message, this.icon = Icons.info_outline, this.action, super.key});

  @override
  Widget build(BuildContext context) => BiocentralSectionCard(
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
        if (action != null) action!,
      ],
    ),
  );
}

/// A labeled group of fields; the feature owns controllers and validation.
class BiocentralFormSection extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;

  const BiocentralFormSection({required this.title, required this.child, this.description, super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      if (description != null) Text(description!),
      const SizedBox(height: 12),
      child,
    ],
  );
}

/// A controlled wizard; step state and submission are owned by the feature.
class BiocentralWizard extends StatelessWidget {
  final int currentStep;
  final List<Step> steps;
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const BiocentralWizard({required this.currentStep, required this.steps, this.onContinue, this.onBack, super.key});

  @override
  Widget build(BuildContext context) =>
      Stepper(currentStep: currentStep, steps: steps, onStepContinue: onContinue, onStepCancel: onBack);
}
