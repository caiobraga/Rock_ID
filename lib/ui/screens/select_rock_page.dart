import 'package:flutter/material.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:page_transition/page_transition.dart';

import '../../constants.dart';
import './widgets/rock_list_item.dart'; // Import the RockListItem widget

class SelectRockPage extends StatefulWidget {
  final bool isFavoritingRock;
  const SelectRockPage({
    super.key,
    this.isFavoritingRock = false,
  });

  @override
  _SelectRockPageState createState() => _SelectRockPageState();
}

class _SelectRockPageState extends State<SelectRockPage> {
  List<Rock> _rockList = Rock.rockList;
  List<Rock> _filteredRockList = Rock.rockList;

  final _searchRocks = FocusNode();

  @override
  void initState() {
    super.initState();
    _orderCollectionRocks();

    if (widget.isFavoritingRock) {
      _filterFavoritedRocks();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _searchRocks.requestFocus();
      });
    });
  }

  void _orderCollectionRocks() async {
    // Recupera todas as rochas da coleção do banco de dados
    final collectionRocks = await DatabaseHelper().findAllRocks();

    // Extrai os nomes das rochas da coleção
    final collectionRockNames =
        collectionRocks.map((rock) => rock.rockName).toSet();

    // Ordena a _rockList baseada na presença das rochas na coleção
    _rockList.sort((rock1, rock2) {
      final rock1InCollection = collectionRockNames.contains(rock1.rockName);
      final rock2InCollection = collectionRockNames.contains(rock2.rockName);

      // Coloca as rochas que não estão na coleção antes das que estão na coleção
      if (rock1InCollection && !rock2InCollection) return 1;
      if (!rock1InCollection && rock2InCollection) return -1;
      return 0;
    });

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
                  style: const TextStyle(color: Constants.white),
                  onChanged: (query) {
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
                      imageUrl: rockDefaultImage[
                          'img1'], // Use a placeholder image if none available
                      title: rock.rockName,
                      tags: const [
                        'Sulfide minerals',
                        'Mar',
                        'Jul'
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
        .where((rockFromAll) => rockFromAll.rockName == rock.rockName)
        .isNotEmpty) {
      isRemovingFromCollection = true;
    }

    Navigator.push(
      context,
      PageTransition(
        child: RockDetailPage(
          rock: rock,
          isFavoritingRock: widget.isFavoritingRock,
          isRemovingFromCollection: isRemovingFromCollection,
          isAddingFromRockList: true,
        ),
        type: PageTransitionType.bottomToTop,
      ),
    );
  }

  void _filterRocks(String query) {
    setState(() {
      _filteredRockList = _rockList
          .where((rock) =>
              rock.rockName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
