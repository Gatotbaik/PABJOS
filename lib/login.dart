import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nyemangati/homepage.dart';
import 'package:nyemangati/homepagepsikolog.dart';
// Mengimpor halaman PsychologistDashboard

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controller untuk input
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false; // Indikator loading

  // Fungsi Login
  Future<void> _loginWithEmailAndPassword() async {
    setState(() {
      isLoading = true; // buat loading indicator
    });

    try {
      print("Attempting to log in with email: ${usernameController.text.trim()}");

      // Login dengan email dan password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("Login successful. User: ${userCredential.user}");

      // Ambil UID pengguna
      String uid = userCredential.user!.uid;
      print("User UID: $uid");

      // Ambil data pengguna dari Firebase Realtime Database
      DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$uid');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
        print("User Data: $userData");

        // Periksa apakah email pengguna berakhiran "@psikolog.com"
        if (userCredential.user?.email?.endsWith('@psikolog.com') ?? false) {
          // Jika iya, navigasikan ke PsychologistDashboard dan kirimkan userData
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PsychologistDashboard(userData: userData), // Kirim data ke PsychologistDashboard
              ),
            );
          }
        } else {
          // Jika bukan, navigasikan ke HomePage
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // Navigasi ke HomePage
            );
          }
        }
      } else {
        print("No data found for this user.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No user data found in database.")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuth Error: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.message}')),
      );
    } catch (e) {
      print("Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // sesi akhir utk loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // Bagian gambar di atas
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Image.asset(
                'assets/logo1.png', // Ganti dengan path gambar Anda
                width: 350,
                height: 285,
              ),
            ),
            // Expanded digunakan untuk mendorong form ke tengah layar
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Input Email
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Input Password
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.shade300,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _loginWithEmailAndPassword,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            backgroundColor: Colors.purple,
                            minimumSize: const Size(double.infinity, 50),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'or',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIconButton(
                            icon: FontAwesomeIcons.google,
                            iconColor: const Color.fromARGB(255, 222, 54, 244),
                            onPressed: () => print("Login with Google"),
                          ),
                          const SizedBox(width: 20),
                          _buildSocialIconButton(
                            icon: FontAwesomeIcons.apple,
                            iconColor: Colors.black,
                            onPressed: () => print("Login with Apple"),
                          ),
                          const SizedBox(width: 20),
                          _buildSocialIconButton(
                            icon: FontAwesomeIcons.facebook,
                            iconColor: Colors.blue,
                            onPressed: () => print("Login with Facebook"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Tombol Media Sosial dengan Ikon
  Widget _buildSocialIconButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(15),
        elevation: 4,
      ),
      child: Icon(icon, color: iconColor, size: 30),
    );
  }
}
