import 'package:automatic_gate/model/dataRaspberry.dart';
import 'package:automatic_gate/utils/auth_helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{



  final referenceDatabase = FirebaseDatabase.instance;
  var retrieveData="";
  String name="";


  Widget _mainScaffold(){
    final ref = referenceDatabase.reference().child("Data");
    return Scaffold(
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot){
          if(snapshot.hasData &&
          !snapshot.hasError &&
          snapshot.data.snapshot.value != null){
            print("Snapshot Data : ${snapshot.data.snapshot.value.toString()}");

            var _dataRaspberry = DataRaspberry.fromJSON(snapshot.data.snapshot.value);
              print("Data Raspberry : ${_dataRaspberry.ambient} / ${_dataRaspberry.relay} / ${_dataRaspberry.threshold}" );

          }else{}
          return Container();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = referenceDatabase.reference().child("Data");
    return _mainScaffold();
  }
}





