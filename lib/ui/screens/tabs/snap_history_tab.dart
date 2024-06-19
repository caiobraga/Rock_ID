import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/get_rock.dart';
import 'package:flutter_onboarding/services/image_picker.dart';
import 'package:flutter_onboarding/services/snackbar.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/loading_component.dart';
import 'package:flutter_onboarding/ui/screens/widgets/rock_list_item.dart';
import 'package:flutter_onboarding/ui/widgets/text.dart';
import 'package:page_transition/page_transition.dart';

class SnapHistoryTab extends StatefulWidget {
  const SnapHistoryTab({super.key});

  @override
  State<SnapHistoryTab> createState() => _SnapHistoryTabState();
}

class _SnapHistoryTabState extends State<SnapHistoryTab> {
  final List<Map<String, dynamic>> _history = [];
  final List<Rock> _allRocks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSnapHistory();
    _loadAllRocks();
  }

  void _loadSnapHistory() async {
    try {
      _history.clear();
      List<Map<String, dynamic>> snapHistory =
          await DatabaseHelper().snapHistory();
      setState(() {
        _history.addAll(snapHistory);
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _loadAllRocks() async {
    try {
      _allRocks.clear();
      List<Rock> allRocks = Rock.rockList;
      setState(() {
        _allRocks.addAll(allRocks);
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        right: 16.0,
        bottom: 40.0,
        left: 16.0,
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Constants.darkGrey,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Scaffold(
            backgroundColor: Constants.darkGrey,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Constants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: () {
                _addRockToSnapHistory();
              },
              child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: Constants.primaryDegrade,
                  ),
                  child: const Icon(Icons.add,
                      color: Colors.white, size: 40, weight: 40, grade: 20)),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniEndFloat,
            body: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: Constants.primaryDegrade,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.0),
                          onTap: () {
                            _addRockToSnapHistory();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.crop_free, color: Colors.white),
                              SizedBox(width: 12),
                              DSCustomText(
                                text: 'Identify Rock',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          final rockId = _history[index]['rockId'];
                          final rock = _allRocks.firstWhere(
                              (rock) => rock.rockId == rockId,
                              orElse: () => Rock.empty());
                          return RockListItem(
                            imageUrl:
                                rock.imageURL.isNotEmpty && rock.imageURL != ''
                                    ? rock.imageURL
                                    : 'https://via.placeholder.com/60',
                            title: rock.rockName,
                            tags: const ['Sulfide minerals', 'Mar', 'Jul'],
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  child: RockDetailPage(
                                    rock: rock,
                                    isSavingRock: false,
                                  ),
                                  type: PageTransitionType.bottomToTop,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                if (_isLoading)
                  const Center(
                    child: LoadingComponent(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addRockToSnapHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final _image = await ImagePickerService().pickImageFromCamera(context);
      final _rock = await GetRockService().getRock(_image);
      String timestamp = DateTime.now().toIso8601String();
      await DatabaseHelper().addRockToSnapHistory(_rock.rockId, timestamp);
      _loadSnapHistory;
    } catch (e) {
      ShowSnackbarService().showSnackBar(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}