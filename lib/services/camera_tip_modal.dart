import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraTipModalService {
  Future<void> show(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTimeCamera') ?? true;

    if (isFirstTime) {
      await prefs.setBool('isFirstTimeCamera', false);
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const Icon(Icons.info, color: Colors.white),
                    const Icon(Icons.flash_on, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'SNAP TIPS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTip(
                  Icons.center_focus_strong,
                  'Place the rock in the center of the frame',
                ),
                _buildTip(
                  Icons.wb_sunny,
                  'Make sure the rock is well-lit and the image isn\'t blurry.',
                ),
                _buildTip(
                  Icons.straighten,
                  'Stand as close to the rock as you can, checking that it fits in the frame.',
                ),
                _buildTip(
                  Icons.photo,
                  'For more accurate recognition, make sure the picture features only one rock.',
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildTip(IconData iconData, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(iconData, color: Colors.white, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
