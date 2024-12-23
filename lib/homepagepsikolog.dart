import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:nyemangati/lengkapi_data_psikolog.dart';
import 'package:nyemangati/profilPsikolog.dart';

class PsychologistDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const PsychologistDashboard({required this.userData, Key? key}) : super(key: key);

  @override
  State<PsychologistDashboard> createState() => _PsychologistDashboardState();
}

class _PsychologistDashboardState extends State<PsychologistDashboard> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> todayAppointments = [];
  List<Map<String, dynamic>> upcomingAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentsWithUserNames();
  }

  Future<void> _fetchAppointmentsWithUserNames() async {
    try {
      final snapshot = await _database.child('appointments').get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> loadedToday = [];
        List<Map<String, dynamic>> loadedUpcoming = [];
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

        for (var entry in data.entries) {
          final appointment = Map<String, dynamic>.from(entry.value);

          if (appointment['psychologistName'] == widget.userData['name']) {
            final userId = appointment['userId'];
            if (userId != null) {
              final userSnapshot = await _database.child('users/$userId').get();
              if (userSnapshot.exists) {
                final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
                appointment['userName'] = userData['name'] ?? 'Unknown User';
              } else {
                appointment['userName'] = 'Unknown User';
              }
            } else {
              appointment['userName'] = 'Unknown User';
            }

            if (appointment['date'] == today) {
              loadedToday.add(appointment);
            } else {
              loadedUpcoming.add(appointment);
            }
          }
        }

        setState(() {
          todayAppointments = loadedToday;
          upcomingAppointments = loadedUpcoming;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load appointments.")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          "Welcome, ${widget.userData['name']}",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          tooltip: 'View Profile',
          onPressed: () {
            // Navigasi ke halaman profil psikolog
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PsychologistProfileScreen(),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Lengkapi Data',
            onPressed: () {
              // Navigasi ke halaman lengkapi data psikolog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PsychologistForm(userData: widget.userData),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Appointments Today",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  todayAppointments.isEmpty
                      ? const Center(child: Text("No appointments today."))
                      : _buildAppointmentList(todayAppointments),

                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "Upcoming Appointments",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  upcomingAppointments.isEmpty
                      ? const Center(child: Text("No upcoming appointments."))
                      : _buildAppointmentList(upcomingAppointments),
                ],
              ),
            ),
    );
  }

  Widget _buildAppointmentList(List<Map<String, dynamic>> appointments) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Appointment",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: const NetworkImage('https://via.placeholder.com/150'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['userName'] ?? 'No Name',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      appointment['session'] ?? 'No Session',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                const SizedBox(width: 5),
                Text(
                  appointment['date'] ?? 'No Date',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey, size: 16),
                const SizedBox(width: 5),
                Text(
                  appointment['time'] ?? 'No Time',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
