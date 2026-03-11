import 'package:flutter/material.dart';
import 'package:meetup/screens/home.dart';
import 'package:meetup/screens/login.dart';
import 'package:meetup/resources/auth_methods.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meetup/screens/video_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MeetUp App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor:Color.fromARGB(255, 13, 71, 74),
      ),
      routes:{
        '/login':(context) => const LoginScreen(),
        '/home':(context) => const HomeScreen(),
        '/video':(context) => const VideoScreen(),
      },
      home: StreamBuilder(
        stream: AuthMethods().authChanges, 
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }
          else if(snapshot.hasData){
            return const HomeScreen();
          }
          return const LoginScreen();
      },
      ),
    );
  }
}