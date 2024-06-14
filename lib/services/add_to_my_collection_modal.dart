import 'package:flutter/material.dart';
import 'package:flutter_onboarding/ui/screens/select_rock_page.dart';
import 'package:page_transition/page_transition.dart';

import '../db/db.dart';
import '../models/collection.dart';
import '../ui/scan_page.dart';
import '../constants.dart';
import '../ui/screens/widgets/collection.dart';
import '../ui/screens/widgets/collections_grid_view.dart';
import 'add_new_collection_modal.dart';

class AddToMyCollectionModalService {
  void show(BuildContext context, void Function() onNewCollectionAdded) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _AddToMyCollectionModal(onNewCollectionAdded: onNewCollectionAdded);
      },
    );
  }
}

class _AddToMyCollectionModal extends StatefulWidget {
  final void Function() onNewCollectionAdded;

  _AddToMyCollectionModal({required this.onNewCollectionAdded});

  @override
  __AddToMyCollectionModalState createState() => __AddToMyCollectionModalState();
}

class __AddToMyCollectionModalState extends State<_AddToMyCollectionModal> {
  List<Collection> _collections = [];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  void _loadCollections() async {
    try {
      List<Collection> collections = await DatabaseHelper().collections();
      setState(() {
        _collections = collections;
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  AddNewCollectionModalService().show(context, () {
                    widget.onNewCollectionAdded();
                    _loadCollections();
                  });
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
          Expanded(
            child: SingleChildScrollView(
              child: CollectionGridView(
                hasAddOption: false,
                onItemAdded: () {
                  _loadCollections();
                  widget.onNewCollectionAdded();
                },
                collections: _collections,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
