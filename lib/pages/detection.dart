import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Constants.dart';
import 'package:gemini_flutter/gemini_flutter.dart';
class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  State<DetectionPage> createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  // Future: Add image picker and ML model logic here
  File? _image;
  String? _detectedLabel;
  double? _carbonValue;

  final picker = ImagePicker();

  // ----------------------------
  // PICK IMAGE FROM GALLERY
  // ----------------------------
  Future<void> pickImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        _image = File(file.path);
        _detectedLabel = null;
        _carbonValue = null;
      });
    }
  }

  // ----------------------------
  // TAKE IMAGE FROM CAMERA
  // ----------------------------
  Future<void> takeImage() async {
    final XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() {
        _image = File(file.path);
        _detectedLabel = null;
        _carbonValue = null;
      });
    }
  }


  Future<String> detectTrashGemini(File imageFile) async {
    final gemini = Gemini.instance;
    final imgBytes = imageFile.readAsBytesSync();

    try {
      // Use the textAndImage method for multimodal input
      final value = await gemini.textAndImage(
        text: "Identify this waste item and classify it as plastic, metal, organic, glass, or paper and give evrything as commas seperated for example      plastic,metal  . if no waste is detected just give as 'None'  "  ,
        images: [imgBytes],
      );

      // Use the same safe output access as your working code
      return value?.output ?? "No response received.";

    } catch (e) {
      // Use a try-catch for error handling
      log('textAndImageInput', error: e);
      return "Error: ${e.toString()}";
    }
  }




  // ----------------------------
  // CARBON CALCULATION LOGIC
  // ----------------------------
  double carbonForItem(String item) {
    item = item.toLowerCase();

    if (item.contains("plastic")) return 0.08;
    if (item.contains("bottle")) return 0.08;
    if (item.contains("can")) return 0.15;
    if (item.contains("paper")) return 0.02;
    if (item.contains("cup")) return 0.03;
    if (item.contains("glass")) return 0.20;
    if (item.contains("food")) return 0.30;
    if (item.contains("metal")) return 0.10;
    if(item.contains ("none")) return 0;


    return 0; // default fallback
  }

  double calculateCarbon(String detectedText) {
    final items = detectedText.split(",");
    double total = 0;

    for (var item in items) {
      total += carbonForItem(item);
    }
    return total;
  }

  // ----------------------------
  // SAVE TO FIREBASE
  // ----------------------------
  Future saveCarbonToFirebase(double co2) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('carbon_entries')
        .add({
      "carbon": co2,
      "timestamp": Timestamp.now(),
    });
  }

  // ----------------------------
  // MAIN DETECTION FLOW
  // ----------------------------
  Future<void> runDetection() async {
    if (_image == null) return;

    // 1) detect with Gemini
    final detected = await detectTrashGemini(_image!);

    // 2) calculate carbon
    final carbon = calculateCarbon(detected);

    // 3) save to Firebase
    await saveCarbonToFirebase(carbon);

    // 4) update UI
    setState(() {
      _detectedLabel = detected;
      _carbonValue = carbon;
    });
  }

  @override
  void initState() {
    super.initState();
    Gemini.init(apiKey: gemini_API_key); // ✅ Your API key must be correct
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Trash Detection",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // IMAGE PREVIEW
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Center(
                child: _image != null
                    ? Image.file(_image!)
                    : const Icon(Icons.image, size: 80),
              ),
            ),

            const SizedBox(height: 20),

            // PICK BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton("Upload Image", Icons.upload_file, pickImage),
                _buildActionButton("Take Picture", Icons.camera_alt, takeImage),
              ],
            ),

            const SizedBox(height: 30),

            // DETECT BUTTON
            ElevatedButton.icon(
              onPressed: runDetection,
              icon: const Icon(Icons.search),
              label: const Text("Detect Waste"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),

            const SizedBox(height: 30),

            // RESULTS SECTION
            if (_detectedLabel != null)
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB84BFF), Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detected: $_detectedLabel",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_carbonValue != null)
                      Text(
                        "\nCarbon Impact: ${_carbonValue!.toStringAsFixed(3)} kg CO₂",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Function() onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

