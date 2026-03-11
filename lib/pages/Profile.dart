import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'package:newapp/utils/Userinfo.dart';
import"login.dart";


class ProfileScreen extends StatefulWidget {

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  userinfo userInfo = userinfo();
  String name = '';
  String email = '';
  @override
  void initState() {
    super.initState();
    Userdata();
  }

  void Userdata() async {
    String Fetchedname = await userInfo.getname();
    String Fetchedemail =  await userInfo.getemail();
    setState(() {
      name =  Fetchedname;
      email = Fetchedemail;
    });

  }

  //const ProfileScreen({required this.name, required this.email, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQm7rgdQwCfn-4lI7Spr0u82Q6lWnN-RvYOdQ&s"), // Optional
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.settings, color: Colors.green),
                title: const Text('Preferences'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {

                  // Go to preferences screen
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.green),
                title: const Text('About EcoBot'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Go to about screen
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.public, color: Colors.green),
                title: const Text('Log out'),
                trailing: const Icon(Icons.logout, size: 16),
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,'/signin'
                  );
                  // Go to carbon tracker
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
