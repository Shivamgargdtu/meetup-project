import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meetup/models/meeting.dart';
import 'package:meetup/resources/firestore_methods.dart';
import 'package:meetup/screens/meeting_details.dart';

// ─────────────────────────────────────────────────────────────────────────────
enum _Filter { all, created, joined, starred }

extension _FilterLabel on _Filter {
  String get label {
    switch (this) {
      case _Filter.all:     return 'All';
      case _Filter.created: return 'Created';
      case _Filter.joined:  return 'Joined';
      case _Filter.starred: return 'Starred';
    }
  }
}
// ─────────────────────────────────────────────────────────────────────────────

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchCtrl = TextEditingController();
  _Filter _filter = _Filter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(
        () => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MeetingHistoryItem> _applyFilter(List<MeetingHistoryItem> all) {
    var list = switch (_filter) {
      _Filter.created => all.where((m) => m.meetingType == 'created').toList(),
      _Filter.joined  => all.where((m) => m.meetingType == 'joined').toList(),
      _Filter.starred => all.where((m) => m.isFavorite).toList(),
      _Filter.all     => all,
    };
    if (_query.isNotEmpty) {
      list = list
          .where((m) =>
              m.displayName.toLowerCase().contains(_query) ||
              m.roomId.toLowerCase().contains(_query))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirestoreMethods().meetingsHistory;

    return Stack(
      children: [
        // ── Anime background — intentionally very dim ───────────────────
        Positioned.fill(
          child: Image.asset('assets/images/anime.png', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.87)),
        ),

        // ── Content ─────────────────────────────────────────────────────
        Column(
          children: [
            _SearchBar(controller: _searchCtrl),
            _FilterBar(
              current: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: stream == null
                  ? const _Hint(
                      icon: Icons.lock_outline_rounded,
                      title: 'History unavailable',
                      subtitle:
                          'Sign in to save and view\nyour meeting history.',
                    )
                  : StreamBuilder<List<MeetingHistoryItem>>(
                      stream: stream,
                      builder: (ctx, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF00C9A7),
                              strokeWidth: 2.5,
                            ),
                          );
                        }
                        if (snap.hasError) {
                          return const _Hint(
                            icon: Icons.wifi_off_rounded,
                            title: 'Could not load history',
                            subtitle: 'Check your connection\nand try again.',
                          );
                        }

                        final all = snap.data ?? [];
                        if (all.isEmpty) {
                          return const _Hint(
                            icon: Icons.history_toggle_off_rounded,
                            title: 'No meetings yet',
                            subtitle:
                                'Meetings you join or create\nwill appear here.',
                          );
                        }

                        final visible = _applyFilter(all);
                        return Column(
                          children: [
                            _StatsStrip(meetings: all),
                            if (visible.isEmpty)
                              const Expanded(
                                child: _Hint(
                                  icon: Icons.search_off_rounded,
                                  title: 'No results',
                                  subtitle:
                                      'Try a different search or filter.',
                                ),
                              )
                            else
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 12, 16, 32),
                                  itemCount: visible.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (ctx, i) => _MeetingCard(
                                    meeting: visible[i],
                                    index: i,
                                    onTap: () => MeetingDetailsSheet.show(
                                        ctx, visible[i]),
                                    onFavToggle: () async {
                                      await FirestoreMethods().toggleFavorite(
                                        visible[i].id,
                                        value: !visible[i].isFavorite,
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: Colors.white54,
        decoration: InputDecoration(
          hintText: 'Search meetings…',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon:
              Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.3)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 18, color: Colors.white.withOpacity(0.4)),
                  onPressed: () => controller.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.07),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER BAR
// ─────────────────────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final _Filter current;
  final ValueChanged<_Filter> onChanged;
  const _FilterBar({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: _Filter.values.map((f) {
          final active = f == current;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF007AFF)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    if (f == _Filter.starred) ...[
                      Icon(Icons.star_rounded,
                          size: 13,
                          color: active
                              ? Colors.white
                              : Colors.white.withOpacity(0.45)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      f.label,
                      style: TextStyle(
                        color: active
                            ? Colors.white
                            : Colors.white.withOpacity(0.45),
                        fontSize: 12.5,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS STRIP
// ─────────────────────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final List<MeetingHistoryItem> meetings;
  const _StatsStrip({required this.meetings});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeek =
        meetings.where((m) => m.createdAt.isAfter(weekStart)).length;
    final starred = meetings.where((m) => m.isFavorite).length;
    final created = meetings.where((m) => m.meetingType == 'created').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat('${meetings.length}', 'Total',
              const Color(0xFF007AFF)),
          _StatDivider(),
          _Stat('$thisWeek', 'This week',
              const Color(0xFF00C9A7)),
          _StatDivider(),
          _Stat('$created', 'Created',
              const Color(0xFF8E2DE2)),
          _StatDivider(),
          _Stat('$starred', 'Starred',
              const Color(0xFFFFB300)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Stat(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 10.5,
                letterSpacing: 0.3)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: Colors.white.withOpacity(0.07));
}

// ─────────────────────────────────────────────────────────────────────────────
// MEETING CARD
// ─────────────────────────────────────────────────────────────────────────────
class _MeetingCard extends StatelessWidget {
  final MeetingHistoryItem meeting;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onFavToggle;

  const _MeetingCard({
    required this.meeting,
    required this.index,
    required this.onTap,
    required this.onFavToggle,
  });

  Color get _accent {
    const palette = [
      Color(0xFF007AFF),
      Color(0xFF8E2DE2),
      Color(0xFF0F7B6C),
      Color(0xFFFF6B00),
      Color(0xFFE91E8C),
    ];
    return palette[index % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormat.yMd().format(meeting.createdAt) ==
        DateFormat.yMd().format(DateTime.now());
    final dateStr =
        isToday ? 'Today' : DateFormat('MMM d, yyyy').format(meeting.createdAt);
    final timeStr = DateFormat('h:mm a').format(meeting.createdAt);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF14142B),
        border: Border.all(color: _accent.withOpacity(0.22), width: 1),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _accent.withOpacity(0.18),
                    border: Border.all(
                        color: _accent.withOpacity(0.3), width: 0.8),
                  ),
                  child: Icon(Icons.videocam_rounded,
                      color: _accent, size: 20),
                ),
                const SizedBox(width: 13),

                // Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // This now shows "Meeting #31832" — never the raw ID
                        meeting.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (meeting.meetingType == 'created'
                                      ? const Color(0xFF007AFF)
                                      : const Color(0xFF8E2DE2))
                                  .withOpacity(0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              meeting.meetingType,
                              style: TextStyle(
                                color: meeting.meetingType == 'created'
                                    ? const Color(0xFF007AFF)
                                    : const Color(0xFFAB82FF),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Date + star
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          color: _accent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onFavToggle,
                      child: Icon(
                        meeting.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 18,
                        color: meeting.isFavorite
                            ? const Color(0xFFFFB300)
                            : Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY / ERROR HINT
// ─────────────────────────────────────────────────────────────────────────────
class _Hint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Hint(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 48,
                color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 16),
            Text(title,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 13.5,
                    height: 1.5)),
          ],
        ),
      ),
    );
  }
}