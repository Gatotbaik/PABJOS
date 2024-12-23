import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PaymentPage extends StatefulWidget {
  final String appointmentId; // ID janji temu yang dibuat

  const PaymentPage({Key? key, required this.appointmentId}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isLoading = false;

  // Fungsi untuk menyelesaikan pembayaran
  Future<void> _completePayment() async {
    final DatabaseReference appointmentRef =
        FirebaseDatabase.instance.ref('appointments/${widget.appointmentId}');

    try {
      setState(() {
        isLoading = true;
      });

      // Simulasi pembayaran (ganti dengan integrasi Payment Gateway)
      await Future.delayed(const Duration(seconds: 2));

      // Perbarui status pembayaran dan konfirmasi janji temu di Firebase
      await appointmentRef.update({
        'paymentStatus': 'paid', // Tandai sebagai sudah dibayar
        'status': 'confirmed', // Konfirmasi appointment
      });

      // Tampilkan notifikasi berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful! Appointment confirmed.")),
      );

      // Navigasi kembali ke jadwal atau halaman utama
      Navigator.pop(context, true); // Kembali dengan hasil sukses
    } catch (e) {
      print("Error completing payment: $e");

      // Tampilkan notifikasi kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed. Please try again.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Loading indicator saat proses pembayaran
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Informasi Pembayaran
                  const Text(
                    "Your Appointment",
                    style: TextStyle(color: Colors.black,fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Session Fee: \$50.00",
                    style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 68, 68, 68)),
                  ),
                  const SizedBox(height: 40),

                  // Tombol Bayar
                  ElevatedButton(
                    onPressed: _completePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 216, 86, 255),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Pay Now",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
