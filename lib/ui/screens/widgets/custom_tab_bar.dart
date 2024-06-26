import 'package:flutter/material.dart';

class CustomTabBar extends StatefulWidget {
  final TabController tabController;
  final List<String> tabsDescriptions;

  const CustomTabBar({
    super.key,
    required this.tabController,
    required this.tabsDescriptions,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: widget.tabController,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(
            30), // Creates border radius for the indicator
        color: Colors.grey[800], // Change the background color
      ),
      unselectedLabelColor: Colors.grey,
      labelColor: Colors.white,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      labelPadding: const EdgeInsets.only(top: 4, bottom: 4),
      dividerHeight: 0,
      tabs: widget.tabsDescriptions.map((tabDescription) {
        return Tab(
          height: 25,
          text: tabDescription,
        );
      }).toList(),
    );
  }
}
