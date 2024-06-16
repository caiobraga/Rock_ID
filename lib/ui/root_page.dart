import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/favorite_page.dart';
import 'package:flutter_onboarding/ui/screens/home_page.dart';

import '../services/bottom_nav_service.dart';
import '../services/selection_modal.dart';
import 'screens/widgets/hexagon_floating_action_button.dart';

class RootPage extends StatefulWidget {
  final bool? showFavorites;

  const RootPage({
    Key? key,
    this.showFavorites,
  }) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Rock> favorites = [];
  List<Rock> myCart = [];
  final BottomNavService _bottomNavService = BottomNavService();

  @override
  void initState() {
    super.initState();

    List<Rock> favoritedRocks = [];

    DatabaseHelper().rocks().then((rocks) {
      DatabaseHelper().wishlist().then((wishlist) {
        for (final rock in rocks) {
          for (final rockId in wishlist) {
            if (rockId == rock.rockId) {
              favoritedRocks.add(rock);
            }
          }
        }
      });

      setState(() {
        favorites = favoritedRocks;
      });
    });

    Rock.addedToCartRocks().then((cartRocks) {
      setState(() {
        myCart = cartRocks;
      });
    });

    if (widget.showFavorites == true) {
      setState(() {
        _bottomNavService.setIndex(1);
      });
    }
  }

  // List of the pages
  List<Widget> _widgetOptions() {
    return [
      const HomePage(),
      FavoritePage(
        favoritedRocks: favorites,
        showWishlist: widget.showFavorites == true,
      ),
    ];
  }

 final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home, size: 40),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.folder_copy, size: 40,),
      label: 'Favorite',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ROCKAPP',
                style: TextStyle(
                  color: Constants.primaryColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    color: Constants.primaryColor,
                    icon: const Icon(Icons.create),
                    onPressed: () {},
                  ),
                  IconButton(
                    color: Constants.primaryColor,
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              )
            ],
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: IndexedStack(
        index: _bottomNavService.bottomNavIndex,
        children: _widgetOptions(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          BottomNavigationBar(
            backgroundColor: Constants.darkGrey,
            selectedItemColor: Constants.primaryColor,
            enableFeedback: false,
            unselectedItemColor: Constants.white.withOpacity(.5),
            items: _bottomNavItems,
            currentIndex: _bottomNavService.bottomNavIndex,
            onTap: (index) async {
              final List<Rock> favoritedRocks = await Rock.getFavoritedRocks();
              final List<Rock> addedToCartRocks = await Rock.addedToCartRocks();
              setState(() {
                _bottomNavService.setIndex(index);
                favorites = favoritedRocks;
                myCart = addedToCartRocks.toSet().toList();
              });
            },
          ),
          Positioned(
            bottom: 20, 
            child: HexagonFloatingActionButton(
              heroTag: "scan",
              onPressed: () {
                ShowSelectionModalService().show(context);
              },
              child: Icon(
                Icons.camera_alt_rounded,
                size: 40,
                color: Constants.white,
              ),
              backgroundColor: Constants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
