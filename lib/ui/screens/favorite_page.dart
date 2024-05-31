import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/collection.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/widgets/plant_widget.dart';
import 'package:flutter_onboarding/ui/screens/collection_page.dart';

import '../../db/db.dart';

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
        return AlertDialog(
          title: const Text('CREATE NEW COLLECTION'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _collectionNameController,
                decoration: const InputDecoration(
                  labelText: 'Name your new collection',
                  hintText: 'Enter name',
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter description',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
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
                    print(e);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        onPressed: _showNewCollectionDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            widget.favoritedRocks.isEmpty
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 100,
                          child: Image.asset('assets/images/favorited.png'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your favorited Rocks',
                          style: TextStyle(
                            color: Constants.primaryColor,
                            fontWeight: FontWeight.w300,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
                    height: size.height * .5,
                    child: ListView.builder(
                      itemCount: widget.favoritedRocks.length,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return RockWidget(
                          index: index,
                          RockList: widget.favoritedRocks,
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            Text(
              'Your Collections',
              style: TextStyle(
                color: Constants.primaryColor,
                fontWeight: FontWeight.w300,
                fontSize: 18,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _collections.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_collections[index].collectionName),
                  subtitle: Text(_collections[index].description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CollectionPage(collection: _collections[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
