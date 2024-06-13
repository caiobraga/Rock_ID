import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Spacer(),
              Text(
                'GET FULL ACCESS\nWith ROCKAPP Pro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              FeatureItem(
                icon: Icons.camera,
                text: 'Unlimited coin identifications',
              ),
              FeatureItem(
                icon: Icons.more,
                text: 'Infinite coin collections',
              ),
              FeatureItem(
                icon: Icons.no_adult_content,
                text: 'Ad-free experience',
              ),
              SizedBox(height: 20),
              Text(
                'JUST \$24.99 PER YEAR\nAuto-renewable. Cancel anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Free trial enabled',
                    style: TextStyle(color: Colors.white),
                  ),
                  Switch(
                    value: true,
                    onChanged: (bool value) {
                      // Switch action
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Continue action
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.brown, // Button color
                ),
                child: Text('Continue'),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Terms of Use action
                      },
                      child: Text(
                        'Terms of Use',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      '|',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        // Privacy Policy action
                      },
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}