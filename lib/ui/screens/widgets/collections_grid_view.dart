import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';

import '../../../db/db.dart';
import '../../../models/collection.dart';
import '../../../services/collection_dialog.dart';
import '../collection_page.dart';
import 'collection.dart';

class CollectionGridView extends StatefulWidget {
  bool hasAddOption;
   void Function() onItemAdded;
  CollectionGridView({
    Key? key,
   required this.hasAddOption,
   required this.onItemAdded
  }) : super(key: key);

  @override
  State<CollectionGridView> createState() => _CollectionGridViewState();
}

class _CollectionGridViewState extends State<CollectionGridView> {
  List<Collection> _collections = [];
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCollections();
  }


  @override
  Widget build(BuildContext context) {
    return 
GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: widget.hasAddOption ? _collections.length + 1 : _collections.length ,
            itemBuilder: (BuildContext context, int index) {
              if (index == _collections.length && widget.hasAddOption) {
                return GestureDetector(
                  onTap: (){
                    CollectionDialogService().show(context, (){
                      widget.onItemAdded();
                      _loadCollections();
                    } );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 30),
                        SizedBox(height: 10),
                        Text('ADD NEW COLLECTION', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                );
              } else {
                final collection = _collections[index];
                return CollectionWidget(
                  title: collection.collectionName,
                  isSavedLayout: collection.collectionName == 'Saved',
                  rockCount: 0,
                  rockImages: collection.collectionName == 'Saved'
                      ? []
                      : [
                          'assets/rock_placeholder.png',
                          'assets/rock_placeholder.png',
                          // Add actual rock images here
                        ],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CollectionPage(collection: collection),
                      ),
                    );
                  },
                );
              }
            },
          );
  }
}



