

import 'package:hive/hive.dart';

class RecordData{
  final _myBox=Hive.box('myList');

    List<String> list=[];
   void initialList(){
     list=[];
   }

  void writeData() {
     _myBox.put('locList',list);
  }
  void readData() {
    list= _myBox.get('locList');
  }
}