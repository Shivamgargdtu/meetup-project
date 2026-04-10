import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:meetup/models/meeting.dart';
import 'package:meetup/resources/firestore_methods.dart';
import 'package:meetup/resources/jitsi_meet.dart';

class MeetingDetailsSheet extends StatefulWidget {
  final MeetingHistoryItem meeting;

  const MeetingDetailsSheet._({required this.meeting});

  static Future<void> show(BuildContext ctx, MeetingHistoryItem meeting) {
    return showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MeetingDetailsSheet._(meeting: meeting),
    );
  }

  @override
  State<MeetingDetailsSheet> createState() => _MeetingDetailsSheetState();
}

class _MeetingDetailsSheetState extends State<MeetingDetailsSheet> {
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.meeting.isFavorite;
  }

  Future<void> _toggleFav() async {
    setState(() => _isFav = !_isFav);
    await FirestoreMethods()
        .toggleFavorite(widget.meeting.id, value: _isFav);
  }

  void _copyRoomId() {
    Clipboard.setData(ClipboardData(text: widget.meeting.roomId));
    _snack('Room ID copied');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.meeting;
    final isCreated = m.meetingType == 'created';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF10102A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // ── Header ───────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _TypeBadge(isCreated: isCreated),
                  ],
                ),
              ),
              IconButton(
                onPressed: _toggleFav,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    _isFav ? Icons.star_rounded : Icons.star_border_rounded,
                    key: ValueKey(_isFav),
                    color: _isFav
                        ? const Color(0xFFFFB300)
                        : Colors.white.withOpacity(0.3),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── Date + time ───────────────────────────────────────────────
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: DateFormat('EEEE, MMMM d, yyyy').format(m.createdAt),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.access_time_rounded,
            text: DateFormat('h:mm a').format(m.createdAt),
          ),

          const SizedBox(height: 18),

          // ── Room ID pill ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ROOM ID',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        m.roomId,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontFamily: 'monospace',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded,
                      color: Colors.white38, size: 18),
                  onPressed: _copyRoomId,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Rejoin button ─────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                JitsiMeetMethods().createMeet(
                  roomId: m.roomId,
                  displayName: m.displayName,
                  isAudioMuted: true,
                  isVideoMuted: true,
                  meetingType: 'joined',
                );
              },
              icon: const Icon(Icons.videocam_rounded, size: 20),
              label: const Text('Rejoin meeting'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Delete ────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await FirestoreMethods()
                    .deleteFromHistory(m.id);
              },
              icon: const Icon(Icons.delete_outline_rounded, size: 17),
              label: const Text('Remove from history'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent.withOpacity(0.7),
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  final bool isCreated;
  const _TypeBadge({required this.isCreated});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: (isCreated
                ? const Color(0xFF007AFF)
                : const Color(0xFF8E2DE2))
            .withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isCreated ? 'Created by you' : 'Joined',
        style: TextStyle(
          color: isCreated
              ? const Color(0xFF007AFF)
              : const Color(0xFF8E2DE2),
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.white.withOpacity(0.3)),
        const SizedBox(width: 9),
        Text(
          text,
          style: TextStyle(
              color: Colors.white.withOpacity(0.58), fontSize: 13.5),
        ),
      ],
    );
  }
}