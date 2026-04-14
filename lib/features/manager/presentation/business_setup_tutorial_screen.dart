import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_container.dart';

class BusinessSetupTutorialScreen extends StatefulWidget {
  const BusinessSetupTutorialScreen({super.key});

  @override
  State<BusinessSetupTutorialScreen> createState() => _BusinessSetupTutorialScreenState();
}

class _BusinessSetupTutorialScreenState extends State<BusinessSetupTutorialScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> _slides = [
    {
      "title": "Welcome to Your Business CMS",
      "desc": "Congratulations! Your venue officially has verified access to our backend Management Hub. Let's walk through how to build your profile out.",
      "icon": "business_center",
    },
    {
      "title": "Configure Your Modules",
      "desc": "Your Store, Programs, Specials, and Events are globally invisible until you build them out inside the Hub. Tap the corresponding Module dynamically to map your logic.",
      "icon": "auto_awesome_mosaic",
    },
    {
      "title": "Superadmin Access",
      "desc": "FreeSpc Superadmins manually process any payouts & banking verifications dynamically behind the scenes. Ping us at support@freespc.com to open banking channels natively.",
      "icon": "shield",
    }
  ];

  IconData _getIconData(String name) {
    switch (name) {
      case 'business_center': return Icons.business_center;
      case 'auto_awesome_mosaic': return Icons.auto_awesome_mosaic;
      case 'shield': return Icons.shield;
      default: return Icons.check_circle;
    }
  }

  void _nextSlide() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getIconData(slide['icon']!), size: 100, color: Colors.amber),
                        const SizedBox(height: 48),
                        Text(
                          slide['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          slide['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? Colors.amber : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _nextSlide,
                      child: Text(
                        _currentIndex == _slides.length - 1 ? "ENTER HUB" : "NEXT",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
