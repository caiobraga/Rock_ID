import 'package:flutter/material.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/pages/rock_view_page.dart';
import 'package:flutter_onboarding/ui/pages/tabs/tab_services/collections_tab_service.dart';
import 'package:flutter_onboarding/ui/pages/tabs/tab_services/loved_tab_service.dart';
import 'package:flutter_onboarding/ui/pages/tabs/tab_services/snap_history_tab_service.dart';
import 'package:flutter_onboarding/utils/string_utils.dart';
import 'package:page_transition/page_transition.dart';

import '../../constants.dart';
import './widgets/rock_list_item.dart'; // Import the RockListItem widget

class SelectRockPage extends StatefulWidget {
  final bool isFavoritingRock;
  final bool showKeyboard;

  const SelectRockPage({
    super.key,
    this.showKeyboard = true,
    this.isFavoritingRock = false,
  });

  @override
  _SelectRockPageState createState() => _SelectRockPageState();
}

class _SelectRockPageState extends State<SelectRockPage> {
  List<Rock> _rockList = [];
  List<Rock> _filteredRockList = [];
  final searchController = TextEditingController();

  final _searchRocks = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.showKeyboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _searchRocks.requestFocus();
        });
      });
    }
    _initializeList();
  }

  void _initializeList() {
    _rockList.clear();
    _filteredRockList.clear();
    DatabaseHelper().incrementDefaultRockList(Rock.rockList).then((rockList) {
      final repeatedRockList = rockList;
      repeatedRockList.sort((a, b) => a.rockId.compareTo(b.rockId));
      final Set<String> rockNamesSet = {};
      DatabaseHelper().findAllRocks().then(
        (allRocks) {
          for (final rock in repeatedRockList) {
            if (!rockNamesSet.contains(rock.rockName)) {
              if (allRocks
                  .where((element) => element.rockId == rock.rockId)
                  .isNotEmpty) {
                _filteredRockList.add(
                  allRocks
                      .firstWhere((element) => element.rockId == rock.rockId),
                );
              } else {
                _filteredRockList.add(rock);
              }
              rockNamesSet.add(rock.rockName);
            }
          }

          _rockList = _filteredRockList;

          if (widget.isFavoritingRock) {
            _filterFavoritedRocks();
          }

          _sortCollectionRocks();
        },
      );
      setState(() {
        searchController.text = '';
      });
    });
  }

  void _sortCollectionRocks() async {
    // Recupera todas as rochas da coleção do banco de dados
    final collectionRocks = (await DatabaseHelper().findAllRocks())
        .where((element) => element.isAddedToCollection);

    // Extrai os nomes das rochas da coleção
    final collectionRockNames =
        collectionRocks.map((rock) => rock.rockName).toSet();

    // Ordena a _rockList baseada no nome em ordem alfabética
    _rockList.sort((rock1, rock2) {
      final rock1InCollection = collectionRockNames.contains(rock1.rockName);
      final rock2InCollection = collectionRockNames.contains(rock2.rockName);

      // If both rocks are in the collection or both are not, sort alphabetically
      if (rock1InCollection == rock2InCollection) {
        return rock1.rockName.compareTo(rock2.rockName);
      }

      // If only one rock is in the collection, move it to the end
      return rock1InCollection ? 1 : -1;
    });

    // Caso a lista de coleção esteja vazia, só ordena a _filteredRockList
    if (collectionRocks.isEmpty) {
      _filteredRockList.sort((a, b) => a.rockName.compareTo(b.rockName));
    }

    setState(() {});
  }

  void _filterFavoritedRocks() async {
    final wishlistRocksMap = await DatabaseHelper().wishlist();
    List<Rock> unfavoritedRocks = _rockList;

    for (final wishlistRock in wishlistRocksMap) {
      unfavoritedRocks = unfavoritedRocks
          .where(
            (element) => element.rockId != wishlistRock['rockId'],
          )
          .toList();
    }

    setState(() {
      _rockList = unfavoritedRocks;
      _filteredRockList = unfavoritedRocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Constants.primaryColor,
          ),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  focusNode: _searchRocks,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Constants.darkGrey,
                    hintStyle: const TextStyle(color: Constants.white),
                    hintText: 'Search for rocks',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Constants.primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  controller: searchController,
                  style: const TextStyle(color: Constants.white),
                  onChanged: (query) {
                    searchController.text = query;
                    _filterRocks(query);
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredRockList.length,
                  cacheExtent: 2000,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  itemBuilder: (context, index) {
                    final rock = _filteredRockList[index];

                    Map<String, dynamic> rockDefaultImage = {
                      'img1': 'https://placehold.jp/60x60.png',
                    };

                    for (final defaultImage in Rock.defaultImages) {
                      if (defaultImage['rockId'] == rock.rockId) {
                        rockDefaultImage = defaultImage;
                      }
                    }

                    return RockListItem(
                      imagePath: rock.rockImages.isNotEmpty
                          ? rock.rockImages.first.imagePath
                          : null,
                      imageUrl: rockDefaultImage[
                          'img1'], // Use a placeholder image if none available
                      title: rock.rockCustomName.isNotEmpty
                          ? rock.rockCustomName
                          : rock.rockName,
                      tags: [
                        {
                          'icon': Icons.category,
                          'text': StringUtils.capitalizeFirstLetter(
                            rock.category.isEmpty ? 'Unknown' : rock.category,
                          ),
                        },
                        {
                          'icon': Icons.color_lens,
                          'text': StringUtils.capitalizeFirstLetter(
                            rock.color.isEmpty ? 'Unknown' : rock.color,
                          ),
                        },
                        {
                          'icon': Icons.brightness_4,
                          'text': StringUtils.capitalizeFirstLetter(
                            rock.luster.isEmpty ? 'Unknown' : rock.luster,
                          ),
                        },
                      ], // Replace with actual tags
                      onTap: () => _saveRock(rock),
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

  void _saveRock(Rock rock) async {
    bool isRemovingFromCollection = false;
    final allRocks = await DatabaseHelper().findAllRocks();
    if (allRocks
        .where((rockFromAll) =>
            rockFromAll.rockName == rock.rockName &&
            rockFromAll.isAddedToCollection)
        .isNotEmpty) {
      isRemovingFromCollection = true;
    }

    Navigator.push(
      context,
      PageTransition(
        child: RockViewPage(
          rock: rock,
          isFavoritingRock: widget.isFavoritingRock,
          isRemovingFromCollection: isRemovingFromCollection,
          isAddingFromRockList: true,
        ),
        type: PageTransitionType.bottomToTop,
      ),
    ).then((_) {
      _initializeList();
      CollectionsTabService.instance
          .loadCollectionRocks()
          .then((_) => setState(() {}));
      SnapHistoryTabService.instance
          .loadSnapHistory()
          .then((_) => setState(() {}));
      LovedTabService.instance.loadLovedRocks().then((_) => setState(() {}));
    });
  }

  void _filterRocks(String query) {
    setState(() {
      _filteredRockList = _rockList
          .where((rock) => rock.rockCustomName.isNotEmpty
              ? rock.rockCustomName.toLowerCase().contains(query.toLowerCase())
              : rock.rockName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
