import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/collection.dart';
import 'package:flutter_onboarding/services/select_new_rock_add_to_collection.dart';
import 'package:flutter_onboarding/ui/screens/widgets/rock_list_item.dart';
import 'package:page_transition/page_transition.dart';

import '../constants.dart';
import '../db/db.dart';
import '../models/rock_in_collection.dart';
import '../models/rocks.dart';
import '../ui/screens/detail_page.dart';

class CollectionListModelService {
  Future<void> show(BuildContext context, Collection collection) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _CollectionListModal(collection: collection);
      },
    );
  }
}

class _CollectionListModal extends StatefulWidget {
  final Collection collection;

  const _CollectionListModal({required this.collection});

  @override
  State<_CollectionListModal> createState() => __CollectionListModalState();
}

class __CollectionListModalState extends State<_CollectionListModal> {
  List<Rock> _collectionRocks = [];

  @override
  void initState() {
    super.initState();
    _loadCollectionRocks(widget.collection.collectionId);
  }

  Future<void> _loadCollectionRocks(int collectionId) async {
    try {
      List<RockInCollection> rocksInCollection =
          await DatabaseHelper().rocksInCollection(collectionId);
      final rocks = <Rock>[];
      for (var element in rocksInCollection) {
        final item = Rock.rockListFirstWhere(element.rockId);
        if (item != null) {
          rocks.add(item);
        }
      }

      setState(() {
        _collectionRocks = rocks;
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Constants.darkGrey,
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
              Expanded(
                child: Text(
                  '${widget.collection.collectionName} (${_collectionRocks.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.visible,
                  ),
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
                        child: RockDetailPage(
                            rock: rock,
                            isSavingRock: false,
                            showAddButton: false),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    await SelectNewRockAndAddToCollection(
                            context, widget.collection.collectionId)
                        .action();
                    await _loadCollectionRocks(widget.collection.collectionId);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Constants.darkGrey,
                    backgroundColor: Constants.primaryColor,
                  ),
                  icon: const Icon(Icons.delete),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await SelectNewRockAndAddToCollection(
                            context, widget.collection.collectionId)
                        .action();
                    await _loadCollectionRocks(widget.collection.collectionId);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Constants.darkGrey,
                    backgroundColor: Constants.primaryColor,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add Rock',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
