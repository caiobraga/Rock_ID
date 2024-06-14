import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/collection.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:page_transition/page_transition.dart';

import '../widgets/text.dart';
import 'collection_page.dart';
import 'detail_page.dart';
import 'widgets/rock_list_item.dart';

class FavoritePage extends StatefulWidget {
  final List<Rock> favoritedRocks;
  const FavoritePage({Key? key, required this.favoritedRocks}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final TextEditingController _collectionNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Collection> _collections = [];
  List<Map<String, dynamic>> _snapHistory = [];
  List<Rock> _allRocks = [];

  @override
  void initState() {
    super.initState();
    _loadCollections();
    _loadSnapHistory();
    _loadAllRocks();
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

  void _loadSnapHistory() async {
    try {
      List<Map<String, dynamic>> snapHistory = await DatabaseHelper().snapHistory();
      setState(() {
        _snapHistory = snapHistory;
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _loadAllRocks() async {
    try {
      List<Rock> allRocks = await DatabaseHelper().rocks();
      setState(() {
        _allRocks = allRocks;
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _addRockToSnapHistory(int rockId) async {
    String timestamp = DateTime.now().toIso8601String();
    await DatabaseHelper().addRockToSnapHistory(rockId, timestamp);
    _loadSnapHistory(); // Reload snap history after adding
  }

  void _showNewCollectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.black,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.black,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'CREATE NEW COLLECTION',
                  style: TextStyle(
                    color: Constants.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _collectionNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Name your new collection',
                    hintText: 'Enter name',
                    hintStyle: const TextStyle(color: Colors.white54),
                    labelStyle: TextStyle(color: Constants.primaryColor),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description',
                    hintStyle: const TextStyle(color: Colors.white54),
                    labelStyle: TextStyle(color: Constants.primaryColor),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Constants.primaryColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Constants.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('OK'),
                      onPressed: () async {
                        final String collectionName = _collectionNameController.text;
                        final String description = _descriptionController.text;

                        if (collectionName.isNotEmpty) {
                          try {
                            Collection newCollection = Collection(
                              collectionId: 0,
                              collectionName: collectionName,
                              description: description,
                            );

                            await DatabaseHelper().insertCollection(newCollection);
                            _loadCollections();
                            Navigator.of(context).pop();
                          } catch (e) {
                            debugPrint('$e');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Constants.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          onPressed: _showNewCollectionDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Constants.darkGrey,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), // Creates border radius for the indicator
                  color: Colors.grey[800], // Change the background color
                ),
                unselectedLabelColor: Colors.white,
                labelColor: Colors.white,
                dividerHeight: 0,
                tabs: [
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text("Collections"),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text("Snap History"),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text("Wishlist"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCollectionsTab(),
                  _buildSnapHistoryTab(),
                  _buildWishlistTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _collections.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == _collections.length) {
                return GestureDetector(
                  onTap: _showNewCollectionDialog,
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
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CollectionPage(collection: _collections[index]),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _collections[index].collectionName,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                            ),
                            itemCount: 6, // Replace with actual number of rocks in the collection
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/rock.png'), // Placeholder image
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSnapHistoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Constants.darkGrey,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFB88F71),
                    Color(0xFFA16132),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.0),
                  onTap: () {
                    _addRockToSnapHistory(1);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.crop_free, color: Colors.white),
                      SizedBox(width: 12),
                      DSCustomText(
                        text: 'Identify Rock',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _snapHistory.length,
                itemBuilder: (context, index) {
                  final rockId = _snapHistory[index]['rockId'];
                  final rock = _allRocks.firstWhere((rock) => rock.rockId == rockId, orElse: () => Rock.empty());
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
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistTab() {
    return const Center(
      child: Text('Wishlist Tab Content', style: TextStyle(color: Colors.white)),
    );
  }
}
