import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nyemangati/ChoosePsychologistPage.dart';
import 'package:nyemangati/chat.dart';
import 'package:nyemangati/history.dart';
import 'package:nyemangati/homescreen.dart';
import 'package:nyemangati/lengkapi_data_user.dart';
import 'package:nyemangati/login.dart';
import 'package:nyemangati/profil.dart';
import 'package:nyemangati/schedule.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? userData; // Data pengguna
  bool isLoading = true; // Tambahkan indikator loading

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Ambil data pengguna saat halaman dimuat
  }

  // Fungsi utk mengambil data pengguna dari Realtime Database
  Future<void> _fetchUserData() async {
    try {
      setState(() {
        isLoading = true; // utk menampilkan loading
      });

      User? user = _auth.currentUser;

      if (user != null) {
        String uid = user.uid;

        // Ambil data dari node `users/<UID>` 
        DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$uid');
        final snapshot = await userRef.get();

        if (snapshot.exists) {
          setState(() {
            userData = Map<String, dynamic>.from(snapshot.value as Map);
          });
        } else {
          print("No data found for this user.");
        }
      } else {
        print("No user is logged in.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        isLoading = false; // Matikan loading
      });
    }
  }

  // Fungsi logout
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Logout dari Firebase
      // kembali ke halaman LoginScreen
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      // Menangani error jika logout gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menampilkan indikator loading jika data belum selesai dimuat
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white, // Latar belakang putih
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple), // Mengubah warna loading indicator
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // Ukuran app bar lebih tinggi
        child: ClipPath(
          clipper: BottomCurveClipper(), // Menggunakan custom clipper untuk efek kurva
          child: AppBar(
            elevation: 5,
            backgroundColor: Colors.purple,
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.2),
                  backgroundImage: AssetImage('assets/default_profile.png'),
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent, // Membuat background transparan
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      height: 250,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.list_alt_rounded, color: Colors.purple),
                            title: Text('Complete Data', style: TextStyle(color: Colors.black)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => UserForm()),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.history, color: Colors.purple),
                            title: Text('History', style: TextStyle(color: Colors.black)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MainPage()),
                              );
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.settings, color: Colors.purple),
                            title: Text('Settings', style: TextStyle(color: Colors.black)),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.logout, color: Colors.red),
                            title: Text('Logout', style: TextStyle(color: Colors.black)),
                            onTap: () {
                              Navigator.pop(context); // Menutup menu
                              _logout(); // Memanggil fungsi logout
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: _getPage(_currentIndex), // Menampilkan halaman sesuai indeks
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF8A47EB), // Warna solid ungu
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Warna shadow hitam transparan
                blurRadius: 10, // Tingkat blur shadow
                spreadRadius: 1, // Seberapa jauh shadow menyebar
                offset: const Offset(0, -3), // Posisi shadow ke atas
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: Colors.purple, // Warna ikon yang dipilih
            unselectedItemColor: Colors.black, // Warna ikon yang tidak dipilih
            backgroundColor: Colors.transparent, // Gunakan transparansi untuk memungkinkan background Container muncul
            elevation: 0, // Hilangkan elevasi
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.wb_sunny),
                label: 'Today',
              ),
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.calendarClock),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.formatListBulleted),
                label: 'Consultant List',
              ),
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.chat),
                label: 'Chat',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeScreen(userData: userData); // Kirim data pengguna ke HomeScreen
      case 1:
        return SchedulePage(); // Halaman schedule
      case 2:
        return ChoosePsychologistPage(); // Halaman consultant list
      case 3:
        return ChatScreen(); // Halaman chat
      default:
        return HomeScreen(userData: userData);
    }
  }
}

// Custom Clipper untuk memberi bentuk kurva di AppBar
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 20); // Memotong bagian bawah dengan radius 20
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
