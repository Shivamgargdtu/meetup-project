import 'package:flutter/foundation.dart';
import 'package:meetup/resources/auth_methods.dart';
import 'package:meetup/resources/firestore_methods.dart';
import 'package:meetup/utils/constants.dart';

import 'jitsi_meet_mobile.dart'
    if (dart.library.html) 'jitsi_meet_web.dart';

class JitsiMeetMethods {
  final AuthMethods _authMethods = AuthMethods();
  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  /// [roomId]      – the raw Jitsi room name, e.g. "31832+1775846574137"
  /// [displayName] – human-friendly label stored in history, e.g. "Meeting #31832"
  Future<void> createMeet({
    required String roomId,
    required String displayName,
    required bool isAudioMuted,
    required bool isVideoMuted,
    String username = '',
    String meetingType = 'created',
  }) async {
    try {
      final user = _authMethods.user;
      final name = username.isNotEmpty
          ? username
          : (user.isAnonymous ? 'Guest' : (user.displayName ?? 'User'));

      await _firestoreMethods.addToHistory(
        roomId: roomId,
        displayName: displayName,
        meetingType: meetingType,
      );

      await joinMeetingPlatform(
        appId: AppConstants.jitsiAppId,
        roomName: roomId,
        displayName: name,
        email: user.email ?? '',
        avatar: user.photoURL ?? '',
        isAudioMuted: isAudioMuted,
        isVideoMuted: isVideoMuted,
      );
    } catch (e) {
      debugPrint('createMeet error: $e');
    }
  }
}