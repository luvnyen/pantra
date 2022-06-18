import 'dart:async';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pantra_project/pages/student_search_result.dart';
import 'package:pantra_project/pages/subpages/account.dart';
import 'package:pantra_project/pages/subpages/event.dart';
import 'package:pantra_project/pages/subpages/student.dart';
import 'package:pantra_project/pages/wishlist.dart';
import 'package:pantra_project/services/student_name.dart';
import 'package:pantra_project/utils/alignment.dart';
import 'package:pantra_project/utils/color.dart';
import 'package:pantra_project/utils/font_weight.dart';
import 'package:pantra_project/widget/text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance;

  final StudentNameService _studentNameService = StudentNameService();
  late Future<String> _futureStudentName;

  @override
  void initState() {
    super.initState();

    _futureStudentName = _studentNameService.getStudentName(
      nrp: user.currentUser!.email.toString().split("@")[0],
    );

    Future(() {
      _futureStudentName.then((value) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: TextWidget(
              str: "Welcome back, $value! 👋",
              size: 20,
              color: primary,
              weight: bold,
              alignment: center,
            ),
          ),
        );
      });
    });
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: secondary,
          title: const Text(
            'Sign Out',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
              fontSize: 15,
              color: primary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
              ),
              child: TextWidget(
                str: 'Yes',
                size: 14,
                color: white,
                weight: bold,
                alignment: center,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(red),
              ),
              child: TextWidget(
                str: 'No',
                size: 14,
                color: white,
                weight: bold,
                alignment: center,
              ),
            ),
          ],
        );
      },
    );

    await FirebaseAuth.instance.signOut();
  }

  List<Widget> pageList = <Widget>[
    const EventPage(),
    const StudentPage(),
    const AccountDetail()
  ];
  int pageIndex = 0;

  final _nameController = TextEditingController();
  bool fabOpened = false;

  @override
  Widget build(BuildContext context) {
    @override
    // ignore: unused_element
    void dispose() {
      _nameController.dispose();
      super.dispose();
    }

    Future<void> showDivisionDialog(double heightposter) async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: secondary,
            title: TextWidget(
              str: 'Search by Students by Name',
              size: MediaQuery.of(context).size.height * 0.025,
              color: primary,
              weight: bold,
              alignment: center,
            ),
            content: SizedBox(
              width: heightposter,
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: primary,
                    ),
                  ),
                  labelText: 'Ex: Sergius Tanalandi',
                  suffixIcon: Icon(Icons.search),
                  suffixIconColor: primary,
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(red),
                ),
                child: TextWidget(
                  str: 'Close',
                  size: 14,
                  color: white,
                  weight: bold,
                  alignment: center,
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(primary),
                ),
                child: TextWidget(
                  str: 'Search',
                  size: 14,
                  color: white,
                  weight: bold,
                  alignment: center,
                ),
                onPressed: () {
                  if (_nameController.text.isEmpty &&
                      _nameController.text.length < 3) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: secondary,
                          title: TextWidget(
                            str: 'Please enter at least 3 characters!',
                            size: 16,
                            color: red,
                            weight: bold,
                            alignment: center,
                          ),
                          actions: <Widget>[
                            TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  primary,
                                ),
                              ),
                              child: TextWidget(
                                str: 'OK',
                                size: 14,
                                color: white,
                                weight: bold,
                                alignment: center,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    var name = _nameController.text;
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudentSearchResult(
                          name: name,
                        ),
                      ),
                    );

                    setState(() {
                      _nameController.clear();
                    });
                  }
                },
              ),
            ],
          );
        },
      );
    }

    final user = FirebaseAuth.instance;
    double heightposter = 0;
    if (MediaQuery.of(context).size.height >
        MediaQuery.of(context).size.width) {
      heightposter = (MediaQuery.of(context).size.width * 0.75);
    } else {
      heightposter = (MediaQuery.of(context).size.height * 0.75);
    }
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: white,
        color: secondary,
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        items: const [
          Icon(
            Icons.celebration_rounded,
            color: primary,
          ),
          Icon(
            Icons.people_alt,
            color: primary,
          ),
          Icon(
            Icons.person,
            color: primary,
          ),
        ],
      ),
      backgroundColor: white,
      body: pageList[pageIndex],
      floatingActionButton: SpeedDial(
        overlayOpacity: 0.9,
        backgroundColor: primary,
        onOpen: () {
          setState(() {
            fabOpened = true;
          });
        },
        onClose: () {
          setState(() {
            fabOpened = false;
          });
        },
        children: [
          SpeedDialChild(
            child: const Icon(
              FontAwesomeIcons.arrowRightFromBracket,
              color: red,
            ),
            labelWidget: TextWidget(
              str: 'Sign Out',
              size: 14,
              color: primary,
              weight: bold,
              alignment: right,
            ),
            onTap: () {
              _signOut();
            },
            backgroundColor: secondary,
          ),
          SpeedDialChild(
            child: const Icon(
              FontAwesomeIcons.magnifyingGlass,
              color: primary,
            ),
            labelWidget: TextWidget(
              str: 'Search Student by Name',
              size: 14,
              color: primary,
              weight: bold,
              alignment: right,
            ),
            labelShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
            onTap: () {
              showDivisionDialog(heightposter);
            },
            backgroundColor: secondary,
          ),
          SpeedDialChild(
            child: const Icon(
              FontAwesomeIcons.solidHeart,
              color: primary,
            ),
            labelWidget: TextWidget(
              str: 'Your Events Wishlist',
              size: 14,
              color: primary,
              weight: bold,
              alignment: right,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WishlistPage(
                    nrp: user.currentUser!.email.toString().split("@")[0],
                  ),
                ),
              );
            },
            backgroundColor: secondary,
          ),
        ],
        child: Icon(
          fabOpened ? Icons.close : Icons.menu,
          color: secondary,
        ),
      ),
    );
  }
}
