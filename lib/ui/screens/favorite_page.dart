import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:flutter_onboarding/ui/screens/select_rock_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/custom_tab_bar.dart';
import 'package:page_transition/page_transition.dart';

import '../../services/collection_dialog.dart';
import '../widgets/text.dart';
import 'widgets/collections_grid_view.dart';
import 'widgets/rock_list_item.dart';

class FavoritePage extends StatefulWidget {
  final bool? showWishlist;
  final List<Rock> favoritedRocks;
  const FavoritePage({
    super.key,
    required this.favoritedRocks,
    this.showWishlist,
  });

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _snapHistory = [];
  List<Rock> _allRocks = [];
  List<Rock> _wishlistRocks = [];
  late TabController _tabController;
  final List<String> _tabsDescriptions = [
    'Collections',
    'Snap History',
    'Wishlist'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSnapHistory();
    _loadAllRocks();
    _loadWishlist();
    setState(() {
      if (widget.showWishlist == true) {
        _tabController.index = 2;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSnapHistory() async {
    try {
      List<Map<String, dynamic>> snapHistory =
          await DatabaseHelper().snapHistory();
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

  void _loadWishlist() async {
    try {
      List<int> wishlistIds = await DatabaseHelper().wishlist();
      List<Rock> wishlistRocks = [];
      for (var rockId in wishlistIds) {
        Rock? rock = await DatabaseHelper().getRockById(rockId);
        if (rock != null) {
          wishlistRocks.add(rock);
        }
      }
      setState(() {
        _wishlistRocks = wishlistRocks;
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

  Widget _buildCollectionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CollectionGridView(
            hasAddOption: true,
            onItemAdded: () {
              setState(() {});
            },
          )
        ],
      ),
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
          onPressed: () {
            CollectionDialogService().show(context, () {
              setState(() {});
            });
          },
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: CustomTabBar(
                tabController: _tabController,
                tabsDescriptions: _tabsDescriptions,
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
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
                  final rock = _allRocks.firstWhere(
                      (rock) => rock.rockId == rockId,
                      orElse: () => Rock.empty());
                  return RockListItem(
                    imageUrl: rock.imageURL.isNotEmpty && rock.imageURL != ''
                        ? rock.imageURL
                        : 'https://via.placeholder.com/60',
                    title: rock.rockName,
                    tags: const ['Sulfide minerals', 'Mar', 'Jul'],
                    onTap: () {
                      Navigator.push(
                              context,
                              PageTransition(
                                  child: RockDetailPage(
                                      rock: rock, isSavingRock: false),
                                  type: PageTransitionType.bottomToTop))
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
    return _wishlistRocks.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.list_alt_rounded,
                  size: 50,
                  color: Colors.grey.withOpacity(0.25),
                ),
                const SizedBox(height: 20),
                const Text(
                  'The Wishlist is empty!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Add any new rock to this page by clicking\non the heart icon on the Rock Detail page',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    _showRockSelectionModal();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add Rock',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.primaryColor,
                    foregroundColor: Constants.blackColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _wishlistRocks.length,
                  itemBuilder: (context, index) {
                    final rock = _wishlistRocks[index];
                    return RockListItem(
                      imageUrl: rock.imageURL.isNotEmpty && rock.imageURL != ''
                          ? rock.imageURL
                          : 'https://via.placeholder.com/60', // Placeholder image
                      title: rock.rockName,
                      tags: const [
                        'Wishlist'
                      ], // Replace with actual tags if any
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: RockDetailPage(
                              rock: rock,
                              isSavingRock: false,
                              isFavoritingRock: true,
                            ),
                            type: PageTransitionType.bottomToTop,
                          ),
                        ).then((value) => _loadWishlist());
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _showRockSelectionModal();
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Rock',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Constants.blackColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                ),
              ),
            ],
          );
  }

  void _showRockSelectionModal() {
    Navigator.push(
        context,
        PageTransition(
            duration: const Duration(milliseconds: 400),
            child: const SelectRockPage(
              isSavingRock: false,
              isFavoritingRock: true,
            ),
            type: PageTransitionType.bottomToTop));
  }
}
