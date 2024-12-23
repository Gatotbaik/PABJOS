import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nyemangati/appointment.dart';
import 'package:nyemangati/detailInformasi.dart';

class ChoosePsychologistPage extends StatefulWidget {
  const ChoosePsychologistPage({super.key});

  @override
  _ChoosePsychologistPageState createState() => _ChoosePsychologistPageState();
}

class _ChoosePsychologistPageState extends State<ChoosePsychologistPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String selectedCategory = 'Career';
  List<Map<String, dynamic>> psychologists = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPsychologists();
  }

  void fetchPsychologists() async {
    setState(() {
      isLoading = true;
    });
    try {
      final snapshot = await _database
          .child('psychologists')
          .orderByChild('category')
          .equalTo(selectedCategory)
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          psychologists = data.values.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        setState(() {
          psychologists = [];
        });
      }
    } catch (e) {
      print("Error fetching psychologists: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Kategori pilihan psikolog dengan tampilan modern
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Career', 'Family', 'Romance', 'Education', 'Personal']
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (isSelected) {
                        setState(() {
                          selectedCategory = category;
                          fetchPsychologists();
                        });
                      },
                      selectedColor: const Color.fromARGB(255, 202, 39, 247),
                      backgroundColor: const Color.fromARGB(255, 191, 191, 191),
                      labelStyle: TextStyle(color: Colors.white),
                      shadowColor: Colors.black.withOpacity(0.2),
                      elevation: 5,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Daftar psikolog
        Expanded(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                )
              : psychologists.isEmpty
                  ? Center(child: Text('No psychologists available in this category'))
                  : SingleChildScrollView(
                      child: Column(
                        children: psychologists.map((psychologist) {
                          return GestureDetector(
                            onTap: () {
                              final selectedPsychologist = psychologist;

                              // Navigasi ke halaman DetailInformasiPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailInformasiPage(psychologist: selectedPsychologist),
                                ),
                              );
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                              shadowColor: Colors.black.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.grey[300],
                                            backgroundImage: psychologist['photoUrl'] != null
                                                ? NetworkImage(psychologist['photoUrl'])
                                                : AssetImage(
                                                    psychologist['gender'] == 'Male'
                                                        ? 'assets/avatar_male.png'
                                                        : 'assets/avatar_female.png',
                                                  ) as ImageProvider,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                psychologist['name'] ?? 'No Name',
                                                style: TextStyle(
                                                    fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                '${psychologist['satisfaction'] ?? 0}% Satisfied Client',
                                                style: TextStyle(
                                                    color: Colors.orange, fontSize: 14),
                                              ),
                                              Text(
                                                '${psychologist['university'] ?? 'Unknown'} ',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Text(
                                                'No License: ${psychologist['license'] ?? 'N/A'}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (psychologist['isOnline'] ?? false)
                                          Icon(Icons.circle, color: const Color.fromARGB(255, 112, 240, 116), size: 12),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton.icon(
                                          icon: Icon(
                                            Icons.calendar_today,
                                            color: Colors.white,
                                          ),
                                          label: Text('Appointment', style: TextStyle(color: Colors.white)),
                                          onPressed: () {
                                            final selectedPsychologist = psychologists[psychologists.indexOf(psychologist)];

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AppointmentPage(psychologist: selectedPsychologist),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          icon: Icon(Icons.chat_bubble_rounded, color: Colors.white),
                                          label: Text('Chat', style: TextStyle(color: Colors.white)),
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                            backgroundColor: const Color.fromARGB(255, 202, 39, 247),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
        ),
      ],
    );
  }
}
