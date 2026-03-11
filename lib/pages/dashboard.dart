import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:newapp/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dashboard.dart';
import 'detection.dart';
import 'chatbot.dart';
import 'control.dart';
import 'Carbontrack.dart';
import 'package:newapp/utils/Userinfo.dart';
import 'Constants.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Constants.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'gloabl_store.dart';


class DashboardPage extends StatefulWidget {

  @override
  State<DashboardPage> createState() => _DashboardPageState();

}


class _DashboardPageState extends State<DashboardPage> {

  String? city;






  @override
  void initState() {
    super.initState();
    Userdata();
    setposition();
    Gemini.init(apiKey: gemini_API_key);
    fetchTip();

    // 👈 Add this line
  }

  Future<String> message() async {
    try {
      final response = await Gemini.instance.prompt(parts: [
        Part.text(
            'Give an eco tip to save carbon in one line(Give me unique )'),
      ]);
      return response?.output ?? 'No response';
    } catch (e) {
      return 'Error: $e';
    }
  }

  String ecoTip = "Loading tip...";

  void fetchTip() async {
    String tip = await message();
    setState(() {
      ecoTip = tip;
    });
  }


  Future<Position?> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the case when permission is permanently denied
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,

    );
  }

  void setposition() async {
    Position? position = await getCurrentLocation();
    if (position == null) return;

    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);
    city = placemarks[0].locality;

    getAQI(position.latitude, position.longitude); // <--- Added here
    weatherdetails();
  }




  userinfo userInfo = userinfo();
  String name = '';
  String email = '';
  Weather? weather;
  final WeatherFactory wf = WeatherFactory(API_key);


  void Userdata() async {
    String Fetchedname = await userInfo.getname();

    setState(() {
      name = Fetchedname;
    });
  }

  int? aqi;

  void getAQI(double lat, double lon) async {
    final String apiUrl =
        'https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$API_key';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        aqi = jsonData['list'][0]['main']['aqi'];
      });
    } else {
      print("Failed to fetch AQI: ${response.statusCode}");
    }
  }

  String getAqiLevel(int index) {
    if (index == 1) return "Good 🌿";
    if (index == 2) return "Fair 🌤️";
    if (index == 3) return "Moderate 😐";
    if (index == 4) return "Poor 😷";
    if (index == 5) return "Very Poor ☠️";
    return "Unknown";
  }


  void weatherdetails() async {
    String cityname = await getcity();


    wf.currentWeatherByCityName(cityname).then((w) {
      setState(() {
        weather = w;
      });
    });
  }

  String getcity() {
    return city!;
  }



  //


  @override
  Widget build(BuildContext context) {

    StreamBuilder<double>(
      stream: GlobalStore.co2Stream(),
      builder: (context, snapshot) {
        final carbon = snapshot.data ?? 0;
        return Text("$carbon");

      },
    );
    Future<double> getCarbon() async {
      double co2 = await GlobalStore.co2Stream().first;
      return co2;
    }



    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text(
          'Dashboard 🌿',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade100,
        elevation: 0,

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Welcome back, $name, 👋",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Weather + AQI Card
            Container(
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  weathericon(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          weather != null
                              ? Text(
                            "📍 $city",
                            style: TextStyle(fontSize: 16),
                          )
                              : Row(
                            children: [
                              CircularProgressIndicator(strokeWidth: 2),
                              SizedBox(width: 10),
                              Text("Getting location..."),
                            ],
                          ),
                          SizedBox(height: 10),
                          weather != null
                              ? Text(
                            "🌡️ ${weather!.temperature!.celsius!
                                .toStringAsFixed(0)}°C | ${weather!
                                .weatherDescription!.toUpperCase()}",
                            style: TextStyle(fontSize: 16),
                          )
                              : Row(
                            children: [
                              CircularProgressIndicator(strokeWidth: 2),
                              SizedBox(width: 10),
                              Text("Loading weather..."),
                            ],
                          ),
                          SizedBox(height: 10),
                          aqi != null
                              ? Text("🌫️ AQI: $aqi (${getAqiLevel(aqi!)})",
                              style: TextStyle(color: Colors.brown))
                              : Row(
                            children: [
                              CircularProgressIndicator(strokeWidth: 2),
                              SizedBox(width: 10),
                              Text("Loading AQI..."),
                            ],
                          ),

                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Eco Score & Footprint
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FutureBuilder<double>(
                  future: getCarbon(),
                  builder: (context, snapshot) {
                    double co2 = snapshot.data ?? 0;
                    double score = 100 * (1 - (co2 / 12));


                    return CircularPercentIndicator(
                      animation: true,
                      radius: 60.0,
                      lineWidth: 10.0,
                      percent: (score / 100).clamp(0.0, 1.0),

                      center: Text('${score.toStringAsFixed(0)}' , style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold
                      ),),
                      progressColor: Colors.green.shade700,
                      backgroundColor: Colors.green.shade200,
                      footer: const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text("Eco Score",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),

                    );
                  },
                ),
        FutureBuilder<double>(
          future: getCarbon(),
          builder: (context, snapshot) {
            double co2 = snapshot.data ?? 0;
            double percent = co2 / 12.0;

            return CircularPercentIndicator(
              animation: true,
              radius: 60.0,
              lineWidth: 10.0,
              percent: percent.clamp(0.0, 1.0),
              center: Text('${co2.toStringAsFixed(2)}' , style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold
              ),),
              progressColor: Colors.green.shade700,
              backgroundColor: Colors.green.shade200,
              footer: const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("Carbon Footprint",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),

            );
          },
        ),

        ],
            ),

            const SizedBox(height: 24),

            // Quick Action Tiles
            const Text("Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionTile(
                    Icons.camera_alt, "Trash Detect", Colors.orange,
                    DetectionPage()),
                _buildActionTile(Icons.games, "Games", Colors.teal, GamePage()),
                _buildActionTile(
                    Icons.chat, "Eco Chatbot", Colors.blue, EcoChatbotPage()),
                _buildActionTile(
                    Icons.show_chart, "Track Carbon", Colors.purple,
                    CarbonTrackerPage()),
              ],
            ),

            const SizedBox(height: 24),

            // Tip of the Day
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🌟 Eco Tip of the Day", style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(ecoTip, style: TextStyle(fontSize: 15)),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, Color color,
      Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget weathericon() {
    return Container(
      height: 50,
      width: 50,
      margin: EdgeInsets.only(left: 30),
      decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(
          "http://openweathermap.org/img/wn/${weather?.weatherIcon}@4x.png"),
          fit: BoxFit.cover),
          color: Colors.purple,
          borderRadius: BorderRadius.circular(40)),

    );
  }
}

