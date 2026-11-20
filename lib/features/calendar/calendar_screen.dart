import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/ads/ad_service.dart';
import '../../core/providers.dart';
import '../../data/repositories/repositories.dart';
import '../../shared/widgets.dart';
import '../outfit_creator/outfits_list.dart';

typedef MonthKey = ({int year, int month});

/// Entries for the visible month (plus a week margin either side for week view edges).
final monthEntriesProvider = StreamProvider.family<List<CalendarItem>, MonthKey>((ref, m) {
  final start = DateTime(m.year, m.month, 1).subtract(const Duration(days: 7));
  final end = DateTime(m.year, m.month + 1, 1).add(const Duration(days: 7));
  return ref.watch(calendarRepoProvider).watchRange(start, end);
});

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = dayOnly(DateTime.now());
  CalendarFormat _format = CalendarFormat.month;

  Future<void> _assign() async {
    final id = await pickOutfit(context, ref);
    if (id == null) return;
    await ref.read(calendarRepoProvider).assign(_selected, id);
    if (mounted) showSnack(context, 'Planned for ${DateFormat.MMMd().format(_selected)}');
  }

  /// In landscape the calendar gets half the width and scrolls on its own if taller than the screen.
  Widget _calendarSlot(BuildContext context, bool landscape, Widget calendar) => landscape
      ? SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.48,
          child: SingleChildScrollView(child: calendar),
        )
      : calendar;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final entries = ref.watch(monthEntriesProvider((year: _focused.year, month: _focused.month)));
    final all = entries.value ?? const <CalendarItem>[];
    final byDay = <DateTime, List<CalendarItem>>{};
    for (final e in all) {
      byDay.putIfAbsent(dayOnly(e.entry.date), () => []).add(e);
    }
    final dayItems = byDay[_selected] ?? const <CalendarItem>[];
    final isPast = _selected.isBefore(dayOnly(DateTime.now()));
    final isFuture = _selected.isAfter(dayOnly(DateTime.now()));
    final landscape = MediaQuery.orientationOf(context) == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _focused = DateTime.now();
              _selected = dayOnly(DateTime.now());
            }),
            child: const Text('Today'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(heroTag: 'plan', onPressed: _assign, icon: const Icon(Icons.add), label: const Text('Plan outfit')),
      // Portrait: calendar above the day's outfits. Landscape: side by side, so nothing overflows.
      body: Column(
        children: [
          Expanded(
            child: Flex(
              direction: landscape ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _calendarSlot(
                  context,
                  landscape,
                  TableCalendar<CalendarItem>(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2100),
                    focusedDay: _focused,
                    calendarFormat: _format,
                    availableCalendarFormats: const {CalendarFormat.month: 'Month', CalendarFormat.week: 'Week'},
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    selectedDayPredicate: (d) => isSameDay(d, _selected),
                    eventLoader: (d) => byDay[dayOnly(d)] ?? const [],
                    onDaySelected: (sel, foc) => setState(() {
                      _selected = dayOnly(sel);
                      _focused = foc;
                    }),
                    onFormatChanged: (f) => setState(() => _format = f),
                    onPageChanged: (f) => setState(() => _focused = f),
                    headerStyle: HeaderStyle(
                      titleTextStyle: t.textTheme.titleMedium!,
                      formatButtonDecoration: BoxDecoration(
                        border: Border.all(color: t.colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(color: t.colorScheme.primary.withValues(alpha: 0.18), shape: BoxShape.circle),
                      todayTextStyle: TextStyle(color: t.colorScheme.primary, fontWeight: FontWeight.w700),
                      selectedDecoration: BoxDecoration(color: t.colorScheme.primary, shape: BoxShape.circle),
                      markerDecoration: BoxDecoration(color: t.colorScheme.tertiary, shape: BoxShape.circle),
                      markersMaxCount: 3,
                    ),
                  ),
                ),
                landscape ? const VerticalDivider(width: 1) : const Divider(height: 1),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat('EEEE, d MMM').format(_selected),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.textTheme.titleMedium,
                              ),
                            ),
                            if (dayItems.isNotEmpty)
                              Text(
                                isPast
                                    ? 'History'
                                    : isFuture
                                    ? 'Upcoming'
                                    : 'Today',
                                style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: entries.isLoading && all.isEmpty
                            ? const LoadingView()
                            : dayItems.isEmpty
                            ? EmptyState(
                                icon: Icons.event_available_outlined,
                                title: 'Nothing planned',
                                message: isPast ? 'No outfit recorded for this day.' : 'Plan an outfit for this day.',
                              )
                            : ListView(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                                children: [
                                  for (final e in dayItems)
                                    Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(10),
                                        leading: SizedBox(
                                          width: 60,
                                          height: 60,
                                          child: ClipRRect(borderRadius: BorderRadius.circular(10), child: OutfitCollage(e.outfit.items)),
                                        ),
                                        title: Text(e.outfit.outfit.name),
                                        subtitle: Text('${e.outfit.items.length} pieces'),
                                        onTap: () => context.push('/outfit/${e.outfit.outfit.id}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (!isFuture)
                                              Tooltip(
                                                message: e.entry.worn ? 'Worn' : 'Mark as worn',
                                                child: Checkbox(
                                                  value: e.entry.worn,
                                                  onChanged: (v) => ref.read(calendarRepoProvider).setWorn(e.entry, v ?? false),
                                                ),
                                              ),
                                            IconButton(
                                              tooltip: 'Remove from day',
                                              icon: const Icon(Icons.close),
                                              onPressed: () async {
                                                final ok = await confirm(
                                                  context,
                                                  title: 'Remove from calendar?',
                                                  message: 'The outfit itself is kept.',
                                                  confirmLabel: 'Remove',
                                                );
                                                if (ok) await ref.read(calendarRepoProvider).remove(e.entry);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ref.watch(adServiceProvider).banner(AdPlacement.calendar),
        ],
      ),
    );
  }
}
