import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:page_transition/page_transition.dart';

import '../../constants.dart';
import './widgets/rock_list_item.dart'; // Import the RockListItem widget

class SelectRockPage extends StatefulWidget {
  final bool isSavingRock;
  final bool? isFavoritingRock;
  const SelectRockPage({
    super.key,
    required this.isSavingRock,
    this.isFavoritingRock,
  });

  @override
  _SelectRockPageState createState() => _SelectRockPageState();
}

class _SelectRockPageState extends State<SelectRockPage> {
  final List<Rock> _rockList = Rock.rockList;
  List<Rock> _filteredRockList = Rock.rockList;

  final _searchRocks = FocusNode();

  void _saveRock(Rock rock) async {
    Navigator.push(
        context,
        PageTransition(
            child: RockDetailPage(
              rock: rock,
              isSavingRock: widget.isSavingRock,
              isFavoritingRock: widget.isFavoritingRock,
            ),
            type: PageTransitionType.bottomToTop));
  }

  void _filterRocks(String query) {
    setState(() {
      _filteredRockList = _rockList
          .where((rock) =>
              rock.rockName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _searchRocks.requestFocus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
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
                    hintStyle: TextStyle(color: Constants.white),
                    hintText: 'Search for rocks',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Constants.primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  style: TextStyle(color: Constants.white),
                  onChanged: (query) {
                    _filterRocks(query);
                  },
                ),
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredRockList.length,
                  itemBuilder: (context, index) {
                    final rock = _filteredRockList[index];
                    return RockListItem(
                      imageUrl: rock.imageURL.isNotEmpty && rock.imageURL != ''
                          ? rock.imageURL
                          : 'https://via.placeholder.com/60', // Use a placeholder image if none available
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
}
