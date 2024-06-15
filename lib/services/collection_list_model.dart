import 'package:flutter/material.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _CollectionListModal(collectionId: collectionId);
      },
    );
  }
}

class _CollectionListModal extends StatefulWidget {
  final int collectionId;

  _CollectionListModal({required this.collectionId});

  @override
  __CollectionListModalState createState() => __CollectionListModalState();
}

class __CollectionListModalState extends State<_CollectionListModal> {
  List<Rock> _collectionRocks = [];

  @override
  void initState() {
    super.initState();
    _loadCollectionRocks(widget.collectionId);
  }

  Future<void> _loadCollectionRocks(int collectionId) async {
    try {
      List<RockInCollection> rocksInCollection =
          await DatabaseHelper().rocksInCollection(collectionId);
      List<Rock> collectionRocks = [];
      for (var rockInCollection in rocksInCollection) {
        Rock? rock =
            await DatabaseHelper().getRockById(rockInCollection.rockId);
        if (rock != null) {
          collectionRocks.add(rock);
        }
      }
      setState(() {
        _collectionRocks = collectionRocks;
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'SAVED (${_collectionRocks.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _collectionRocks.length,
              itemBuilder: (BuildContext context, int index) {
                final rock = _collectionRocks[index];
                return RockListItem(
                  imageUrl: rock.imageURL.isNotEmpty && rock.imageURL != ''
                      ? rock.imageURL
                      : 'https://via.placeholder.com/60',
                  title: rock.rockName,
                  tags: const ['Sulfide minerals', 'Mar', 'Jul'],
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        child: RockDetailPage(rock: rock, isSavingRock: false),
                        type: PageTransitionType.bottomToTop,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () {
                SelectNewRockAndAddToCollection(context, widget.collectionId)
                    .action()
                    .then((value) {
                  _loadCollectionRocks(widget.collectionId);
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
  }
}
