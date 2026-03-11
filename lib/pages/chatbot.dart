import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'Constants.dart';

class EcoChatbotPage extends StatefulWidget {
  const EcoChatbotPage({super.key});

  @override
  State<EcoChatbotPage> createState() => _EcoChatbotPageState();
}

class _EcoChatbotPageState extends State<EcoChatbotPage> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Hello! How can I help you reduce your carbon footprint today?",
      "isUser": false
    },
  ];
 bool isLoading = false;


  @override
  void initState() {
    super.initState();
    Gemini.init(apiKey: gemini_API_key); // ✅ Your API key must be correct
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"text": text, "isUser": true});
      isLoading = true;
    });
    _controller.clear();

    try {
      final value = await Gemini.instance.prompt(
        parts: [Part.text(text)],
      );
      setState(() {
        _messages.add({
          "text": value?.output ?? "No response received.",

          "isUser": false
        }
        );
        isLoading=false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "text": "❌ Error: ${e.toString()}",
          "isUser": false

        });
        isLoading=false;
      });
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy, color: Colors.green, size: 18),
            ),
            SizedBox(width: 8),
            Text("EcoX Chat", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg["isUser"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: msg["isUser"]
                          ? Colors.green.shade300
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                        Radius.circular(msg["isUser"] ? 16 : 0),
                        bottomRight:
                        Radius.circular(msg["isUser"] ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["isUser"]
                            ? Colors.white
                            : Colors.green.shade900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: CircularProgressIndicator(strokeAlign: 5, strokeWidth: 4,),

            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
