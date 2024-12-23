import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class PsychologistForm extends StatefulWidget {
  final Map<String, dynamic> userData;

  const PsychologistForm({required this.userData, Key? key}) : super(key: key);

  @override
  _PsychologistFormState createState() => _PsychologistFormState();
}

class _PsychologistFormState extends State<PsychologistForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedGender;
  String? _selectedEducation;
  String? _selectedCategory;

  Map<String, dynamic>? existingData;

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _licenseController.dispose();
    _universityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void loadProfileData() {
    setState(() {
      existingData = widget.userData;
      _nameController.text = existingData?['name'] ?? '';
      _phoneController.text = existingData?['phone'] ?? '';
      _locationController.text = existingData?['location'] ?? '';
      _licenseController.text = existingData?['license'] ?? '';
      _universityController.text = existingData?['university'] ?? '';
      _descriptionController.text = existingData?['description'] ?? '';
      _selectedGender = existingData?['gender'] ?? '';
      _selectedEducation = existingData?['education'] ?? '';
      _selectedCategory = existingData?['category'] ?? '';
    });
  }

  void submitForm() {
    // Process form submission, update user data in Firebase
    final userRef = FirebaseDatabase.instance.ref('users/${widget.userData['id']}');
    userRef.update({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'location': _locationController.text,
      'license': _licenseController.text,
      'university': _universityController.text,
      'description': _descriptionController.text,
      'gender': _selectedGender,
      'education': _selectedEducation,
      'category': _selectedCategory,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lengkapi Data Psikolog'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _licenseController,
              decoration: const InputDecoration(labelText: 'License'),
            ),
            TextField(
              controller: _universityController,
              decoration: const InputDecoration(labelText: 'University'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: ['Male', 'Female']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedEducation,
              decoration: const InputDecoration(labelText: 'Education'),
              items: ['Bachelor', 'Master', 'Doctorate']
                  .map((education) => DropdownMenuItem(
                        value: education,
                        child: Text(education),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEducation = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['Psychologist', 'Therapist']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitForm,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
