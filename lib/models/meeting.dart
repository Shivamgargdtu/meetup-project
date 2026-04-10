import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingHistoryItem {
  final String id;
  final String roomId;       // technical Jitsi ID  e.g. "31832+1775846574137"
  final String displayName;  // friendly label       e.g. "Meeting #31832"
  final DateTime createdAt;
  final String meetingType;  // 'created' | 'joined'
  final bool isFavorite;

  const MeetingHistoryItem({
    required this.id,
    required this.roomId,
    required this.displayName,
    required this.createdAt,
    required this.meetingType,
    required this.isFavorite,
  });

  factory MeetingHistoryItem.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    final ts = d['createdAt'];
    // Backward-compat: older docs used 'meetingName' for the raw room ID
    final rawId = (d['roomId'] as String?)
        ?? (d['meetingName'] as String?)
        ?? '';
    return MeetingHistoryItem(
      id: doc.id,
      roomId: rawId,
      displayName: (d['displayName'] as String?) ?? _deriveName(rawId),
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      meetingType: (d['meetingType'] as String?) ?? 'joined',
      isFavorite: (d['isFavorite'] as bool?) ?? false,
    );
  }

  static String _deriveName(String rawId) {
    if (rawId.trim().isEmpty) return 'Unnamed Meeting';
    final parts = rawId.replaceFirst(RegExp(r'^meet_'), '').split(RegExp(r'[_+]'));
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? 'Meeting #${parts[0]}'
        : 'Meeting';
  }

  MeetingHistoryItem copyWith({bool? isFavorite}) => MeetingHistoryItem(
        id: id,
        roomId: roomId,
        displayName: displayName,
        createdAt: createdAt,
        meetingType: meetingType,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}