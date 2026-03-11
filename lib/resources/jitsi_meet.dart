import 'package:meetup/resources/auth_methods.dart';
import 'package:meetup/resources/firestore_methods.dart';

// Mobile-only imports wrapped safely
import 'jitsi_meet_mobile.dart'
    if (dart.library.html) 'jitsi_meet_web.dart';

class JitsiMeetMethods {
  final AuthMethods _authMethods = AuthMethods();
  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  static const String _appId =
      "vpaas-magic-cookie-2c7a81b33b4943b396ee51b15e180056";

  void createMeet({
    required String roomName,
    required bool isAudioMuted,
    required bool isVideoMuted,
    String username = '',
  }) async {
    try {
      String name = username.isEmpty
          ? _authMethods.user.displayName!
          : username;

      _firestoreMethods.addToHistory(roomName);

      await joinMeetingPlatform(
        appId: _appId,
        roomName: roomName,
        displayName: name,
        email: _authMethods.user.email ?? '',
        avatar: _authMethods.user.photoURL ?? '',
        isAudioMuted: isAudioMuted,
        isVideoMuted: isVideoMuted,
      );
    } catch (e) {
      print(e.toString());
    }
  }
}