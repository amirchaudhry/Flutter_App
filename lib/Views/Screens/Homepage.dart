import 'package:analog/Model/LocalUser.dart';
import 'package:analog/Model/Reminder.dart';
import 'package:analog/SettingsPage.dart';
import 'package:analog/Views/Reminder/AddService.dart';
import 'package:analog/Views/Reminder/ReminderWidget.dart';
import 'package:analog/services/AuthService.dart';
import 'package:analog/services/DatabaseManager.dart';
import 'package:analog/services/NotificationService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class Homepage extends StatefulWidget {
  Homepage({Key? key, required this.title, required this.userId})
      : super(key: key);

  final String title;
  final String userId;
  final reminderManager = DatabaseManager();
  final notificationService = NotificationService();
  final _authService = AuthService();
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Homepage> {
  final _scrollController = ScrollController();
  List<Reminder> reminderList = [];
  // Currency Formatter
  final curFormatter = new NumberFormat('#,##0', 'en_US');
  late DatabaseReference _reminderRef;
  String localId = '';
  double totalAmount = 0.0;

  getUser() {
    print('HOMEPAGE: Getting User ID ....');
    if (widget.userId.isEmpty) {
      this.localId = widget._authService.getCurrentUser()!.uid;
    }
  }

  @override
  void initState() {
    super.initState();
    // Get the total amount
    _reminderRef = FirebaseDatabase.instance.reference().child(widget.userId);

    getUser();
    if (widget.userId.isNotEmpty) {
      print('HOMEPAGE: Loading Data ....');
      loadData();
    }
  }

  void loadData() async {
    _reminderRef.child('TOTAL_AMOUNT').onValue.listen((event) {
      final jsonVal = event.snapshot.value['total_amount'].toString();
      print('HOMEPAGE: Amount - $jsonVal');
      if (jsonVal.isNotEmpty) {
        setState(() {
          totalAmount = double.parse(jsonVal) >= 0.0 ? double.parse(jsonVal) : 0.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF8DD1EF),
      body: CustomScrollView(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          // App Bar to Show Total Amount
          SliverAppBar(
            automaticallyImplyLeading: false,
            floating: true,
            backgroundColor: Color(0xFF8DD1EF),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: SafeArea(
                child: Stack(children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingsPage()),
                          );
                        },
                        icon: const Icon(Icons.settings,
                            color: Colors.deepPurple)),
                  ),
                  Center(
                      child: Card(
                          elevation: 22,
                          shape: CircleBorder(),
                          child: CircleAvatar(
                            radius: 72,
                            backgroundColor: Colors.deepPurple,
                            child: CircleAvatar(
                              radius: 69,
                              backgroundColor: Colors.white,
                              child: Center(
                                  child: Text(
                                '\$${_formatCurrency(totalAmount)}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = ui.Gradient.linear(
                                      const Offset(70, 100),
                                      const Offset(130, 10),
                                      <Color>[
                                        Colors.purpleAccent.shade400,
                                        Colors.lightBlueAccent.shade200,
                                        // Colors.purpleAccent.shade400,
                                      ],
                                    ),
                                  //color: Colors.black87,
                                ),
                              )),
                            ),
                          ))),
                ]),
              ),
            ),
            expandedHeight: 200,
          ),
          SliverToBoxAdapter(
              child: Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(bottom: 18),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, offset: Offset(0, 1))
                ]),
            child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: _getAllReminders()),
          )),
          SliverFillRemaining(
            child: Container(
              color: Colors.white,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddService(userId: widget.userId)));
        },
        tooltip: 'Add New Reminder',
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _getAllReminders() {
    return FirebaseAnimatedList(
        controller: _scrollController,
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        query: widget.reminderManager.getMessageQuery(widget.userId),
        itemBuilder: (context, DataSnapshot snapshot, animation, index) {
          if (!snapshot.exists || snapshot.value == null) {
            return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "No Reminders Added!",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 24,
                        fontWeight: FontWeight.w400),
                  ),
                ));
          }
          else {
            final jsonValue = snapshot.value as Map<dynamic, dynamic>;
            final reminderValue = Reminder.fromJson(jsonValue);
            if (!this.reminderList.contains(reminderValue))
              this.reminderList.add(reminderValue);
            return Dismissible(
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    widget.reminderManager.updateAmount(
                        widget.userId, totalAmount - reminderValue.amount);
                    calculateTotalAmount(reminderValue);
                    widget.reminderManager.deleteReminder(
                        snapshot.key!, LocalUser(uid: widget.userId));
                    reminderList.removeAt(index);
                    createSnackBar('Item Deleted at $index', context);
                    setState(() {});
                  }
                },
                key: UniqueKey(),
                background: Container(
                  color: Colors.deepOrange,
                ),
                child: ReminderWidget(
                    userId: widget.userId,
                    dbKey: snapshot.key!,
                    serviceName: reminderValue.serviceName,
                    dueDate: reminderValue.dueDate,
                    amount: reminderValue.amount.toString(),
                    remindDate: reminderValue.setReminder));
          }
        },
        defaultChild: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Loading Reminders...",
            style: TextStyle(
                color: Colors.black54,
                fontSize: 24,
                fontWeight: FontWeight.w400),
          ),
        )));
  }

  void createSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$message')));
  }

  calculateTotalAmount(Reminder remObj) {
    double newAmt = totalAmount - remObj.amount;
    if (newAmt >= 0.0) {
      totalAmount = newAmt;
    }
    else {
      totalAmount = 0.0;
    }
    setState(() {});
  }

  _formatCurrency(num) {
    return curFormatter.format(double.parse(num.toStringAsFixed(0)));
  }
}
