import 'package:flutter/material.dart';
import '../asset_manifest.dart';
import '../main.dart';

import '../widgets/rabbit_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        RabbitPrecaster.precache(context);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFFF9EBEA), // Warm vintage paper background matching the image
      body: SafeArea(
        child: GestureDetector(
          onTap: _navigateToHome,
          child: Stack(
            children: [
              // Splash image
              Positioned.fill(
                child: Image.asset(
                  AppAssets.splash,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '1734',
                          style: TextStyle(
                            fontFamily: 'Essays1743',
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Your little space to write, organize, and create.',
                          style: TextStyle(
                            fontFamily: 'Essays1743',
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Enter button
              Positioned(
                bottom: 30,
                left: 40,
                right: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 3,
                  ),
                  onPressed: _navigateToHome,
                  child: const Text(
                    'Enter Notebook  ➔',
                    style: TextStyle(
                      fontFamily: 'Essays1743',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigationShell()),
    );
  }
}
