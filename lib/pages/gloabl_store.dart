import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class GlobalStore {
  static Stream<double> co2Stream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('carbon_entries')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return 0.0;

      final data = snap.docs.first.data();
      final food = data['food'] ?? 0;
      final elec = data['electricity'] ?? 0;
      final travel = data['travel'] ?? 0;

      return (food + elec + travel).toDouble();
    });
  }
}
