import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/services/snackbar.dart';

class SelectNewRockAndAddToCollection {
  final BuildContext context;
  final int collectionId;

  SelectNewRockAndAddToCollection(this.context, this.collectionId);

  Future<void> action() async {
    List<Rock> rocks = await DatabaseHelper().rocks();

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.black,
          child: ListView.builder(
            itemCount: rocks.length,
            itemBuilder: (BuildContext context, int index) {
              final rock = rocks[index];
              return ListTile(
                title: Text(
                  rock.rockName,
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  rock.description,
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    await DatabaseHelper().addRockToCollection(rock.rockId, collectionId);
                    Navigator.pop(context);
                    ShowSnackbarService().showSnackBar('${rock.rockName} was added to the collection!');
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
