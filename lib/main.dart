import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import'pages/onboarding.dart';

import 'pages/dashboard.dart';
import 'package:flutter/material.dart';

import 'pages/detection.dart';
import 'pages/chatbot.dart';
import 'pages/control.dart';
import 'pages/Carbontrack.dart';
import 'pages/Profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login.dart';
import 'pages/signup.dart';
import 'pages/home.dart';





void main () async {
  WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp();
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(



          theme: ThemeData(primarySwatch: Colors.green),
          debugShowCheckedModeBanner: false,
          initialRoute: '/onboarding', // start at Sign-In
          routes: {
            '/onboarding':(context) => const Onboarding(),
            '/signin': (context) => const SignIn(),
            '/signup': (context) => const SignUp(),
            '/dashboard': (context) =>  DashboardPage(),
            '/tracker': (context) => const CarbonTrackerPage(),
            '/chatbot': (context) => const EcoChatbotPage(),
            '/game': (context) => const WasteGame(),
            '/home':(context) => HomePage()
          },








    );
  }
}
