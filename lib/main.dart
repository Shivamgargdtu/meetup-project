/*import 'package:flutter/material.dart';
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
}*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meetup/screens/home.dart';
import 'package:meetup/screens/login.dart';
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
      title: 'MeetUp',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 13, 71, 74),
      ),
      // Named routes for deep links and explicit navigation (e.g. /video)
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/video': (context) => const VideoScreen(),
      },
      // Auth state drives the root: no manual Navigator.pushNamed after login/logout.
      // When the user signs in or out, Firebase emits a new User? and the tree
      // rebuilds automatically — no double-stacked routes, no back-button weirdness.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) return const HomeScreen();
          return const LoginScreen();
        },
      ),
    );
  }
}