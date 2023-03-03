import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../database/data.dart';

class ListOfRecords extends StatefulWidget {
  const ListOfRecords({Key? key}) : super(key: key);

  @override
  State<ListOfRecords> createState() => _ListOfRecordsState();
}

class _ListOfRecordsState extends State<ListOfRecords> {
  RecordData data = RecordData();
  final _myBox = Hive.box('myList');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(_myBox.get('locList')==null){
      data.initialList();
    }else{
      data.readData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of searched Cities'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ListView.builder(
          reverse: true,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Text(data.list[index]),
            );
          },
          itemCount: data.list.length,
        ),
      ),
    );
  }
}
