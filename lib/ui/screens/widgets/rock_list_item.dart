import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';

import '../../widgets/text.dart';

class RockListItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<String> tags;
  final VoidCallback onTap;
  final Uint8List? image;
  final VoidCallback? onDelete;

  const RockListItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.onTap,
    this.onDelete,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.naturalBlack,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: image == null
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
                  : Image.memory(
                      image!,
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
                  DSCustomText(
                    text: title,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                            text: tag,
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
            Visibility(
              visible: onDelete != null,
              child: IconButton(
                onPressed: onDelete,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.all(0),
                icon: const Icon(
                  Icons.remove_circle,
                  color: Constants.lightestRed,
                  size: 24,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
