import 'package:flutter/material.dart';
import 'package:meetup/resources/auth_methods.dart';
import 'package:meetup/screens/history.dart';
import 'package:meetup/screens/meeting.dart';
import 'package:meetup/utils/colors.dart';
import 'package:meetup/widgets/custom_button.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int page=0;
  void onPageChange(int page){
    setState(() {
    this.page = page;
  });
  }
  List <Widget> pages=[
    MeetingScreen(),
    const HistoryScreen(),
    const Text('Contacts'),
    CustomButton(text: 'Log Out', onPressed:() => AuthMethods().signOut()),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Meet Up App', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600,fontFamily: 'Arial'),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 43, 40, 40),
      ),
      body: pages[page],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: onPageChange,
        currentIndex: page,
        //type: BottomNavigationBarType.fixed,
        selectedFontSize: 16,
        //unselectedFontSize: 16,
        backgroundColor: footerColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.comment_bank), label: 'Meet & Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.lock_clock), label: 'Meetings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Contacts'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
    ),
    );
  }
}