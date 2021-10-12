import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsEnglishPage extends StatefulWidget {
  const TermsAndConditionsEnglishPage({Key? key}) : super(key: key);

  @override
  _TermsAndConditionsEnglishPageState createState() =>
      _TermsAndConditionsEnglishPageState();
}

class _TermsAndConditionsEnglishPageState
    extends State<TermsAndConditionsEnglishPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var _tc_english;
  var _line1;
  var _line2;
  var _line3;
  var _line4;

  @override
  void initState() {
    super.initState();
    this.getTCEnglish;
  }

  Future getTCEnglish() async {
    await FirebaseFirestore.instance
        .collection('termsAndConditions')
        .doc('1')
        .get()
        .then((value) {
      _tc_english = value.data()!['english'];
    });

    _line1 = await _tc_english.split('  By accessing')[0];
    _line2 = await _tc_english.split('eTraffic!  ')[1].split('  The following terminology')[0];
    _line3 = await _tc_english.split('  Cookies ')[1].split(' All intellectual property')[0];
    _line4 = await _tc_english.split('material on eTraffic. ')[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(10),
          color: Colors.lightBlue[50],
          child: FutureBuilder(
              future: getTCEnglish(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Center(
                      child: Text('none'),
                    );
                  case ConnectionState.active:
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  case ConnectionState.done:
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: <Widget>[
                          Text(
                            _line1,
                            style: TextStyle(
                                letterSpacing: 1, wordSpacing: 1, height: 1.3),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _line2,
                            style: TextStyle(
                                letterSpacing: 1, wordSpacing: 1, height: 1.3),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _line3,
                            style: TextStyle(
                                letterSpacing: 1, wordSpacing: 1, height: 1.3),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _line4,
                            style: TextStyle(
                                letterSpacing: 1, wordSpacing: 1, height: 1.3),
                          ),
                        ],
                      )
                    );
                }
              })),
    );
  }
}
