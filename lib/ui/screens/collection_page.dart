import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/collection.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rock_in_collection.dart';

class CollectionPage extends StatefulWidget {
  final Collection collection;
  const CollectionPage({Key? key, required this.collection}) : super(key: key);

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<Rock> _rocks = [];
  List<Rock> _collectionRocks = [];

  @override
  void initState() {
    super.initState();
    _loadRocks();
    _loadCollectionRocks();
  }

  void _loadRocks() async {
    List<Rock> rocks = await DatabaseHelper().rocks();
    setState(() {
      _rocks = rocks;
    });
  }

  void _loadCollectionRocks() async {
    List<RockInCollection> rocksInCollection = await DatabaseHelper().rocksInCollection(widget.collection.collectionId);
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

  void _addRockToCollection(Rock rock) async {
    await DatabaseHelper().addRockToCollection(rock.rockId, widget.collection.collectionId);
    _loadCollectionRocks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
            icon: Icon(Icons.settings),
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
                  Text(
                    'Behrouz',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '0 coins',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // Handle add new rock action
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                      SizedBox(width: 5),
                      Text(
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
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _collectionRocks.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          _collectionRocks[index].rockName,
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          _collectionRocks[index].description,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
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
