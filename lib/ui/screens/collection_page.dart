import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/collection.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/widgets/plant_widget.dart';

import '../../db/db.dart';
import '../../models/rock_in_collection.dart';

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
        title: Text(widget.collection.collectionName),
      ),
      body: Column(
        children: [
          Text(
            'Add Rocks to Collection',
            style: TextStyle(
              color: Constants.primaryColor,
              fontWeight: FontWeight.w300,
              fontSize: 18,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _rocks.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_rocks[index].rockName),
                  subtitle: Text(_rocks[index].description),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _addRockToCollection(_rocks[index]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Rocks in Collection',
            style: TextStyle(
              color: Constants.primaryColor,
              fontWeight: FontWeight.w300,
              fontSize: 18,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _collectionRocks.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_collectionRocks[index].rockName),
                  subtitle: Text(_collectionRocks[index].description),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
