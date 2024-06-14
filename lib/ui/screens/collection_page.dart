import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/collection.dart';
import 'package:flutter_onboarding/models/rock_in_collection.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:page_transition/page_transition.dart';

import '../../services/select_new_rock_add_to_collection.dart';
import '../../services/snackbar.dart';
import 'detail_page.dart';
import 'widgets/rock_list_item.dart';

class CollectionPage extends StatefulWidget {
  final Collection collection;
  const CollectionPage({Key? key, required this.collection}) : super(key: key);

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<Rock> _collectionRocks = [];

  @override
  void initState() {
    super.initState();
    _loadRocks();
    _loadCollectionRocks();
  }

  void _loadRocks() async {
    setState(() {});
  }

  void _loadCollectionRocks() async {
    List<RockInCollection> rocksInCollection = await DatabaseHelper()
        .rocksInCollection(widget.collection.collectionId);
    List<Rock> collectionRocks = [];
    for (var rockInCollection in rocksInCollection) {
      Rock? rock = await DatabaseHelper().getRockById(rockInCollection.rockId);
      if (rock != null) {
        collectionRocks.add(rock);
      }
    }
    setState(() {
      _collectionRocks = collectionRocks;
    });
  }

  // void _addRockToCollection(Rock rock) async {
  //   await DatabaseHelper()
  //       .addRockToCollection(rock.rockId, widget.collection.collectionId);
  //   _loadCollectionRocks();
  // }

  void _removeRockFromCollection(int rockId) async {
    await DatabaseHelper()
        .removeRockFromCollection(rockId, widget.collection.collectionId);
    _loadCollectionRocks();
    ShowSnackbarService().showSnackBar('Rock removed from the collection.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Constants.primaryColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'STONE ID',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Behrouz',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '0 coins',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // Handle add new rock action
                  SelectNewRockAndAddToCollection(
                          context, widget.collection.collectionId)
                      .action()
                      .then((value) {
                    _loadCollectionRocks();
                    setState(() {});
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Constants.darkGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: Constants.primaryColor,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Add new rock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _collectionRocks.length,
                  itemBuilder: (BuildContext context, int index) {
                    final rock = _collectionRocks[index];
                    return Dismissible(
                      key: Key(rock.rockId.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _removeRockFromCollection(rock.rockId);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child:RockListItem(
                      imageUrl: rock.imageURL.isNotEmpty &&  rock.imageURL != ''
                          ? rock.imageURL
                          : 'https://via.placeholder.com/60', // Use a placeholder image if none available
                      title: rock.rockName,
                      tags: ['Sulfide minerals', 'Mar', 'Jul'], // Replace with actual tags
                      onTap: () {
                         Navigator.push(
                                  context,
                                  PageTransition(
                                      child: RockDetailPage(
                                          rock: rock, isSavingRock: false),
                                      type: PageTransitionType.bottomToTop))
                              .then((value) => Navigator.of(context).pop());
                      },
                      )
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
