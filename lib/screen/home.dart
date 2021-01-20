import 'package:automatic_gate/model/dataModel.dart';
import 'package:automatic_gate/utils/auth_helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final referenceDatabase = FirebaseDatabase.instance;
  var retrieveData="";
  String name="";

  @override
  Widget build(BuildContext context) {
    final ref = referenceDatabase.reference().child("Data");
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Home Page"),
            RaisedButton(
              child: Text("Logout"),
              onPressed: (){
                AuthHelper.logOut();
              },
            ),
            RaisedButton(
              child: Text("Set Data"),
              onPressed: (){
                ref.child("ambient").set(name);
              },
            ),
            RaisedButton(
              child: Text("Read Data"),
              onPressed: (){
                ref.child("ambient").once().then((DataSnapshot data) {
                  setState(() {
                    print(data.value);
                  });
                });
              },
            ),
            TextField(
              onChanged: (val){
                setState(() {
                  name = val;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}

