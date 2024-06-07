import 'package:flutter/material.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:page_transition/page_transition.dart';

import '../../constants.dart';

class SelectRockPage extends StatefulWidget {
  final bool isSavingRock;
  const SelectRockPage({Key? key, required this.isSavingRock})
      : super(key: key);

  @override
  _SelectRockPageState createState() => _SelectRockPageState();
}

class _SelectRockPageState extends State<SelectRockPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<Rock> _rockList = Rock.RockList;
  List<Rock> _filteredRockList = Rock.RockList;

  final _searchRocks = FocusNode();

  void _saveRock(Rock rock) async {
    /*if (widget.isSavingRock) {
      await _dbHelper.insertRock(rock);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${rock.rockName} foi salvo!')),
      );
      Navigator.of(context).pop();
    } else {*/
      Navigator.push(
          context,
          PageTransition(
              child: RockDetailPage(rock: rock, isSavingRock: widget.isSavingRock),
              type: PageTransitionType.bottomToTop));
    //}
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
      Future.delayed(const Duration(seconds: 1), () {
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
                    return Card(
                      color: Constants.darkGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15.0),
                        leading: rock.imageURL.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: AssetImage(rock
                                    .imageURL), // Assuming you have images for the rocks
                                radius: 30.0,
                              )
                            : CircleAvatar(
                                backgroundColor: Constants.primaryColor,
                                radius: 30.0,
                                child: Text(
                                  rock.rockName[0],
                                  style: TextStyle(
                                    color: Constants.white,
                                    fontSize: 24.0,
                                  ),
                                ),
                              ),
                        title: Text(
                          rock.rockName,
                          style: TextStyle(
                            color: Constants.white,
                            fontSize: 18.0,
                          ),
                        ),
                        subtitle: Text(
                          rock.description,
                          style: TextStyle(
                            color: Constants.white,
                            fontSize: 14.0,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () => _saveRock(rock),
                      ),
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
