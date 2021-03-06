import 'dart:convert' show base64Decode, jsonDecode;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:memory_ever/classes/history/history.dart';
import 'package:memory_ever/classes/person/person.dart';
import 'package:memory_ever/constants.dart';
import 'package:memory_ever/screens/main/bottom_bar/bottom_bar.dart';
import 'package:memory_ever/screens/main/card_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanHistory extends StatefulWidget {
  @override
  _ScanHistoryState createState() => _ScanHistoryState();
}

class _ScanHistoryState extends State<ScanHistory> {
  bool isLoading = true;

  bool showCardInfo = false;

  History selectedHistory;

  List<History> histories = [];

  String selectedUrl = '';

  void fetchHistoryFromStorage() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var historyList = prefs.getStringList('history') ?? [];

      setState(() {
        isLoading = false;
        histories = historyList.isNotEmpty
            ? historyList
            .where((item) => item != 'null')
            .map(
              (string) => History.fromJson(jsonDecode(string)),
        )
            .toList()
            : [];
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void closeCardInfo() {
    setState(() {
      showCardInfo = false;
    });
  }

  void openScanner(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/scan');
  }

  String getBackgroundPath(history) {
    print('scan history url ${history.url}');
    print('scan history description ${history.description}');
    print('scan history people length ${history.people.length}');
    print('scan history theme ${history.theme}');
    switch (history.theme) {
      case 'sky':
        return 'assets/bgSky1.png';
      case '星空風格':
        return 'assets/bgSky1.png';
      case 'sky2':
        return 'assets/bgSky2.png';
      case '藍天風格':
        return 'assets/bgSky2.png';
      case 'sea':
        return 'assets/bgSea.png';
      case '晨海風格':
        return 'assets/bgSea.png';
      case 'deepsea':
        return 'assets/bgDeepSea.png';
      case '深海風格':
        return 'assets/bgDeepSea.png';
      case 'flower':
        return 'assets/bgFlower.png';
      case '花田風格':
        return 'assets/bgFlower.png';
      case 'story':
        return 'assets/bgStory.png';
      case '童話風格':
        return 'assets/bgStory.png';
      default:
        return 'assets/bgSky2.png';
    }
  }

  List<Builder> renderCards() => histories
      .map((history) => Builder(
            builder: (context) => GestureDetector(
                  onTap: () {
                    setState(() {
                      showCardInfo = true;
                      selectedHistory = history;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: ExactAssetImage(getBackgroundPath(history)),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(0, 101, 190, 0.16),
                              offset: Offset(0, 12),
                              blurRadius: 12)
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: history.people.map(renderPerson).toList(),
                    ),
                  ),
                ),
          ))
      .toList();

  Column renderPerson(Person person) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 5,
              ),
            ),
            child: Image.memory(
              base64Decode(person.imageBase64),
              semanticLabel: '${person.name} 的遺照',
              height: 250,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              person.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 5,
              ),
            ),
          ),
          Text(
            person.hometown,
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 3,
            ),
          ),
          Text(
            person.age.toString(),
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 3,
            ),
          ),
        ],
      );

  CardInfo renderCardInfo() => showCardInfo
      ? CardInfo(
          info: selectedHistory,
          onClose: closeCardInfo,
        )
      : null;

  @override
  void initState() {
    super.initState();

    fetchHistoryFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25, right: 25, left: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '掃描歷史',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 30,
                          letterSpacing: 5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          openScanner(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(5),
                          color: primaryColor,
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                  child: histories.isEmpty && isLoading
                        ? SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(),
                          )
                        : CarouselSlider(
                            height: 480,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: false,
                            autoPlay: false,
                            items: renderCards(),
                          ),
                  ),
                ),
                BottomBar(activeRoute: '/history'),
              ],
            ),
            renderCardInfo(),
          ].where((widget) => widget != null).toList(),
        ),
      ),
    );
  }
}
