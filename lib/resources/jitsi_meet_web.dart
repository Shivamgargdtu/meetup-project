import 'package:url_launcher/url_launcher.dart';

Future<void> joinMeetingPlatform({
  required String appId,
  required String roomName,
  required String displayName,
  required String email,
  required String avatar,
  required bool isAudioMuted,
  required bool isVideoMuted,
}) async {
  // Build the 8x8.vc URL with config params
  final meetingUrl = Uri.parse(
    "https://8x8.vc/$appId/$roomName"
    "#userInfo.displayName=${Uri.encodeComponent(displayName)}"
    "&userInfo.email=${Uri.encodeComponent(email)}"
    "&config.startWithAudioMuted=$isAudioMuted"
    "&config.startWithVideoMuted=$isVideoMuted"
    "&config.prejoinPageEnabled=false"
    "&config.enableLobby=false",
  );

  if (await canLaunchUrl(meetingUrl)) {
    await launchUrl(
      meetingUrl,
      webOnlyWindowName: '_blank', // ✅ opens in new tab on web
    );
  } else {
    throw Exception('Could not launch meeting URL: $meetingUrl');
  }
}