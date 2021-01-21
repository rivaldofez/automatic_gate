import 'package:automatic_gate/constant/constants.dart';
import 'package:automatic_gate/model/dataRaspberry.dart';
import 'package:automatic_gate/utils/auth_helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toggle_switch/toggle_switch.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int tabIndex = 0;
  double threshold, calibrate;

  // final referenceDatabase = FirebaseDatabase.instance;
  final ref = FirebaseDatabase.instance.reference().child("Data");
  var retrieveData = "";


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _mainScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Automatic Gate"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout,color: Colors.white,),
            color: Colors.white,
            onPressed: (){
              AuthHelper.logOut();
            },
          ),
        ],
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          onTap: (int index) {
            setState(() {
              tabIndex = index;
            });
          },
          tabs: [
            Tab(
              icon: Icon(Icons.home_work),
            ),
            Tab(
              icon: Icon(Icons.thermostat_rounded),
            ),
            Tab(
              icon: Icon(Icons.add_road_rounded),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              !snapshot.hasError &&
              snapshot.data.snapshot.value != null) {
            print("Snapshot Data : ${snapshot.data.snapshot.value.toString()}");

            var _dataRaspberry =
                DataRaspberry.fromJSON(snapshot.data.snapshot.value);
            print(
                "Data Raspberry : ${_dataRaspberry.ambient} / ${_dataRaspberry.relay} / ${_dataRaspberry.threshold}");
            return IndexedStack(
              index: tabIndex,
              children: [
                _tempAmbientLayout(_dataRaspberry),
                _tempObjectLayout(_dataRaspberry),
                _calibrateMenu()
              ],
            );
          } else {
            return Center(
              child: Text("No Data On Database"),
            );
          }
        },
      ),
    );
  }

  Widget _tempObjectLayout(DataRaspberry _dataRaspberry) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 40),
            child: Text(
              "Object Temperature",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: FAProgressBar(
                progressColor: Colors.green,
                direction: Axis.vertical,
                verticalDirection: VerticalDirection.up,
                size: 100,
                currentValue: _dataRaspberry.object.round(),
                changeColorValue: 100,
                changeProgressColor: Colors.red,
                maxValue: 100,
                displayText: "C",
                borderRadius: 16,
                animatedDuration: Duration(microseconds: 500),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              "${_dataRaspberry.object.round().toStringAsFixed(2)} C",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tempAmbientLayout(DataRaspberry _dataRaspberry) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 40),
            child: Text(
              "Ambient Temperature",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: FAProgressBar(
                progressColor: Colors.blue,
                direction: Axis.vertical,
                verticalDirection: VerticalDirection.up,
                size: 100,
                currentValue: _dataRaspberry.ambient.round(),
                changeColorValue: 100,
                changeProgressColor: Colors.red,
                maxValue: 100,
                displayText: "C",
                borderRadius: 16,
                animatedDuration: Duration(microseconds: 500),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 40),
            child: Text(
              "${_dataRaspberry.ambient.round().toStringAsFixed(2)} C",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calibrateMenu(){
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10,),
                Text(
                    "Settings",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  ),
                ),
                _buildThresholdRow(),
                _buildCalibrateRow(),
                _buildSetValue()
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10,),
                Text(
                  "Relay State",
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                _buildRelayState()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdRow() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
        onChanged: (value) {
          setState(() {
            threshold = double.parse(value);
          });
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.thermostat_rounded,
              color: mainColor,
            ),
            labelText: "Threshold"),
      ),
    );
  }

  Widget _buildCalibrateRow() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
        onChanged: (value) {
          setState(() {
            calibrate = double.parse(value);
          });
        },
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.precision_manufacturing_sharp,
              color: mainColor,
            ),
            labelText: "Calibrate"),
      ),
    );
  }

  Widget _buildSetValue() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 1.4 * (MediaQuery.of(context).size.height / 20),
          width: 5 * (MediaQuery.of(context).size.width / 8),
          margin: EdgeInsets.symmetric(vertical: 20),
          child: RaisedButton(
            elevation: 5.0,
            color: mainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: (){
              ref.child("threshold").set(threshold);
              ref.child("calibrate").set(calibrate);
            },
            child: Text(
              "Set Value",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: MediaQuery.of(context).size.height / 40,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelayState(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(10.0),
          child: ToggleSwitch(
            initialLabelIndex: 0,
            minWidth: 120,
            labels: [
              "Off",
              "On"
            ],
            fontSize: 22.0,
            cornerRadius: 30,
            icons: [
              Icons.power_settings_new_rounded,
              Icons.lightbulb,
            ],
            inactiveBgColor: Colors.white,
            onToggle: (int index){
              ref.child("relay").set(index);
            },
            changeOnTap: true,
            activeBgColor: mainColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _mainScaffold();
  }
}
