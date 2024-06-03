import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:page_transition/page_transition.dart';

import '../../constants.dart';
import '../scan_page.dart';

class SelectRockPage extends StatefulWidget {
  bool is_saving_rock;
  SelectRockPage({required this.is_saving_rock});

  @override
  _SelectRockPageState createState() => _SelectRockPageState();
}

class _SelectRockPageState extends State<SelectRockPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Rock> _rockList = Rock.RockList;
  List<Rock> _filteredRockList = Rock.RockList;


  void _saveRock(Rock rock) async {
    if(widget.is_saving_rock){
      await _dbHelper.insertRock(rock);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${rock.rockName} foi salvo!')),
      );
      Navigator.of(context).pop();
    }else{
      Navigator.push(context, PageTransition(child: RockDetailPage(rock: rock), type: PageTransitionType.bottomToTop));
    }
    
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: Colors.black,
       leading: IconButton(
          icon: Icon(Icons.arrow_back,
          color: Constants.primaryColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
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
              style: TextStyle(
                color: Constants.white
              ),
              onChanged: (query) {
                _filterRocks(query);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRockList.length,
              itemBuilder: (context, index) {
                final rock = _filteredRockList[index];
                return ListTile(
                  title: Text(rock.rockName),
                  subtitle: Text(rock.description),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => _saveRock(rock),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}