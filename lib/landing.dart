import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nyemangati/onboarding.dart';
import 'login.dart'; 

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LandingScreen(),
    );
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8A47EB), // Warna gradasi atas
              Color(0xFFB25EF8), // Warna gradasi bawah
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset(
                'assets/logo1.png', // Path gambar dari asset
                height: 250, // Tinggi gambar
                fit: BoxFit.contain, // Menjaga proporsi gambar tetap rapi
              ),
            ),
            // Tombol Sign Up dengan Email
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Navigasi ke halaman SignUpPage
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>  OnboardingScreen()),
                    );
                  },
                  child: const Text(
                    'Sign up with email',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "or use social sign up",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 20),
                // Tombol Media Sosial
                SocialButton(
                  icon: FontAwesomeIcons.google,
                  iconColor: const Color.fromARGB(255, 222, 54, 244),
                  text: "Continue with Google",
                  color: Colors.white,
                  onPressed: () async {
                  },
                ),
                SocialButton(
                  icon: Icons.facebook,
                  text: "Continue with Facebook",
                  color: Colors.white,
                  iconColor: Colors.blue,
                  onPressed: () async {
                  },
                ),
                SocialButton(
                  icon: Icons.apple,
                  text: "Continue with Apple",
                  color: Colors.white,
                  iconColor: Colors.black,
                  onPressed: () async {
                  },
                ),
              ],
            ),
            // Footer dengan Navigasi ke Log In
            RichText(
              text: TextSpan(
                text: "Already have account? ",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                children: [
                  TextSpan(
                    text: "Log In",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Navigasi ke halaman LoginPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  LoginPage()),
                        );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// Social Button Widget
class SocialButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed; // Menambahkan onPressed

  const SocialButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
    required this.iconColor,
    required this.onPressed, // Menginisialisasi onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextButton(
          onPressed: onPressed, // Memanggil fungsi autentikasi
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
