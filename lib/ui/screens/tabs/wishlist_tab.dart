import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:flutter_onboarding/ui/screens/select_rock_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/rock_list_item.dart';
import 'package:page_transition/page_transition.dart';

class WishlistTab extends StatefulWidget {
  const WishlistTab({super.key});

  @override
  State<WishlistTab> createState() => _WishlistTabState();
}

class _WishlistTabState extends State<WishlistTab> {
  final List<Rock> _wishlistRocks = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  void _loadWishlist() async {
    try {
      _wishlistRocks.clear();
      List<int> wishlistIds = await DatabaseHelper().wishlist();
      for (var rockId in wishlistIds) {
        final rock = Rock.rockListFirstWhere(rockId);
        if (rock != null) {
          _wishlistRocks.add(rock);
        }
      }

      setState(() {});
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        right: 16.0,
        bottom: 40.0,
        left: 16.0,
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Constants.darkGrey,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: _wishlistRocks.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_alt_rounded,
                        size: 50,
                        color: Constants.naturalGrey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      Text('The Wishlist is empty!',
                          style: AppTypography.body2(
                              color: AppColors.naturalWhite)),
                      const SizedBox(height: 10),
                      Text(
                          "Add any new rock to this page by seeing it's details and clicking on the heart icon on the top right of the page.",
                          textAlign: TextAlign.center,
                          style: AppTypography.body3(
                              color: AppColors.naturalWhite)),
                      const SizedBox(height: 20),
                      _addRockToWishlistButton(),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _wishlistRocks.length,
                      itemBuilder: (context, index) {
                        final rock = _wishlistRocks[index];
                        return RockListItem(
                          imageUrl: rock.imageURL.isNotEmpty &&
                                  rock.imageURL != ''
                              ? rock.imageURL
                              : 'https://via.placeholder.com/60', // Placeholder image
                          title: rock.rockName,
                          tags: const ['Wishlist'],
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
                            ).then((value) => _loadWishlist);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _addRockToWishlistButton(),
                ],
              ),
      ),
    );
  }

  Widget _addRockToWishlistButton() {
    return ElevatedButton.icon(
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
