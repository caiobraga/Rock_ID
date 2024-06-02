import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/plant_widget.dart';
import 'package:page_transition/page_transition.dart';

import '../../services/botton_nav.dart';
import '../../services/selection_modal.dart';
import '../scan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Rock> _RockList;
  double price = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    try {
      DatabaseHelper().rocks().then((value) {
        _RockList = value;
        _calculateTotalPrice();
        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _calculateTotalPrice() {
    double totalPrice = 0;
    for (var rock in _RockList) {
      totalPrice += rock.price;
    }
    price = totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
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
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Handle rock collection functionality
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Constants.darkGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.share,
                                  color: Constants.primaryColor,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Share App',
                                  style: TextStyle(
                                    color: Constants.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            BottomNavService().setIndex(1);
                            // Handle rock collection functionality
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Constants.darkGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.folder_copy_rounded,
                                  color: Constants.primaryColor,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Rock Collection',
                                  style: TextStyle(
                                    color: Constants.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Constants.darkGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.minimize,
                              color: Constants.primaryColor,
                            ),
                            Text(
                              '${_RockList.length}',
                              style: TextStyle(
                                color: Constants.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Rocks',
                                style: TextStyle(
                                  color: Constants.white.withAlpha(100),
                                )),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: Constants.primaryColor,
                            ),
                            Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Constants.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Value (USD)',
                                style: TextStyle(
                                  color: Constants.white.withAlpha(100),
                                )),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.science_rounded,
                              color: Constants.primaryColor,
                            ),
                            Text(
                              '1',
                              style: TextStyle(
                                color: Constants.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Country',
                                style: TextStyle(
                                  color: Constants.white.withAlpha(100),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Handle recognition functionality
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      width: size.width * 0.8,
                      height: size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Constants.darkGrey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: (){
                          ShowSelectionModalService().show(context);
                          //
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/rocktap.png', height: 100),
                            SizedBox(height: 10),
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                            ),
                            SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                              margin: const EdgeInsets.all(4.0) ,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Constants.primaryColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                    50), 
                              ),
                              child: Text(
                                'TAP HERE',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Constants.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'TO RECOGNIZE YOUR ROCK',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                color: Constants.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
