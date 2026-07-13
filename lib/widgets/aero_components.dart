import 'package:aerocrew/theme/aero_theme.dart';
import 'package:flutter/material.dart';

class AeroAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AeroAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackButton;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 64 : 72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      toolbarHeight: preferredSize.height,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          if (subtitle != null)
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      actions: actions,
    );
  }
}

class AeroCard extends StatelessWidget {
  const AeroCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AeroSpacing.md),
      child: child,
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

enum AeroButtonVariant { primary, secondary, danger }

class AeroButton extends StatelessWidget {
  const AeroButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AeroButtonVariant.primary,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AeroButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AeroSizes.smallIcon),
              const SizedBox(width: AeroSpacing.xs),
              Text(label),
            ],
          );
    Widget button;
    if (variant == AeroButtonVariant.secondary) {
      button = OutlinedButton(onPressed: onPressed, child: child);
    } else {
      button = ElevatedButton(
        onPressed: onPressed,
        style: variant == AeroButtonVariant.danger
            ? ElevatedButton.styleFrom(backgroundColor: context.aero.danger)
            : null,
        child: child,
      );
    }
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AeroStatusChip extends StatelessWidget {
  const AeroStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AeroRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...icon == null
              ? const <Widget>[]
              : <Widget>[
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 5),
                ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class AeroSectionHeader extends StatelessWidget {
  const AeroSectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ?action,
      ],
    );
  }
}

class AeroLoadingState extends StatelessWidget {
  const AeroLoadingState({super.key, this.label = 'Loading'});
  final String label;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: AeroSpacing.md),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class AeroEmptyState extends StatelessWidget {
  const AeroEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AeroSpacing.section),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: context.aero.textSecondary),
          const SizedBox(height: AeroSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AeroSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (action != null) ...[
            const SizedBox(height: AeroSpacing.md),
            action!,
          ],
        ],
      ),
    ),
  );
}

class AeroErrorState extends StatelessWidget {
  const AeroErrorState({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => AeroEmptyState(
    icon: Icons.error_outline,
    title: 'Something went wrong',
    message: message,
    action: onRetry == null
        ? null
        : AeroButton(label: 'Try again', onPressed: onRetry),
  );
}

class AeroListTile extends StatelessWidget {
  const AeroListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: AeroSizes.touchTarget,
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: trailing ?? const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
