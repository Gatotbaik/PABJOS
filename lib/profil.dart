import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nyemangati/login.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late Future<Map<String, dynamic>> userData;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      userData = fetchUserData(currentUser!.uid);
    } else {
      userData = Future.error('User not logged in');
    }
  }

  Future<Map<String, dynamic>> fetchUserData(String userId) async {
    final snapshot = await _database.child('users/$userId').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    } else {
      throw Exception('No data found for user ID: $userId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: ClipPath(
          clipper: CustomAppBarClipper(),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.purple,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Profile',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  // Profile Picture with Gender-based Avatar
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: data['photoUrl'] != null
                            ? NetworkImage(data['photoUrl'])
                            : AssetImage(
                                data['gender'] == 'Male'
                                    ? 'assets/avatar_male.png'
                                    : 'assets/avatar_female.png',
                              ) as ImageProvider,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Profile Information Fields
                  buildInfoField('Name', data['name'] ?? '-'),
                  buildInfoField('Phone Number', data['phone'] ?? '-'),
                  buildInfoField('Location', data['location'] ?? '-'),
                  buildInfoField('Gender', data['gender'] ?? '-'),
                  buildInfoField('Education', data['education'] ?? '-'),
                  SizedBox(height: 30),

                  // Logout Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Logout logic
                        await FirebaseAuth.instance.signOut();
                        // Navigate to login page and clear previous route stack
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.purple,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Logout',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                'No data available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 2, size.height,
      size.width, size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
