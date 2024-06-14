import 'package:flutter/material.dart';
import 'package:flutter_onboarding/ui/screens/select_rock_page.dart';
import 'package:page_transition/page_transition.dart';

import '../ui/scan_page.dart';
import '../constants.dart';
import '../ui/screens/widgets/collection.dart';
import '../ui/screens/widgets/collections_grid_view.dart';

class AddToMyCollectionModalService {
  Future<void> show(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ADD TO MY ROCKS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle add new action
                    },
                    child: Text(
                      '+Add new',
                      style: TextStyle(
                        color: Constants.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
                CollectionGridView(hasAddOption: false, onItemAdded: (){},)
            ],
          ),
        );
      },
    );
  }
}
