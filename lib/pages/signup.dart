import 'package:flutter/material.dart';
import 'package:newapp/pages/home.dart';
import 'package:newapp/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;



  registration() async {


    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),

        );
        Map<String, dynamic> userInfoMap = {
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "uid": FirebaseAuth.instance.currentUser!.uid,
        };
        try {
          User? user = FirebaseAuth.instance.currentUser;
          await user?.reload(); // Force refresh
          user = FirebaseAuth.instance.currentUser;



          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .set(userInfoMap);
        }
        catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text("Firestore error: $e", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.redAccent,
            ));
        }


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account Created Successfully", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, '/home');;
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Something went wrong", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.redAccent,
          ),
        );
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEFE7),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Banner
              Stack(
                children: [
                  Image.asset('assets/images/loginpage.jpeg'),
                  const Positioned(
                    bottom: 20,
                    left: 20,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Color(0xDC000000),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Name",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xDC000000))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF74A27E), width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF74A27E), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Email",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xDC000000))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: emailController,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF74A27E), width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF74A27E), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Password",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xDC000000))),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your password' : null,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF74A27E), width: 2),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF74A27E), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Sign Up Button or Loader
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF74A27E))
                    : GestureDetector(
                  onTap: registration,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.87,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF74A27E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFEEEFE7)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an Account?"),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn()));
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
