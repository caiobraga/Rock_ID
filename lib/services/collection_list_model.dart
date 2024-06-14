import 'package:flutter/material.dart';
import 'package:flutter_onboarding/services/add_rock_dialog.dart';
import 'package:flutter_onboarding/services/select_new_rock_add_to_collection.dart';
import 'package:flutter_onboarding/ui/screens/widgets/rock_list_item.dart';
import 'package:page_transition/page_transition.dart';

import '../constants.dart';
import '../db/db.dart';
import '../models/rock_in_collection.dart';
import '../models/rocks.dart';
import '../ui/screens/detail_page.dart';


class CollectionListModelService {
  Future<void> show(BuildContext context, int collectionId) async {
    List<Rock> collectionRocks = await _loadCollectionRocks(collectionId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
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
                  Text(
                    'SAVED (${collectionRocks.length})', // Update with actual count
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: collectionRocks.length,
                  itemBuilder: (BuildContext context, int index) {
                    final rock = collectionRocks[index];
                    return RockListItem(
                    imageUrl: rock.imageURL.isNotEmpty && rock.imageURL != '' ? rock.imageURL : 'https://via.placeholder.com/60',
                    title: rock.rockName,
                    tags: const ['Sulfide minerals', 'Mar', 'Jul'],
                    onTap: () {
                      Navigator.push(
                              context, PageTransition(child: RockDetailPage(rock: rock, isSavingRock: false), type: PageTransitionType.bottomToTop))
                          .then((value) => Navigator.of(context).pop());
                    },
                  );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    /*AddRockDialogService().show(context, (Rock rock) {

                    });*/
                    SelectNewRockAndAddToCollection(
                          context, collectionId)
                      .action()
                      .then((value) {
                    _loadCollectionRocks(collectionId);
                    
                  });
                  },
                  child: Text(
                    '+Add Rock',
                    style: TextStyle(
                      color: Constants.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Rock>> _loadCollectionRocks(int collectionId) async {
    List<RockInCollection> rocksInCollection = await DatabaseHelper().rocksInCollection(collectionId);
    List<Rock> collectionRocks = [];
    for (var rockInCollection in rocksInCollection) {
      Rock? rock = await DatabaseHelper().getRockById(rockInCollection.rockId);
      if (rock != null) {
        collectionRocks.add(rock);
      }
    }
    return collectionRocks;
  }


  Widget _buildTag(String tag) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
