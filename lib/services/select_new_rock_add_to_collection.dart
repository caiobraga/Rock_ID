import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/services/snackbar.dart';

import '../models/rock_in_collection.dart';

class SelectNewRockAndAddToCollection {
  final BuildContext context;
  final int collectionId;

  SelectNewRockAndAddToCollection(this.context, this.collectionId);

  Future<void> action() async {
    List<Rock> rocks = await DatabaseHelper().rocks();
    List<RockInCollection> rocksInCollection = await DatabaseHelper().rocksInCollection(collectionId);
    List<int> rocksInCollectionIds = rocksInCollection.map((rock) => rock.rockId).toList();

    final TextEditingController _searchController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              List<Rock> filteredRocks = rocks.where((rock) {
                return rock.rockName.toLowerCase().contains(_searchController.text.toLowerCase());
              }).toList();

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
                          'ADD ROCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: () {
                            // Implement camera functionality if needed
                          },
                        ),
                        hintText: 'Search rock name',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredRocks.length,
                        itemBuilder: (BuildContext context, int index) {
                          final rock = filteredRocks[index];
                          final bool isInCollection = rocksInCollectionIds.contains(rock.rockId);

                          return Card(
                            color: Colors.grey[850],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: rock.imageURL.isNotEmpty
                                  ? Image.network(
                                      rock.imageURL,
                                      width: 50,
                                      height: 50,
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[700],
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white,
                                      ),
                                    ),
                              title: Text(
                                rock.rockName,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                rock.description,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isInCollection ? Icons.check : Icons.add,
                                  color: isInCollection ? Colors.green : Colors.white,
                                ),
                                onPressed: () async {
                                  if (isInCollection) {
                                    await DatabaseHelper().removeRockFromCollection(rock.rockId, collectionId);
                                    setState(() {
                                      rocksInCollectionIds.remove(rock.rockId);
                                    });
                                    ShowSnackbarService().showSnackBar('${rock.rockName} was removed from the collection!');
                                  } else {
                                    await DatabaseHelper().addRockToCollection(rock.rockId, collectionId);
                                    setState(() {
                                      rocksInCollectionIds.add(rock.rockId);
                                    });
                                    ShowSnackbarService().showSnackBar('${rock.rockName} was added to the collection!');
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
