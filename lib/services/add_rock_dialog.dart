import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/rocks.dart'; // Make sure you have a database helper to fetch rocks

class AddRockDialogService {
  void show(BuildContext context, void Function(Rock) onItemAdded) {
    final TextEditingController _searchController = TextEditingController();
    List<Rock> _rocks = []; // This should be populated with your data
    List<Rock> _filteredRocks = [];
    Rock? _selectedRock;

    _searchController.addListener(() {
      _filteredRocks = _rocks
          .where((rock) => rock.rockName
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search for Rocks',
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.grey[800],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: const Icon(Icons.search,
                                  color: Colors.white54),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _filteredRocks = _rocks
                                    .where((rock) => rock.rockName
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                    .toList();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Constants.primaryColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white),
                            onPressed: () {
                              // Handle camera action
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _searchController.text.isEmpty
                        ? Column(
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Popular Rock sets',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                children: [
                                  _buildRockSetCard('Igneous', 'Rocks',
                                      'assets/images/igneous.jpg'),
                                  _buildRockSetCard('Sedimentary', 'Rocks',
                                      'assets/images/sedimentary.jpg'),
                                  _buildRockSetCard('Metamorphic', 'Rocks',
                                      'assets/images/metamorphic.jpg'),
                                  _buildRockSetCard('Specific', 'varieties',
                                      'assets/images/specific.jpg'),
                                ],
                              ),
                            ],
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _filteredRocks.length,
                              itemBuilder: (BuildContext context, int index) {
                                final rock = _filteredRocks[index];
                                return ListTile(
                                  leading: Image.network(
                                    rock.imageURL.isNotEmpty
                                        ? rock.imageURL
                                        : 'https://via.placeholder.com/60',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(
                                    rock.rockName,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      const Text('Sulfide minerals',
                                          style:
                                              TextStyle(color: Colors.white54)),
                                      const SizedBox(width: 5),
                                      Wrap(
                                        spacing: 5,
                                        children:
                                            ['Mar', 'Jul', 'Dec'].map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[700],
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Text(tag,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                  trailing: _selectedRock == rock
                                      ? Icon(Icons.check,
                                          color: Constants.primaryColor)
                                      : IconButton(
                                          icon: Icon(Icons.add,
                                              color: Constants.primaryColor),
                                          onPressed: () {
                                            setState(() {
                                              _selectedRock = rock;
                                            });
                                            onItemAdded(rock);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                  onTap: () {
                                    setState(() {
                                      _selectedRock = rock;
                                    });
                                    onItemAdded(rock);
                                    // Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRockSetCard(String title, String subtitle, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
