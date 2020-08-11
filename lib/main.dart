import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class Month {
  final List<DateData> monthData;

  Month({this.monthData});

  factory Month.fromJson(Map<String, dynamic> parsedJson) {
    var monthDataFromJson = parsedJson['monthData'] as List;
    List<DateData> monthDataList = List<DateData>.from(monthDataFromJson.map((i) => DateData.fromJson(i)));
    return new Month(
        monthData: monthDataList
    );
  }
}

class DateData {
  final List<String> dateData;

  DateData({this.dateData});

  factory DateData.fromJson(Map<String, dynamic> parsedJson) {
    var dateDataFromJson = parsedJson['dateData'];
    List<String> dateDataList = new List<String>.from(dateDataFromJson);
    return DateData(
        dateData: dateDataList
    );
  }
}

Future<String> _loadMonthAsset(selectedMonth) async {
  return await rootBundle.loadString('assets/${selectedMonth}.json');
}

Future<Month> loadMonth(selectedMonth) async {
  String jsonMonth = await _loadMonthAsset(selectedMonth);
  final jsonResponse = json.decode(jsonMonth);
  Month month = new Month.fromJson(jsonResponse);
//  print(month.monthData[1]);
  return month;
}

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panchangam',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/selectedDay': (context) => SelectedDay(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarController _controller;

  @override
  void initState() {
    //TODO: implement initState
    super.initState();
    _controller = CalendarController();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Panchangam'),
      ), //AppBar
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TableCalendar(
              initialCalendarFormat: CalendarFormat.month,
              calendarStyle: CalendarStyle(
                todayColor: Colors.orange,
                selectedColor: Theme.of(context).primaryColor,
                todayStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.white
                )
              ),
              headerStyle: HeaderStyle(
                centerHeaderTitle: true,
                formatButtonShowsNext: false,
              ),
              startingDayOfWeek: StartingDayOfWeek.sunday,
              onDaySelected: (date, events) {
                print(date.toIso8601String());
                Navigator.pushNamed(context, '/selectedDay', arguments: date);
              },
              calendarController: _controller,)
          ],
        ), // Column
      ), // SingleChildScrollView
    ); // Scaffold
  }
}

class SelectedDay extends StatefulWidget {
  @override
  _SelectedDayState createState() => _SelectedDayState();
}

class _SelectedDayState extends State<SelectedDay> {
  Widget futureWidget(date, selectedMonth) {
    return new FutureBuilder<Month>(
      future: loadMonth(selectedMonth),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.monthData[date- 1].dateData.length,
              itemBuilder: (context, index) {
                return Column (
                  children: <Widget>[
                    Text(snapshot.data.monthData[date - 1].dateData[index])
                  ],
                );
              },
          );
        } else if (snapshot.hasError) {
          final error = snapshot.error;
          return new Text("Sorry, something went wrong! 😱");
        }
        return Center(
          child: CircularProgressIndicator()
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime selectedDate = ModalRoute.of(context).settings.arguments;
    final String formattedDate = new DateFormat.yMMMMd('en_US').format(selectedDate); // July 20, 2020
    final int date = int.parse(new DateFormat.d('en_US').format(selectedDate)); // 20
    final int selectedMonth = int.parse(new DateFormat.M('en_US').format(selectedDate)); // 07
    return Scaffold(
      appBar: AppBar(
        title: Text('$formattedDate'),
      ),
      body: Center(
        child: (selectedMonth < 8) ?
         new Text("Sorry, we don't know everything. 🤷‍♀️") : futureWidget(date, selectedMonth)
      )
    );
  }
}