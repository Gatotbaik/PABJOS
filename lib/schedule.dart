import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  // Fungsi untuk mengambil data dari Firebase
  Future<void> _fetchAppointments() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to view your schedule")),
      );
      return;
    }

    try {
      final snapshot = await _database
          .child('appointments')
          .orderByChild('userId')
          .equalTo(user.uid)
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          _appointments = data.values
              .map((e) => Map<String, dynamic>.from(e))
              .where((appointment) =>
                  appointment['status'] == 'confirmed' &&
                  appointment['paymentStatus'] == 'paid')
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          _appointments = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching appointments: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load schedule")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(), // Loading Indicator
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _appointments.isNotEmpty
                ? Column(
                    children: _buildScheduleCards(filterToday: true),
                  )
                : Center(child: Text('No appointments for today')),

            const SizedBox(height: 20),
            const Text(
              'Upcoming Schedule',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _appointments.isNotEmpty
                ? Column(
                    children: _buildScheduleCards(filterToday: false),
                  )
                : Center(child: Text('No upcoming appointments')),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScheduleCards({required bool filterToday}) {
    final today = DateTime.now();
    return _appointments
        .where((appointment) {
          final dateParts = appointment['date'].split('/');
          final appointmentDate = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );

          if (filterToday) {
            return appointmentDate.year == today.year &&
                appointmentDate.month == today.month &&
                appointmentDate.day == today.day;
          }
          return appointmentDate.isAfter(today);
        })
        .map((appointment) {
          return ScheduleCard(
            name: 'Psychologist: ${appointment['psychologistName'] ?? 'Unknown'}',
            category: 'Hospital: ${appointment['hospital'] ?? 'Online'}',
            date: 'Date: ${appointment['date'] ?? ''}',
            time: 'Time: ${appointment['time'] ?? ''}',
            gender: appointment['psychologistGender'] ?? 'Unknown', // Tambahkan gender psikolog
          );
        })
        .toList();
  }
}

class ScheduleCard extends StatelessWidget {
  final String name;
  final String category;
  final String date;
  final String time;
  final String gender; // Tambahkan parameter gender

  const ScheduleCard({
    super.key,
    required this.name,
    required this.category,
    required this.date,
    required this.time,
    required this.gender, // Tambahkan parameter gender
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF8F3FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage(
                  gender == 'Male'
                      ? 'assets/avatar_male.png' // Avatar untuk laki-laki
                      : 'assets/avatar_female.png', // Avatar untuk perempuan
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 20, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
