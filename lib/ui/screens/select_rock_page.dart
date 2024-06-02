import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/db/db.dart';

class SelectRockPage extends StatefulWidget {
  @override
  _SelectRockPageState createState() => _SelectRockPageState();
}

class _SelectRockPageState extends State<SelectRockPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _saveRock(Rock rock) async {
    await _dbHelper.insertRock(rock);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${rock.rockName} foi salvo!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione uma Rocha'),
      ),
      body: ListView.builder(
        itemCount: Rock.RockList.length,
        itemBuilder: (context, index) {
          final rock =  Rock.RockList[index];
          return ListTile(
            title: Text(rock.rockName),
            subtitle: Text(rock.description),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => _saveRock(rock),
          );
        },
      ),
    );
  }
}