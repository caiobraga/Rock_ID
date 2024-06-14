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
    super.key,
    this.showFavorites,
  });

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Rock> favorites = [];
  List<Rock> myCart = [];
  final BottomNavService _bottomNavService = BottomNavService();

  @override
  void initState() {
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

    super.initState();
  }

  //List of the pages
  List<Widget> _widgetOptions() {
    return [
      const HomePage(),
      FavoritePage(
        favoritedRocks: favorites,
        showWishlist: widget.showFavorites == true,
      ),
    ];
  }

  //List of the pages icons
  List<IconData> iconList = [
    Icons.home,
    Icons.folder_copy,
  ];

  //List of the pages titles
  List<String> titleList = [
    'Home',
    'Favorite',
    'Cart',
    'Profile',
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
      floatingActionButton: HexagonFloatingActionButton(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: Constants.darkGrey,
        splashColor: Constants.primaryColor,
        activeColor: Constants.primaryColor,
        inactiveColor: Constants.white.withOpacity(.5),
        icons: iconList,
        iconSize: 30,
        activeIndex: _bottomNavService.bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
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
    );
  }
}
