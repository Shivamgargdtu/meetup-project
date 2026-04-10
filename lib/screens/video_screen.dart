import 'package:flutter/material.dart';
import 'package:meetup/resources/auth_methods.dart';
import 'package:meetup/resources/jitsi_meet.dart';
import 'package:meetup/utils/colors.dart';
import 'package:meetup/utils/utils.dart';
import 'package:meetup/widgets/meeting_option.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final AuthMethods _authMethods = AuthMethods();
  final JitsiMeetMethods _jitsiMeetMethods = JitsiMeetMethods();

  late final TextEditingController _roomIdCtrl;
  late final TextEditingController _nameCtrl;

  bool _isAudioMuted = true;
  bool _isVideoMuted = true;

  @override
  void initState() {
    super.initState();
    _roomIdCtrl = TextEditingController();
    final user = _authMethods.user;
    _nameCtrl = TextEditingController(
      text: user.isAnonymous ? '' : (user.displayName ?? ''),
    );
  }

  @override
  void dispose() {
    _roomIdCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // Derive a clean display name for a room ID the user typed manually.
  // "31832+1775846574137" → "Meeting #31832"
  // "123"                → "Meeting #123"
  String _friendlyName(String roomId) {
    if (roomId.trim().isEmpty) return 'Unnamed Meeting';
    final parts = roomId.split(RegExp(r'[_+]'));
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? 'Meeting #${parts[0]}'
        : 'Meeting #$roomId';
  }

  Future<void> _joinMeeting() async {
    final roomId = _roomIdCtrl.text.trim();
    if (roomId.isEmpty) {
      showSnackBar(context, 'Please enter a Room ID');
      return;
    }
    await _jitsiMeetMethods.createMeet(
      roomId: roomId,
      displayName: _friendlyName(roomId),
      isAudioMuted: _isAudioMuted,
      isVideoMuted: _isVideoMuted,
      username: _nameCtrl.text.trim(),
      meetingType: 'joined',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: const Text('Join a Meeting', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: TextField(
              controller: _roomIdCtrl,
              maxLines: 1,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                fillColor: secondaryBackgroundColor,
                filled: true,
                hintText: 'Room ID',
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              ),
            ),
          ),
          SizedBox(
            height: 60,
            child: TextField(
              controller: _nameCtrl,
              maxLines: 1,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                fillColor: secondaryBackgroundColor,
                filled: true,
                hintText: 'Your name',
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              ),
            ),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: _joinMeeting,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text('Join',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
          MeetingOption(
            text: 'Mute Audio',
            isMute: _isAudioMuted,
            onChange: (val) => setState(() => _isAudioMuted = val),
          ),
          const SizedBox(height: 20),
          MeetingOption(
            text: 'Turn Off Video',
            isMute: _isVideoMuted,
            onChange: (val) => setState(() => _isVideoMuted = val),
          ),
        ],
      ),
    );
  }
}