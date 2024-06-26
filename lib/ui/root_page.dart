import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/camera_screen.dart';
import 'package:flutter_onboarding/ui/screens/home_page.dart';
import 'package:flutter_onboarding/ui/screens/my_rocks_page.dart';
import 'package:flutter_onboarding/ui/screens/premium_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';

import '../services/bottom_nav_service.dart';

class RootPage extends StatefulWidget {
  final bool showFavorites;

  const RootPage({
    Key? key,
    this.showFavorites = false,
  }) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Rock> myCart = [];

  final _bottomNavService = BottomNavService.instance;

  @override
  void initState() {
    super.initState();
    if (widget.showFavorites) {
      _bottomNavService.setIndex(1);
    }
  }

  // List of the pages
  List<Widget> _widgetOptions() {
    return [
      const HomePage(),
      MyRocksPage(
        showWishlist: widget.showFavorites,
      ),
    ];
  }

  Widget _buildCurrentBottomNavItem(index, isActive) {
    if (!isActive) {
      return index == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.string(AppIcons.homeUnselected),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Home',
                    maxLines: 1,
                    style: TextStyle(color: Constants.silver, fontSize: 12),
                  ),
                )
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.string(AppIcons.folderUnselected),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'My Rocks',
                    maxLines: 1,
                    style: TextStyle(color: Constants.silver, fontSize: 12),
                  ),
                )
              ],
            );
    } else {
      return index == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.string(AppIcons.home),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Home',
                    maxLines: 1,
                    style: TextStyle(
                      color: Constants.primaryColor,
                      fontSize: 13.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.string(AppIcons.folder),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'My Rocks',
                    maxLines: 1,
                    style: TextStyle(
                      color: Constants.primaryColor,
                      fontSize: 13.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            );
    }
  }

  List<Widget> _buildBottomNavItems() {
    return [
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.string(AppIcons.homeUnselected),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Home',
              maxLines: 1,
              style: TextStyle(color: Constants.silver, fontSize: 12),
            ),
          )
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.string(AppIcons.folder),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'My Rocks',
              maxLines: 1,
              style: TextStyle(color: Constants.silver, fontSize: 12),
            ),
          )
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ROCKAPP',
          style: TextStyle(
            color: Constants.primaryColor,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            child: SvgPicture.string(AppIcons.crown),
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const PremiumScreen(),
              ),
            ),
          ),
        ],
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _bottomNavService.bottomNavIndexNotifier,
        builder: (context, index, child) {
          return IndexedStack(
            index: index,
            children: _widgetOptions(),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              PageTransition(
                duration: const Duration(milliseconds: 400),
                child: const CameraScreen(),
                type: PageTransitionType.bottomToTop,
              ),
            );
          },
          child: SvgPicture.string(AppIcons.polygonCamera),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _bottomNavService.bottomNavIndexNotifier,
        builder: (context, index, child) {
          return AnimatedBottomNavigationBar.builder(
            itemCount: _buildBottomNavItems().length,
            tabBuilder: (index, isActive) {
              return _buildCurrentBottomNavItem(index, isActive);
            },
            backgroundColor: Constants.darkGrey,
            splashColor: Constants.primaryColor,
            splashRadius: 32,
            blurEffect: true,
            scaleFactor: 0.4,
            activeIndex: index,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.softEdge,
            height: 70,
            onTap: (index) {
              _bottomNavService.setIndex(index);
            },
          );
        },
      ),
    );
  }
}
