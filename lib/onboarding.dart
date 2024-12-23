import 'package:flutter/material.dart';

import 'package:nyemangati/signup.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                OnboardingSlide(
                  image: 'assets/slide1.png',
                  title: 'Pause and Embrace Peace',
                  description:
                      'In the rush of everyday life, it\'s okay to take a moment to pause. Allow yourself to breathe, reflect, and reconnect with your inner peace. We are here to guide you on this path.',
                ),
                OnboardingSlide(
                  image: 'assets/slide2.png',
                  title: 'Discover Your Best Self',
                  description:
                      'Your emotions and thoughts matter. Learn to understand and manage them with the right tools and resources. Together, we can help you uncover the best version of yourself, one step at a time.',
                ),
                OnboardingSlide(
                  image: 'assets/slide3.png',
                  title: 'Start Your Healing Journey',
                  description:
                      'Take the first step toward mental clarity and emotional resilience. We\'re here to support you every step of the way.',
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 5),
                height: 10,
                width: _currentPage == index ? 20 : 10,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.purple : Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          Container(
             decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.shade300, // Warna bayangan
                            blurRadius: 8, // Tingkat blur
                            offset: const Offset(0, 4), // Posisi bayangan (timbul ke bawah)
                          ),
                        ],
                      ),
           
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                if (_currentPage < 2) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  // Navigasi ke halaman sign up
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(),
                    ),
                  );
                }
              },
              child: Text(
                _currentPage < 2 ? 'Next' : 'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingSlide({
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 300),
          SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

