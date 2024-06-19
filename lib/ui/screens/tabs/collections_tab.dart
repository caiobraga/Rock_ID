import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/collection.dart';
import 'package:flutter_onboarding/services/add_new_collection_modal.dart';
import 'package:flutter_onboarding/ui/screens/widgets/collections_grid_view.dart';

class CollectionsTab extends StatefulWidget {
  const CollectionsTab({super.key});

  @override
  State<CollectionsTab> createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<CollectionsTab> {
  final List<Collection> _collections = [];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  void _loadCollections() async {
    try {
      _collections.clear();
      List<Collection> collections = await DatabaseHelper().collections();
      setState(() {
        _collections.addAll(collections);
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        right: 16.0,
        bottom: 40.0,
        left: 16.0,
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Constants.darkGrey,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Scaffold(
          backgroundColor: Constants.darkGrey,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Constants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () {
              AddNewCollectionModalService().show(context, _loadCollections);
            },
            child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: Constants.primaryDegrade,
                ),
                child: const Icon(Icons.add,
                    color: Colors.white, size: 40, weight: 40, grade: 20)),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniEndFloat,
          body: Column(
            children: [
              Expanded(
                child: CollectionGridView(
                  collections: _collections,
                  hasAddOption: true,
                  onItemAdded: _loadCollections,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
