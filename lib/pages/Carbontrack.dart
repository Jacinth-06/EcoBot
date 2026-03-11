import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';
import'dashboard.dart';
import'gloabl_store.dart';

class CarbonTrackerPage extends StatefulWidget {
  const CarbonTrackerPage({super.key});
  @override
  State<CarbonTrackerPage> createState() => _CarbonTrackerPageState(

  );
}
class _CarbonTrackerPageState extends State<CarbonTrackerPage> {
  double food = 0;
  double electricity = 0;
  double travel = 0;

  double get totalCO2 => food + electricity + travel;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadLastCarbonData();
  }


  String getSafeUsername() {
    if (_user?.displayName != null && _user!.displayName!.isNotEmpty) {
      return _user!.displayName!;
    }

    if (_user?.email != null) {
      return _user!.email!.split('@')[0];
    }

    return "User";
  }

  Future<void> loadLastCarbonData() async {
    if (_user == null) return;

    final snap = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('carbon_entries')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data();

      setState(() {
        food = (data['food'] ?? 0).toDouble();
        electricity = (data['electricity'] ?? 0).toDouble();
        travel = (data['travel'] ?? 0).toDouble();
      });
    }
  }

  Future<void> submitCarbonData() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User not logged in")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final username = getSafeUsername();

      // Create user doc if not exists
      await _firestore.collection('users').doc(_user!.uid).set({
        'username': username,
        'email': _user!.email,
      }, SetOptions(merge: true));

      // Add carbon entry
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('carbon_entries')
          .add({
        'total_carbon': totalCO2,
        'food': food,
        'electricity': electricity,
        'travel': travel,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carbon data submitted successfully!")),


      );
      //GlobalStore.totalCO2 = totalCO2;



    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Carbon Tracker 🌿",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 14.0,
              percent: (totalCO2 / 12.0).clamp(0.0, 1.0),
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${totalCO2.toStringAsFixed(1)} kg",
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("CO₂ usage today", style: TextStyle(fontSize: 16)),
                ],
              ),
              progressColor: Colors.green.shade600,
              backgroundColor: Colors.green.shade200,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
            ),

            const SizedBox(height: 30),

            // Breakdown Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text("🌍 Saved Breakdown",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),

                  // FOOD
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🍔 Food', style: TextStyle(fontSize: 15)),
                      DropdownMenu<double>(
                        initialSelection: food,
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(value: 1, label: 'Vegan (1.0 kg)'),
                          DropdownMenuEntry(value: 1.5, label: 'Veg (1.5 kg)'),
                          DropdownMenuEntry(value: 3, label: 'Non veg (3.0 kg)'),
                        ],
                        onSelected: (value) {
                          setState(() => food = value ?? 0);
                        },
                        width: 160,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ELECTRICITY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('⚡️ Electricity',
                          style: TextStyle(fontSize: 15)),
                      DropdownMenu<double>(
                        initialSelection: electricity,
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(value: 2, label: 'Low (2.0 kg)'),
                          DropdownMenuEntry(value: 3, label: 'Med (3.0 kg)'),
                          DropdownMenuEntry(value: 4, label: 'High (4.0 kg)'),
                        ],
                        onSelected: (value) {
                          setState(() => electricity = value ?? 0);
                        },
                        width: 160,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // TRAVEL
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🚗 Travel', style: TextStyle(fontSize: 15)),
                      DropdownMenu<double>(
                        initialSelection: travel,
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(value: 1, label: 'Bus (1.0 kg)'),
                          DropdownMenuEntry(value: 1.5, label: 'Bike (1.5 kg)'),
                          DropdownMenuEntry(value: 3.5, label: 'Car (3.5 kg)'),
                        ],
                        onSelected: (value) {
                          setState(() => travel = value ?? 0);
                        },
                        width: 160,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // TIP
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🌟 Tip to Lower Your Footprint",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 8),
                  Text(
                    "Unplug devices when not in use to save energy.",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // SUBMIT BUTTON
            ElevatedButton(


              onPressed: isLoading ? null : submitCarbonData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,),

              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit Today’s CO₂ Data"),
            ),
          ],
        ),
      ),
    );
  }


}


