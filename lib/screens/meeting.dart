import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meetup/resources/jitsi_meet.dart';
import 'package:meetup/utils/constants.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen>
    with SingleTickerProviderStateMixin {
  final JitsiMeetMethods _jitsiMeetMethods = JitsiMeetMethods();
  late AnimationController _ctrl;
  late Animation<double> _fade;

  static const _quotes = [
    (
      'The way we communicate with others and with ourselves ultimately determines the quality of our lives.',
      'Tony Robbins'
    ),
    (
      'Connection is why we\'re here. We are hardwired to connect with others; it\'s what gives purpose and meaning to our lives.',
      'Brené Brown'
    ),
    (
      'We are all connected; to each other, biologically. To the earth, chemically. To the rest of the universe atomically.',
      'Neil deGrasse Tyson'
    ),
    (
      'I am, by calling, a dealer in words; and words are, of course, the most powerful drug used by mankind.',
      'Rudyard Kipling'
    ),
    (
      'Vulnerability is the birthplace of innovation, creativity and change.',
      'Brené Brown'
    ),
    (
      'Communication is a skill that you can learn. If you\'re willing to work at it, you can rapidly improve the quality of your life.',
      'Brian Tracy'
    ),
    (
      'Leadership requires two things: a vision of the world that does not yet exist and the ability to communicate it.',
      'Simon Sinek'
    ),
  ];

  (String, String) get _todaysQuote =>
      _quotes[(DateTime.now().weekday - 1) % _quotes.length];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Room-name fix: store short ID in history, use full ID for Jitsi ──────
  void _createNewMeeting() {
    final shortId = Random().nextInt(100000);
    final roomId =
        '$shortId+${DateTime.now().millisecondsSinceEpoch}'; // Jitsi room
    final friendlyName = 'Meeting #$shortId';               // shown in history
    _jitsiMeetMethods.createMeet(
      roomId: roomId,
      displayName: friendlyName,
      isAudioMuted: true,
      isVideoMuted: true,
      meetingType: 'created',
    );
  }

  void _joinMeeting() => Navigator.pushNamed(context, '/video');

  void _copyInvite() {
    Clipboard.setData(const ClipboardData(text: AppConstants.appShareUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invite link copied'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final (quote, author) = _todaysQuote;

    return FadeTransition(
      opacity: _fade,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/anime.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.38, 0.72, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.60),
                    Colors.black.withOpacity(0.28),
                    Colors.black.withOpacity(0.65),
                    Colors.black.withOpacity(0.88),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _QuoteBlock(quote: quote, author: author),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ActionRow(
                    onNewMeeting: _createNewMeeting,
                    onJoin: _joinMeeting,
                    onSchedule: () {},
                    onInvite: _copyInvite,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _QuoteBlock extends StatelessWidget {
  final String quote;
  final String author;
  const _QuoteBlock({required this.quote, required this.author});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36, height: 1.5,
          color: Colors.white.withOpacity(0.35),
          margin: const EdgeInsets.only(bottom: 14),
        ),
        Text(
          '"$quote"',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontStyle: FontStyle.italic,
            height: 1.55,
            color: Colors.white.withOpacity(0.92),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '— $author',
          style: TextStyle(
            fontSize: 11.5,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.45),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _ActionRow extends StatelessWidget {
  final VoidCallback onNewMeeting, onJoin, onSchedule, onInvite;
  const _ActionRow({
    required this.onNewMeeting,
    required this.onJoin,
    required this.onSchedule,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 17),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: Colors.white.withOpacity(0.12), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Pill(icon: Icons.videocam_rounded, label: 'New',
                  onTap: onNewMeeting, highlight: true),
              _VertDivider(),
              _Pill(icon: Icons.login_rounded, label: 'Join', onTap: onJoin),
              _VertDivider(),
              _Pill(icon: Icons.calendar_month_rounded, label: 'Schedule',
                  onTap: onSchedule),
              _VertDivider(),
              _Pill(icon: Icons.link_rounded, label: 'Share App',
                  onTap: onInvite),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;
  const _Pill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  @override
  State<_Pill> createState() => _PillState();
}

class _PillState extends State<_Pill> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: () => _ctrl.reverse(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 22,
                  color: widget.highlight
                      ? Colors.white
                      : Colors.white.withOpacity(0.65)),
              const SizedBox(height: 5),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  letterSpacing: 0.2,
                  fontWeight: widget.highlight
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: widget.highlight
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: Colors.white.withOpacity(0.1));
}