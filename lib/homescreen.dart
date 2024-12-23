import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const HomeScreen({this.userData, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Map<String, int> feelings = {"Sad": 0, "Happy": 0, "Stress": 0};
  bool isLoading = true;

  final List<Map<String, String>> articles = [
    {
      "title": "How to Improve Your Mental Health",
      "description": "Discover simple techniques to manage stress and improve your overall mental health.",
      "imagePath": "assets/artikel1.jpg",
      "url": "https://www.google.com",
    },
    {
      "title": "Benefits of Gratitude",
      "description": "Learn how practicing gratitude daily can positively impact your happiness and relationships.",
      "imagePath": "assets/artikel2.jpg",
      "url": "https://lifestyle.kompas.com/read/2024/03/21/090900320/7-cara-meningkatkan-kesehatan-dengan-bersyukur?utm_source=chatgpt.com#google_vignette",
    },
    {
      "title": "Understanding Stress",
      "description": "An insightful guide into understanding the effects of stress and how to overcome it.",
      "imagePath": "assets/artikel3.jpg",
      "url": "https://example.com/understanding-stress",
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchFeelings();
  }

  Future<void> _fetchFeelings() async {
    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to view feelings")),
      );
      return;
    }

    try {
      final snapshot = await _database.child('feelings/${user.uid}').get();

      if (snapshot.exists) {
        final rawData = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          feelings = {
            "Sad": int.tryParse(rawData["Sad"].toString()) ?? 0,
            "Happy": int.tryParse(rawData["Happy"].toString()) ?? 0,
            "Stress": int.tryParse(rawData["Stress"].toString()) ?? 0,
          };
          isLoading = false;
        });
      } else {
        setState(() {
          feelings = {"Sad": 0, "Happy": 0, "Stress": 0};
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching feelings: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _navigateToFeelingInput() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeelingInputPage()),
    );

    if (result == true) {
      _fetchFeelings();
    }
  }

  Future<void> _openArticleUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the article")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.userData != null) ...[
              Text(
                "Welcome, ${widget.userData!['name']}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 16),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildFeelingGraph(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToFeelingInput,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, const Color.fromARGB(255, 230, 64, 245)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  child: const Text(
                    "How's your feelings?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildArticleSlider(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeelingGraph() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withOpacity(0.1), Colors.blue.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your Feelings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _progressIndicator("Sad", feelings["Sad"] ?? 0, Colors.orange),
              _progressIndicator("Happy", feelings["Happy"] ?? 0, const Color.fromARGB(255, 0, 135, 245)),
              _progressIndicator("Stress", feelings["Stress"] ?? 0, const Color.fromARGB(255, 255, 0, 0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressIndicator(String label, int progress, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: progress / 100,
                strokeWidth: 8,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                backgroundColor: color.withOpacity(0.2),
              ),
            ),
            Text(
              '$progress%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArticleSlider() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return _buildArticleCard(articles[index]);
        },
      ),
    );
  }

  Widget _buildArticleCard(Map<String, String> article) {
    return GestureDetector(
      onTap: () {
        if (article['url'] != null) {
          _openArticleUrl(article['url']!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No URL available for this article")),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            gradient: LinearGradient(
              colors: [Colors.purple.withOpacity(0.8), Colors.blue.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article['imagePath'] != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.asset(
                    article['imagePath']!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article['description'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeelingInputPage extends StatefulWidget {
  @override
  _FeelingInputPageState createState() => _FeelingInputPageState();
}

class _FeelingInputPageState extends State<FeelingInputPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double _sadValue = 50;
  double _happyValue = 50;
  double _stressValue = 50;

  Future<void> _saveFeelings() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to save feelings")),
      );
      return;
    }

    try {
      await _database.child('feelings/${user.uid}').set({
        'Sad': _sadValue.toInt(),
        'Happy': _happyValue.toInt(),
        'Stress': _stressValue.toInt(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print("Data saved to Firebase successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feelings saved successfully!")),
      );
      Navigator.pop(context, true); // Kembali dengan hasil berhasil
    } catch (e) {
      print("Error saving feelings: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save feelings.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Input Feelings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSlider("Sad", _sadValue, (value) {
              setState(() {
                _sadValue = value;
              });
            }),
            _buildSlider("Happy", _happyValue, (value) {
              setState(() {
                _happyValue = value;
              });
            }),
            _buildSlider("Stress", _stressValue, (value) {
              setState(() {
                _stressValue = value;
              });
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveFeelings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Save Feelings", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "${value.toInt()}%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.purple,
            inactiveTrackColor: Colors.grey.shade300,
            trackHeight: 8.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
            thumbColor: Colors.purple,
            overlayColor: Colors.purple.withOpacity(0.2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            activeTickMarkColor: Colors.purple,
            inactiveTickMarkColor: Colors.grey,
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
