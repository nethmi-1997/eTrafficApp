import 'dart:io';
import 'package:etraffic/model/violation_data_model.dart';
import 'package:etraffic/page/violation_details_view_page.dart';
import 'package:etraffic/widget/avatar_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:etraffic/widget/profile_picture_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'package:image_picker/image_picker.dart';

class SubmissionsListPage extends StatefulWidget {
  const SubmissionsListPage({Key? key}) : super(key: key);

  @override
  _SubmissionsListPageState createState() => _SubmissionsListPageState();
}

class _SubmissionsListPageState extends State<SubmissionsListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseStorage storage =
      FirebaseStorage.instanceFor(bucket: 'gs://etraffic-8ba4d.appspot.com');
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  late CollectionReference _collectionRef;

  late List<ViolationDataModel> violationsList;

  @override
  void initState() {
    super.initState();
    this.getSubmissions();
  }

  Future<void> getSubmissions() async {
    user = await FirebaseAuth.instance.currentUser!;
    _collectionRef = await FirebaseFirestore.instance
        .collection('violations')
        .doc(user!.uid)
        .collection('violation');

    QuerySnapshot querySnapshot = await _collectionRef.get();

    List allData = await querySnapshot.docs.map((doc) => doc.data()).toList();

    violationsList = await List.generate(
        allData.length,
        (index) => ViolationDataModel(
            allData[index]['imageUrl'],
            allData[index]['description'],
            allData[index]['comment'],
            allData[index]['location'],
            allData[index]['status']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightBlue[50],
        appBar: AppBar(
          title: Text('Submissions List'),
          centerTitle: true,
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          backwardsCompatibility: false,
        ),
        body: FutureBuilder(
            future: getSubmissions(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('none');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                case ConnectionState.done:
                  return ListView.builder(
                      itemCount: violationsList.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ViolationDetailsViewPage(
                                        violationDataModel:
                                            violationsList[index])));
                          },
                          child: Container(
                              height: 150,
                              child: Card(
                                color: Colors.blue[400],
                                elevation: 5,
                                child: Row(
                                  children: <Widget>[
                                    Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              10, 6, 5, 0),
                                          child: Image.network(
                                            violationsList[index].imageUrl,
                                            fit: BoxFit.cover,
                                            height: 130,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                10, 25, 5, 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  violationsList[index].description,
                                                  style: TextStyle(
                                                      fontFamily: 'Nunito Sans',
                                                      fontSize: 15,
                                                      color: Colors.white70,
                                                      fontWeight: FontWeight.w700,
                                                      height: 2
                                                    ),
                                                  ),
                                                Text(
                                                  violationsList[index].comment,
                                                  style: TextStyle(
                                                      fontFamily: 'Nunito Sans',
                                                      fontSize: 15,
                                                      color: Colors.white70,
                                                      fontWeight: FontWeight.w700,
                                                      height: 1.5
                                                    ),
                                                ),
                                                Text(
                                                  violationsList[index].status,
                                                  style: TextStyle(
                                                      fontFamily: 'Nunito Sans',
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      height: 1.5,
                                                      shadows: <Shadow>[
                                                        Shadow(
                                                          offset: Offset(0.0, 0.0),
                                                          blurRadius: 2.0,
                                                          color: (violationsList[index].status == 'Submitted') ? (Colors.black)  : (Colors.lightBlue[50])!,
                                                      )],
                                                      color: (violationsList[index].status == 'Submitted') 
                                                      ? Colors.lightGreen[300]
                                                      : (violationsList[index].status == 'In review') 
                                                      ? Colors.orange[900]
                                                      : (violationsList[index].status == 'Rejected') 
                                                      ? Colors.red[800]
                                                      : Colors.green[800]
                                                    ),
                                                )
                                              ],
                                            )),
                                      ],
                                    ),
                                  ],
                                ),

                                // ListTile(
                                //   title: Column(
                                //     children: [
                                //       Text(violationsList[index].description),
                                //       Text(violationsList[index].comment),
                                //       Text(violationsList[index].status)
                                //     ],
                                //   ),
                                //   leading: Image.network(
                                //               violationsList[index].imageUrl,
                                //               fit: BoxFit.cover,
                                //             ),
                                //   onTap: () {
                                //     Navigator.of(context).push(MaterialPageRoute(
                                //         builder: (context) =>
                                //             ViolationDetailsViewPage(
                                //                 violationDataModel:
                                //                     violationsList[index])));
                                //   },
                                // ),
                              ))
                              );

                        // Container(
                        //   height: 150,
                        //     child: Card(
                        //       color: Colors.blue[400],
                        //       elevation: 5,
                        //       child: Row(
                        //         children: <Widget>[
                        //           Column(
                        //             children: [
                        //               Padding(
                        //                 padding: EdgeInsets.fromLTRB(10, 6, 5, 0),
                        //                 child: Image.network(
                        //                   violationsList[index].imageUrl,
                        //                   fit: BoxFit.cover,
                        //                   height: 130,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //           Column(
                        //             children: [
                        //               Padding(
                        //                 padding: EdgeInsets.fromLTRB(10, 40, 5, 0),
                        //                 child: Column(
                        //                   crossAxisAlignment: CrossAxisAlignment.start,
                        //                   children: [
                        //                     Text(violationsList[index].description),
                        //                     Text(violationsList[index].comment),
                        //                     Text(violationsList[index].status)
                        //                   ],
                        //                 )
                        //               ),
                        //             ],
                        //           ),
                        //         ],
                        //       ),

                        //       // ListTile(
                        //       //   title: Column(
                        //       //     children: [
                        //       //       Text(violationsList[index].description),
                        //       //       Text(violationsList[index].comment),
                        //       //       Text(violationsList[index].status)
                        //       //     ],
                        //       //   ),
                        //       //   leading: Image.network(
                        //       //               violationsList[index].imageUrl,
                        //       //               fit: BoxFit.cover,
                        //       //             ),
                        //       //   onTap: () {
                        //       //     Navigator.of(context).push(MaterialPageRoute(
                        //       //         builder: (context) =>
                        //       //             ViolationDetailsViewPage(
                        //       //                 violationDataModel:
                        //       //                     violationsList[index])));
                        //       //   },
                        //       // ),
                        //     ));
                      });
              }
            }));
  }
}
