
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/favorite_page.dart';
import 'package:flutter_onboarding/ui/screens/home_page.dart';

import '../services/botton_nav.dart';
import '../services/selection_modal.dart';
import 'screens/widgets/hexagon_floating_action_button.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Rock> favorites = [];
  List<Rock> myCart = [];
  int _currentBottonNum = 0;
  @override
  void initState(){
    BottomNavService().addListener(() {
      setState(() {
        _currentBottonNum = BottomNavService().bottomNavIndex;
      });
    });
    super.initState();
  }
  //List of the pages
  List<Widget> _widgetOptions(){
    return [
      const HomePage(),
      FavoritePage(favoritedRocks: favorites,),
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
        title:Container(
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
        index: _currentBottonNum,
        children: _widgetOptions(),
      ),
      floatingActionButton: HexagonFloatingActionButton(
        heroTag: "scan",
        onPressed: (){
            ShowSelectionModalService().show(context);
        },
        child: Image.asset('assets/images/code-scan-two.png', height: 30.0,),
        backgroundColor: Constants.primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        backgroundColor: Constants.darkGrey,
        splashColor: Constants.primaryColor,
        activeColor: Constants.primaryColor,
        inactiveColor: Constants.white.withOpacity(.5),
        icons: iconList,
        activeIndex: _currentBottonNum,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) async {
          final List<Rock> favoritedRocks = await Rock.getFavoritedRocks();
          final List<Rock> addedToCartRocks = await Rock.addedToCartRocks();
          setState(() {
            BottomNavService().setIndex(index);
            favorites = favoritedRocks;
            myCart = addedToCartRocks.toSet().toList();
          });
        },
      ),
    );
  }
}
