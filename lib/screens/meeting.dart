import 'dart:math';
import 'package:flutter/material.dart';
import 'package:meetup/resources/jitsi_meet.dart';
import 'package:meetup/widgets/meeting_button.dart';

class MeetingScreen extends StatelessWidget {
  MeetingScreen({super.key});

  final JitsiMeetMethods _jitsiMeetMethods = JitsiMeetMethods();

void createNewMeeting() {
  var random = Random();

  String roomName =
      "${random.nextInt(100000)}+${DateTime.now().millisecondsSinceEpoch}";

  _jitsiMeetMethods.createMeet(
    roomName: roomName,
    isAudioMuted: true,
    isVideoMuted: true,
  );
}

  void joinMeeting(BuildContext context) {
    Navigator.pushNamed(context, '/video');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        /// FIXES OVERFLOW
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [

                const SizedBox(width: 15),

                MeetingButton(
                  onPressed: createNewMeeting,
                  text: 'New Meeting',
                  icon: Icons.videocam,
                ),

                const SizedBox(width: 20),

                MeetingButton(
                  onPressed: () => joinMeeting(context),
                  text: 'Join Meeting',
                  icon: Icons.add_box_rounded,
                ),

                const SizedBox(width: 20),

                MeetingButton(
                  onPressed: () {},
                  text: 'Schedule',
                  icon: Icons.calendar_today,
                ),

                const SizedBox(width: 20),

                MeetingButton(
                  onPressed: () {},
                  text: 'Share Screen',
                  icon: Icons.arrow_upward_rounded,
                ),

                const SizedBox(width: 15),

              ],
            ),
          ),
        ),

        const Expanded(
          child: Center(
            child: Text(
              'Create/Join Meetings with just a click!',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 255, 255, 188),
              ),
            ),
          ),
        ),
      ],
    );
  }
}