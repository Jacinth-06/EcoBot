import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class userinfo extends StatefulWidget {
  const userinfo({super.key});

  void initState() {
    //super.initState();
    getname();
  }

  Future<String> getname () async {
    User? user = FirebaseAuth.instance.currentUser;
       if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String name = snapshot.get('name');


      return name;

    }
    else {
      return '';
    }
  }


  Future<String> getemail () async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String email = snapshot.get('email');


      return email;

    }
    else {
      return '';
    }
  }



  @override
  State<userinfo> createState() => _userinfoState();
}

class _userinfoState extends State<userinfo> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
