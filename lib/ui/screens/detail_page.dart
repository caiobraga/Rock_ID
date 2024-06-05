import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/rocks.dart';

class RockDetailPage extends StatelessWidget {
  final Rock rock;

  const RockDetailPage({Key? key, required this.rock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Constants.primaryColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'BEST MATCHES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/images/rock1.png', height: 200), // Placeholder image
                    SizedBox(height: 10),
                    Text(
                      rock.rockName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'a variety of ${rock.category}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildInfoSection('Formula', rock.formula),
              _buildInfoSection('Hardness', rock.hardness.toString()),
              _buildInfoSection('Color', rock.color),
              _buildInfoSection('Magnetic', rock.isMagnetic ? 'Magnetic' : 'Non-magnetic'),
              SizedBox(height: 20),
              _buildPremiumSection(),
              SizedBox(height: 20),
              _buildHealthRisksSection(),
              SizedBox(height: 20),
              _buildImagesSection(),
              SizedBox(height: 20),
              _buildLocationsSection(),
              SizedBox(height: 20),
              _buildFAQSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Constants.primaryColor,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Constants.darkGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.amber),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Try ROCKAPP Premium for free\nClaim your offer now',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(primary: Colors.amber),
            child: Text('Go Premium'),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRisksSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Constants.darkGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HEALTH RISKS',
            style: TextStyle(
              color: Constants.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Quartz, silica, crystalline silica and flint are non-toxic materials, but very fine dust containing quartz, known as respirable crystalline silica (RCS), can cause serious and fatal lung diseases. '
            'Lapidaries should exercise caution when cutting silica.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IMAGES OF "${rock.rockName.toUpperCase()}"',
          style: TextStyle(
            color: Constants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            _buildImageCard('Quartz', 'assets/images/emerald.png'),
            _buildImageCard('Quartz', 'assets/images/emerald1.png'),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard(String title, String assetPath) {
    return Expanded(
      child: Column(
        children: [
          Image.asset(assetPath, height: 100), // Placeholder image
          Text(
            title,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOCATIONS FOR "${rock.rockName.toUpperCase()}"',
          style: TextStyle(
            color: Constants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        // Replace with actual map widgets or images
        Image.asset('assets/map.png', height: 150), // Placeholder image
      ],
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PEOPLE OFTEN ASK',
          style: TextStyle(
            color: Constants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        _buildFAQItem('Is ${rock.rockName} valuable?'),
      ],
    );
  }

  Widget _buildFAQItem(String question) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Constants.darkGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        question,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
