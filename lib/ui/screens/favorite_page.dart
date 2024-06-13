import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';

import '../../db/db.dart';
import '../../models/collection.dart';
import '../../models/rocks.dart';
import 'collection_page.dart';

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
      print(e);
    }
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
                SizedBox(height: 10),
                TextField(
                  controller: _collectionNameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Name your new collection',
                    hintText: 'Enter name',
                    hintStyle: TextStyle(color: Colors.white54),
                    labelStyle: TextStyle(color: Constants.primaryColor),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description',
                    hintStyle: TextStyle(color: Colors.white54),
                    labelStyle: TextStyle(color: Constants.primaryColor),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
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
                        primary: Constants.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('OK'),
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
                            print(e);
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
    Size size = MediaQuery.of(context).size;
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
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Constants.darkGrey,
                  borderRadius: BorderRadius.circular(50), 
                  
                ) ,
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
                      child: Align(
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
                      child: Align(
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
                      child: Align(
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
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                    child: Column(
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
    return Center(
      child: Text('Snap History Tab Content', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildWishlistTab() {
    return Center(
      child: Text('Wishlist Tab Content', style: TextStyle(color: Colors.white)),
    );
  }
}
