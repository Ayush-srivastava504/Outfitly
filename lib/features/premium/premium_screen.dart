import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

void showLimitDialog(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      icon: const Icon(Icons.workspace_premium_outlined),
      title: const Text('Free limit reached'),
      content: Text('$message\n\nDelete items you no longer own, or look out for Outfitly Premium with higher limits.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(c);
            context.push('/profile/premium');
          },
          child: const Text('About Premium'),
        ),
        FilledButton(onPressed: () => Navigator.pop(c), child: const Text('OK')),
      ],
    ),
  );
}

/// Honest premium page: describes the plan; no purchase flow until Play Billing ships.
class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    final ent = ref.watch(entitlementsProvider);
    final rows = [
      ('Wardrobe items', '${ent.maxItems}', 'Unlimited'),
      ('Saved outfits', '${ent.maxOutfits}', 'Unlimited'),
      ('Advanced statistics', '—', '✓'),
      ('Extra themes', '—', '✓'),
      ('Ad-free', '—', '✓'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Outfitly Premium')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(Icons.workspace_premium, size: 64, color: t.colorScheme.primary),
          const SizedBox(height: 12),
          Text('Coming soon', textAlign: TextAlign.center, style: t.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Everything you use today stays free. Premium will add higher limits and extras for people with big wardrobes. '
            'It isn\'t available to buy yet — we\'ll let you know in an update.',
            textAlign: TextAlign.center,
            style: t.textTheme.bodyLarge?.copyWith(color: t.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Card(
            child: Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
              children: [
                TableRow(
                  decoration: BoxDecoration(color: t.colorScheme.primary.withValues(alpha: 0.08)),
                  children: [
                    for (final h in ['', 'Free', 'Premium'])
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(h, style: t.textTheme.labelLarge, textAlign: h.isEmpty ? TextAlign.start : TextAlign.center),
                      ),
                  ],
                ),
                for (final (f, free, prem) in rows)
                  TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(12), child: Text(f)),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(free, textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          prem,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: t.colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
