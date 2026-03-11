import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

Future<void> joinMeetingPlatform({
  required String appId,
  required String roomName,
  required String displayName,
  required String email,
  required String avatar,
  required bool isAudioMuted,
  required bool isVideoMuted,
}) async {
  final jitsiMeet = JitsiMeet();

  var options = JitsiMeetConferenceOptions(
    serverURL: "https://8x8.vc",
    room: "$appId/$roomName",
    userInfo: JitsiMeetUserInfo(
      displayName: displayName,
      email: email,
      avatar: avatar,
    ),
    featureFlags: {
      "lobby-mode.enabled": false,
      "add-people.enabled": false,
      "invite.enabled": false,
    },
    configOverrides: {
      "startWithAudioMuted": isAudioMuted,
      "startWithVideoMuted": isVideoMuted,
      "prejoinPageEnabled": false,
      "enableLobby": false,
      "autoKnockLobby": false,
      "lobby.autoKnock": false,
      "disableModeratorIndicator": false,
    },
  );

  await jitsiMeet.join(options);
}