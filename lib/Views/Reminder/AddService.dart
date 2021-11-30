import 'package:analog/Model/LocalUser.dart';
import 'package:analog/services/NotificationService.dart';
import 'package:analog/services/DatabaseManager.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:analog/Model/Reminder.dart';
import 'package:intl/intl.dart';

class AddService extends StatefulWidget {
  AddService({Key? key, required this.userId}) : super(key: key);
  final reminderManager = DatabaseManager();
  final String userId;
  final notificationService = NotificationService();
  @override
  _AddServiceState createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final formGlobalKey = GlobalKey<FormState>();
  String dropdownvalue = '';
  var reminderOption = [
    '',
    '1 Day Before',
    '2 Day Before',
    '3 Day Before',
    '4 Day Before',
    '5 Day Before',
    '6 Day Before',
    '1 Week Before'
  ];

  TextEditingController serviceNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  final format = DateFormat('MM/dd/yyyy');
  DateTime dueDate = DateTime.now();
  double totalAmount = 0.0;

  void getUserData() async {
    totalAmount =
        await widget.reminderManager.getUserInfo(widget.userId) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void _sendReminder() {
    var remindDate = calculateRemindDate(dropdownvalue);
    final reminder = Reminder(serviceNameController.text, dueDate,
        double.parse(amountController.text), remindDate, dropdownvalue);
    //Save the Reminder
    widget.reminderManager
        .saveReminder(reminder, LocalUser(uid: widget.userId));
    // update the amount in Firebase
    widget.reminderManager.updateAmount(
        widget.userId, totalAmount + double.parse(amountController.text));
    // Schedule the Notification
    if (dropdownvalue != '')
      widget.notificationService.scheduleNotifications(reminder);
    // Clear and GO back
    serviceNameController.clear();
    dueDate = DateTime.now();
    amountController.clear();
    dropdownvalue = '';
    setState(() {});
    createSnackBar('Item Added Successfully', context);
    Navigator.pop(context);
  }

  DateTime calculateRemindDate(String value) {
    DateTime tempDate = DateTime.now();
    switch (value) {
      case ('1 Day Before'):
        tempDate = dueDate.subtract(const Duration(days: 1));
        break;
      case ('2 Day Before'):
        tempDate = dueDate.subtract(const Duration(days: 2));
        break;
      case ('3 Day Before'):
        tempDate = dueDate.subtract(const Duration(days: 3));
        break;
      case ('4 Day Before'):
        tempDate = dueDate.subtract(const Duration(days: 4));
        break;
      case ('5 Day Before'):
        tempDate = dueDate.subtract(const Duration(days: 5));
        break;
      case ('6 Day Before'):
        tempDate = dueDate.subtract(const Duration(days: 6));
        break;
      case ('1 Week Before'):
        tempDate = dueDate.subtract(const Duration(days: 7));
        break;
      default:
        break;
    }
    return tempDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text("Add Subscription",
            style: TextStyle(
              color: Colors.black,
            ),),
          backgroundColor: Color(0xFF8DD1EF),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: formGlobalKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 50),
                TextFormField(
                  controller: serviceNameController,
                  decoration: InputDecoration(labelText: "Service Name"),
                  validator: (Name) {
                    if (Name == null) return ("Enter a Valid Service Name");
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: "Amount"),
                  validator: (Amount) {
                    if (Amount == null) return ("Enter the amount");
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Select Due Date',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DateTimeField(
                      format: format,
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                            context: context,
                            helpText: 'Select Due Date',
                            fieldHintText: 'Select Due Date',
                            fieldLabelText: 'Due Date',
                            firstDate: DateTime.now(),
                            currentDate: dueDate,
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                      onSaved: (data) => setState(() {
                        dueDate = data!;
                      }),
                      onChanged: (data) {
                        if (data != null)
                          setState(() {
                            dueDate = data;
                          });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Select Notification Date',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.black45, width: 1)),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    isDense: true,
                    value: dropdownvalue,
                    hint: Container(
                        height: 150,
                        child: Text(
                          "Select Notification Date",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        )),
                    icon: Icon(Icons.keyboard_arrow_down),
                    onChanged: (String? newValue) {
                      // check for valid Reminder Time
                      if (newValue!.isNotEmpty) {
                        if (calculateRemindDate(newValue)
                                .compareTo(DateTime.now()) >=
                            0) {
                          setState(() {
                            dropdownvalue = newValue;
                          });
                        } else {
                          createSnackBar(
                              'Cannot set reminder before today', context);
                        }
                      }
                    },
                    items: reminderOption.map((String items) {
                      return DropdownMenuItem(value: items, child: Text(items));
                    }).toList(),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                new Row(
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          serviceNameController.clear();
                          dueDate = DateTime.now();
                          amountController.clear();
                          setState(() {});
                        },
                        child: Text(
                          "Clear",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(width: 1.0, color: Colors.red),
                          primary: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        )),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                        onPressed: _sendReminder,
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.green.shade400,
                            fontSize: 18,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          side: BorderSide(
                            width: 1.0,
                            color: Colors.green.shade400,
                          ),
                          primary: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                        )),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  void createSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$message')));
  }
}
