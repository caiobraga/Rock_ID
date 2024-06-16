import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';

import '../../../models/collection.dart';
import '../../../services/add_new_collection_modal.dart';
import '../../../services/collection_list_model.dart';
import 'collection.dart';

class CollectionGridView extends StatefulWidget {
  final bool hasAddOption;
  final List<Collection> collections;
  final void Function() onItemAdded;
  final GlobalKey<_CollectionGridViewState> gridKey =
      GlobalKey<_CollectionGridViewState>();

  CollectionGridView({
    super.key,
    required this.hasAddOption,
    required this.onItemAdded,
    required this.collections,
  });

  @override
  State<CollectionGridView> createState() => _CollectionGridViewState();
}

class _CollectionGridViewState extends State<CollectionGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: widget.hasAddOption
          ? widget.collections.length + 1
          : widget.collections.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == widget.collections.length && widget.hasAddOption) {
          return GestureDetector(
            onTap: () {
              AddNewCollectionModalService().show(context, () {
                widget.onItemAdded();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline,
                      color: Constants.primaryColor, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    'ADD NEW COLLECTION',
                    style: AppTypography.body1(color: Constants.white),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          );
        } else {
          final collection = widget.collections[index];
          return CollectionWidget(
            title: collection.collectionName,
            isSavedLayout: collection.collectionName == 'Saved',
            rockCount: 0,
            rockImages: collection.collectionName == 'Saved'
                ? []
                : [
                    'assets/images/rock1.png',
                    'assets/images/rock1.png',
                    // Add actual rock images here
                  ],
            onTap: () {
              CollectionListModelService()
                  .show(context, widget.collections[index].collectionId);
            },
          );
        }
      },
    );
  }
}
