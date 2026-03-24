import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meetup/resources/firestore_methods.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  /// Converts raw room IDs like "meet_34333_1772953061792"
  /// or "34333+1772953061792" into a friendly display name.
  String _formatRoomName(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Unnamed Meeting';

    // Strip leading "meet_" prefix if present
    String cleaned = raw.replaceFirst(RegExp(r'^meet_'), '');

    // Extract just the short numeric ID before any separator
    final parts = cleaned.split(RegExp(r'[_+]'));
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return 'Meeting #${parts[0]}';
    }
    return 'Meeting';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreMethods().meetingsHistory,
      builder: (context, snapshot) {
        // ── Loading ──────────────────────────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF00C9A7),
              strokeWidth: 2.5,
            ),
          );
        }

        // ── Error ────────────────────────────────────────────────────
        if (snapshot.hasError) {
          return _CenteredHint(
            icon: Icons.wifi_off_rounded,
            title: 'Could not load history',
            subtitle: 'Check your connection and try again.',
          );
        }

        // ── Empty ────────────────────────────────────────────────────
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _CenteredHint(
            icon: Icons.history_toggle_off_rounded,
            title: 'No meetings yet',
            subtitle: "Meetings you join or create\nwill appear here.",
          );
        }

        // ── List ─────────────────────────────────────────────────────
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final rawName = doc['meetingName'] as String?;
            final createdAt =
                (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

            final friendlyName = _formatRoomName(rawName);
            final dateStr = DateFormat('MMM d, yyyy').format(createdAt);
            final timeStr = DateFormat('h:mm a').format(createdAt);
            final isToday = DateFormat.yMd().format(createdAt) ==
                DateFormat.yMd().format(DateTime.now());

            return _MeetingCard(
              friendlyName: friendlyName,
              rawName: rawName,
              dateStr: isToday ? 'Today' : dateStr,
              timeStr: timeStr,
              index: index,
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEETING CARD
// ─────────────────────────────────────────────────────────────────────────────
class _MeetingCard extends StatelessWidget {
  final String friendlyName;
  final String? rawName;
  final String dateStr;
  final String timeStr;
  final int index;

  const _MeetingCard({
    required this.friendlyName,
    required this.rawName,
    required this.dateStr,
    required this.timeStr,
    required this.index,
  });

  // Cycle through a few accent colours for visual variety
  Color get _accentColor {
    const colors = [
      Color(0xFF007AFF),
      Color(0xFF8E2DE2),
      Color(0xFF0F7B6C),
      Color(0xFFFF6B00),
      Color(0xFFE91E8C),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF1C1C2E),
        border: Border.all(
          color: _accentColor.withOpacity(0.25),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {}, // hook up rejoin logic here later
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── Left accent icon ─────────────────────────────────
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                      colors: [
                        _accentColor,
                        _accentColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.videocam_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                // ── Text block ───────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friendlyName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Raw room ID as muted subtitle
                      if (rawName != null && rawName!.trim().isNotEmpty)
                        Text(
                          rawName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 11.5,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ── Date / time chip ─────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          color: _accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
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
// CENTERED HINT  (empty & error state)
// ─────────────────────────────────────────────────────────────────────────────
class _CenteredHint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CenteredHint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Colors.white.withOpacity(0.18)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
