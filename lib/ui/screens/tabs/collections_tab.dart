import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/services/selection_modal.dart';
import 'package:flutter_onboarding/ui/screens/detail_page.dart';
import 'package:flutter_onboarding/ui/screens/widgets/rock_list_item.dart';
import 'package:flutter_onboarding/ui/widgets/text.dart';
import 'package:page_transition/page_transition.dart';

class CollectionsTab extends StatefulWidget {
  const CollectionsTab({super.key});

  @override
  State<CollectionsTab> createState() => _CollectionsTabState();
}

class _CollectionsTabState extends State<CollectionsTab> {
  final List<Rock> _collectionRocks = [];

  @override
  void initState() {
    super.initState();
    _loadCollectionRocks();
  }

  void _loadCollectionRocks() async {
    try {
      _collectionRocks.clear();
      List<Rock> collectionRocks = await DatabaseHelper().findAllRocks();
      setState(() {
        _collectionRocks.addAll(collectionRocks);
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
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Constants.darkGrey,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Scaffold(
          backgroundColor: Constants.darkGrey,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Constants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () async {
              await ShowSelectionModalService().show(context);
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
          body: Column(
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
                    onTap: () async {
                      await ShowSelectionModalService().show(context);
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
                  itemCount: _collectionRocks.length,
                  itemBuilder: (context, index) {
                    final rock = _collectionRocks[index];

                    return RockListItem(
                      imageUrl: rock.imageURL.isNotEmpty && rock.imageURL != ''
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
                              isRemovingFromCollection: true,
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
        ),
      ),
    );
  }
}
