import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';

import '../../widgets/ds_custom_text.dart';

class RockListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<Map<String, dynamic>> tags;
  final VoidCallback onTap;
  final String? imagePath;
  final VoidCallback? onDelete;

  const RockListItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.onTap,
    this.onDelete,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.naturalBlack,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: imagePath == null
                  ? Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey,
                          child: const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress != null &&
                            loadingProgress.expectedTotalBytes != null &&
                            loadingProgress.cumulativeBytesLoaded <
                                loadingProgress.expectedTotalBytes!) {
                          return SizedBox(
                            height: 60,
                            width: 60,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Constants.primaryColor,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            ),
                          );
                        }

                        return child;
                      },
                    )
                  : Image.file(
                      File(imagePath!),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey,
                          child: const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DSCustomText(
                          text: title,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      Visibility(
                        visible: onDelete != null,
                        child: InkWell(
                          onTap: () => _showDeleteConfirmationDialog(context),
                          customBorder: const CircleBorder(),
                          child: const Icon(
                            Icons.remove_circle,
                            color: Constants.lightestRed,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 24,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: tags.map((tag) {
                        return Container(
                          margin: const EdgeInsets.only(right: 4.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DSCustomText(
                            text: tag['text'],
                            icon: tag['icon'],
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.naturalSilver,
                          ),
                        );
                      }).toList(),
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

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.blackColor,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Removing rock',
            style: TextStyle(color: Constants.lightestRed),
          ),
          content: const Text(
            'Are you sure you want to remove the rock?',
            style: TextStyle(color: Constants.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Constants.darkGrey,
                backgroundColor: Constants.primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (onDelete != null) {
                  onDelete!();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Constants.lightestRed,
              ),
              child: const Text('Remove rock'),
            ),
          ],
        );
      },
    );
  }
}
