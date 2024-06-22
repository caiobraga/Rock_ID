import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/ui/screens/tabs/collections_tab.dart';
import 'package:flutter_onboarding/ui/screens/tabs/snap_history_tab.dart';
import 'package:flutter_onboarding/ui/screens/tabs/wishlist_tab.dart';
import 'package:flutter_onboarding/ui/screens/widgets/custom_tab_bar.dart';

import '../../services/bottom_nav_service.dart';

class MyRocksPage extends StatefulWidget {
  final bool showWishlist;
  const MyRocksPage({
    super.key,
    this.showWishlist = false,
  });

  @override
  State<MyRocksPage> createState() => _MyRocksPageState();
}

class _MyRocksPageState extends State<MyRocksPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<String> _tabsDescriptions = [
    'Collection',
    'Snap History',
    'Wishlist'
  ];

  final _bottomNavService = BottomNavService.instance;
  StreamSubscription<int>? _bottomNavIndexSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.showWishlist) {
      setState(() {
        _tabController.index = 2;
      });
    }

    // Escute as mudanças no índice do BottomNavigationBar
    _bottomNavService.rockCollectionClickStream.listen((event) {
      if (event == 'rock_collection') {
        setState(() {
          _tabController.index = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bottomNavIndexSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Constants.darkGrey,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: CustomTabBar(
                    tabController: _tabController,
                    tabsDescriptions: _tabsDescriptions,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      CollectionsTab(),
                      SnapHistoryTab(),
                      WishlistTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
