import 'package:flutter/material.dart';
import 'package:meetup/resources/auth_methods.dart';
import 'package:meetup/resources/jitsi_meet.dart';
import 'package:meetup/utils/colors.dart';
import 'package:meetup/widgets/meeting_option.dart';
class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final AuthMethods _authMethods = AuthMethods();
  late TextEditingController meetingIdController;
  late TextEditingController nameController;
  final JitsiMeetMethods _jitsiMeetMethods = JitsiMeetMethods();
  bool isAudioMuted = true;
  bool isVideoMuted = true;
  void initState() {
    meetingIdController = TextEditingController();
    nameController = TextEditingController(text: _authMethods.user.displayName);
    super.initState();
  }
  @override
  void dispose() {
    meetingIdController.dispose();
    nameController.dispose();
    super.dispose();
  }
  void _joinMeeting() {
    _jitsiMeetMethods.createMeet(
      roomName: meetingIdController.text,
      isAudioMuted: isAudioMuted,
      isVideoMuted: isVideoMuted,
      username: nameController.text,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: const Text(
          'Join a Meerting',
          style: TextStyle(fontSize: 18)
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 60,
          child: TextField(
            controller: meetingIdController,
            maxLines: 1,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              fillColor: secondaryBackgroundColor,
              filled: true,
              hintText: 'Room ID',
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
            ),


          ),
        ),
        SizedBox(height: 60,
          child: TextField(
            controller: nameController,
            maxLines: 1,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              fillColor: secondaryBackgroundColor,
              filled: true,
              hintText: 'Name',
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
            ),
          ),
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: _joinMeeting,
          child: const Padding(padding: EdgeInsets.all(8),child: Text('Join',style: TextStyle(fontSize: 16),),),
        ),
        const SizedBox(height: 20,),
        MeetingOption(text: 'Mute Audio',isMute:isAudioMuted,onChange: onAudioMuted,),
        const SizedBox(height: 20,),
        MeetingOption(text: 'Turn Off Video',isMute:isVideoMuted,onChange: onVideoMuted,),
        ],
      )
    );
  }
  void onAudioMuted(bool val){
    setState(() {
      isAudioMuted = val;
    });
  }
  void onVideoMuted(bool val){
    setState(() {
      isVideoMuted = val;
    });
  }
}