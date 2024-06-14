import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';

class CollectionWidget extends StatelessWidget {
  final String title;
  final bool isSavedLayout;
  final int rockCount;
  final List<String> rockImages;
  final VoidCallback onTap;

  CollectionWidget({
    Key? key,
    required this.title,
    this.isSavedLayout = false,
    this.rockCount = 0,
    this.rockImages = const [],
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 159.5,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Constants.naturalGrey,
            width: 2
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children:[
                Expanded(
                child: Container(
                  height: 33,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Constants.naturalGrey,
                    borderRadius: BorderRadius.all(Radius.circular(41)),
                  ),
                  child: Text(
                    '  $title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              ] 
            ),
            const SizedBox(height: 16),
            if (isSavedLayout)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark, color: Constants.primaryColor, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    '$rockCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Rocks',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  for (int i = 0; i < rockImages.length && i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(rockImages[i]),
                        radius: 15,
                      ),
                    ),
                  for (int i = rockImages.length; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: CircleAvatar(
                        backgroundColor: Constants.naturalGrey,
                        radius: 15,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
