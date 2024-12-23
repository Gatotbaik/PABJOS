import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nyemangati/payment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppointmentPage(psychologist: {},),
    );
  }
}

class AppointmentPage extends StatefulWidget {
  final Map<String, dynamic> psychologist; // Menambahkan parameter psikolog

  // Konstruktor untuk menerima data psikolog
  const AppointmentPage({super.key, required this.psychologist});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String? _selectedSession = "Online"; // Default session
  String? _selectedHospital; // Selected hospital for offline session(hanya khusus sesi offline)
  DateTime? _selectedDate; // Untuk menyimpan tanggal yang dipilih
  String? _selectedTime; // Untuk menyimpan waktu yang dipilih

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Fungsi untuk menyimpan data ke Firebase
 Future<void> _saveAppointmentToFirebase() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You must be logged in to create an appointment")),
    );
    return;
  }

  if (_selectedSession == null || _selectedDate == null || _selectedTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please complete all fields!")),
    );
    return;
  }

  try {
    final appointmentRef = _database.child('appointments').push();
    final appointmentId = appointmentRef.key;

    // Simpan appointment sebagai pending dan unpaid
    await appointmentRef.set({
      'userId': user.uid,
      'psychologistId': widget.psychologist['id'],  // Menyimpan ID psikolog
      'psychologistName': widget.psychologist['name'],  // Menyimpan nama psikolog
      'session': _selectedSession,
      'hospital': _selectedSession == "Offline" ? _selectedHospital : "Online",
      'date': "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
      'time': _selectedTime,
      'status': 'pending', // Status awal
      'paymentStatus': 'unpaid', // Status pembayaran
      'createdAt': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment created. Please proceed to payment.")),
    );

    // Navigasi ke halaman pembayaran
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentPage(appointmentId: appointmentId!)),
    );

    // Reset form fields after the payment is successful
    _resetForm(); // Memanggil fungsi untuk mengosongkan form
  } catch (e) {
    print("Error saving appointment: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to create appointment.")),
    );
  }
}

// Fungsi untuk mengosongkan form setelah pembayaran
void _resetForm() {
  setState(() {
    _selectedSession = null;
    _selectedDate = null;
    _selectedTime = null;
    _selectedHospital = null; // Jika ada, reset juga hospital (misalnya untuk offline session)
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Appointment',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan nama psikolog yang dipilih
            Text(
              'Selected Psychologist: ${widget.psychologist['name']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Pilih Tanggal
            const Text('Select Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            TextFormField(
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                hintText: _selectedDate == null
                    ? "Pick a date"
                    : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 20),

            // Pilih Waktu
            const Text('Select Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildTimeButton("08.00"),
                _buildTimeButton("09.00"),
                _buildTimeButton("10.00"),
                _buildTimeButton("11.00"),
                _buildTimeButton("12.00"),
                _buildTimeButton("13.00"),
              ],
            ),
            const SizedBox(height: 20),

            // Sesi Konsultasi
            const Text('Select a Consultation Session',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Online'),
                  value: 'Online',
                  groupValue: _selectedSession,
                  onChanged: (value) {
                    setState(() {
                      _selectedSession = value;
                      _selectedHospital = null; // Reset hospital jika Online
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Offline'),
                  value: 'Offline',
                  groupValue: _selectedSession,
                  onChanged: (value) {
                    setState(() {
                      _selectedSession = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dropdown Hospital (jika Offline dipilih)
            if (_selectedSession == "Offline") ...[
              const Text('Choose a Hospital',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedHospital,
                items: <String>['Hospital A', 'Hospital B', 'Hospital C'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedHospital = newValue;
                  });
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                hint: const Text("Select a hospital"),
              ),
            ],

            const Spacer(),
            ElevatedButton(
              onPressed: _saveAppointmentToFirebase,
              style: ElevatedButton.styleFrom(
                backgroundColor:  Colors.purple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(String time) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTime = time;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedTime == time
            ? const Color(0xFF6A1B9A)
            : Colors.purple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(time),
    );
  }
}
