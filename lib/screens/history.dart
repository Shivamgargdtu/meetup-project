import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meetup/resources/firestore_methods.dart';
import 'package:intl/intl.dart';
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreMethods().meetingsHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                'Room Name: ${docs[index]['meetingName']}',
              ),
              subtitle: Text(
                'Joined on : ${DateFormat.yMMMd().format((docs[index]['createdAt'].toDate()),)}',
              ),
            );
          },
        );
      },
    );
  }
}