import 'package:flutter/material.dart';

class DetailInformasiPage extends StatelessWidget {
  final Map<String, dynamic> psychologist;

  const DetailInformasiPage({super.key, required this.psychologist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade100],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Profil Psikolog',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Foto Psikolog
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: AssetImage(
                  psychologist['gender'] == 'Male'
                      ? 'assets/avatar_male.png'
                      : 'assets/avatar_female.png',
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Nama dan Status
            Text(
              psychologist['name'] ?? 'No Name',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${psychologist['satisfaction'] ?? 0}% Klien Puas',
              style: TextStyle(color: Colors.pink, fontSize: 16),
            ),
            const SizedBox(height: 15),

            // Informasi Detail
            Divider(thickness: 1, color: Colors.grey[300]),
            buildInfoRow('University', psychologist['university'] ?? 'not available'),
            buildInfoRow('No License', psychologist['license'] ?? 'not available'),
            buildInfoRow('Hospital', psychologist['hospital'] ?? 'not available'),
            buildInfoRow('Location', psychologist['location'] ?? 'not available'), // Menambahkan Location
            buildInfoRow('Description', psychologist['description'] ?? 'not available'), // Menambahkan Description

            const SizedBox(height: 20),
            Divider(thickness: 1, color: Colors.grey[300]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan baris informasi
  Widget buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.deepPurple),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
