import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const billingRoute = '/profile/billing';
const upgradeToGrowthLabel = 'Upgrade to Growth';

void navigateToBilling(BuildContext context) {
  context.push(billingRoute);
}

void showUpgradeSnackBar(
  BuildContext context, {
  String message = 'This feature requires a Growth plan or higher.',
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Upgrade',
        onPressed: () => navigateToBilling(context),
      ),
    ),
  );
}

Future<void> showUpgradeDialog(
  BuildContext context, {
  String title = 'Upgrade required',
  String message = 'Upgrade to Growth or higher to unlock this feature.',
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            navigateToBilling(context);
          },
          child: const Text(upgradeToGrowthLabel),
        ),
      ],
    ),
  );
}

class UpgradePromptBanner extends StatelessWidget {
  const UpgradePromptBanner({
    super.key,
    this.message = 'This feature requires Growth or higher.',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: () => navigateToBilling(context),
              child: const Text(upgradeToGrowthLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class UsageQuotaLabel extends StatelessWidget {
  const UsageQuotaLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
