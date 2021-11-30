import 'package:analog/Model/LocalUser.dart';
import 'package:analog/services/DatabaseManager.dart';
import 'package:analog/services/NotificationService.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:analog/Model/Reminder.dart';
import 'package:intl/intl.dart';

class EditService extends StatefulWidget {
  EditService(
      {Key? key,
      required this.userId,
      required this.serviceName,
      required this.dueDate,
      required this.amount,
      required this.remindDate,
      required this.dbKey})
      : super(key: key);
  final reminderManager = DatabaseManager();
  final String serviceName;
  final DateTime dueDate;
  final String amount;
  final String remindDate;
  final String dbKey;
  final String userId;
  final notificationService = NotificationService();
  @override
  _EditServiceState createState() => _EditServiceState();
}

class _EditServiceState extends State<EditService> {
  final formGlobalKey = GlobalKey<FormState>();
  String dropDownValue = '';
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

  _getUserData() async {
    totalAmount =
        await widget.reminderManager.getUserInfo(widget.userId) ?? 0.0;
  }

  void _updateUserAmount(double editedAmt) {
    double orgAmt = double.parse(widget.amount);
    double result = orgAmt - editedAmt;
    if (result == 0.0) return;
    // Total in DB - 45: Org Amt - 15 -> Changed to - 10 =  Diff - 5
    // Subtract the difference in Firebase
    widget.reminderManager.updateAmount(widget.userId, totalAmount - result);
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
    dropDownValue = widget.remindDate;
    serviceNameController.text = widget.serviceName;
    dueDate = widget.dueDate;
    amountController.text = widget.amount;
    setState(() {});
  }

  void _editReminder() {
    // Do not Change Anything if nothing is edited
    if (serviceNameController.text == widget.serviceName &&
        widget.dueDate == dueDate &&
        amountController.text == widget.amount &&
        widget.remindDate == dropDownValue) {
      Navigator.pop(context);
    } else {
      var remindDate = calculateRemindDate(dropDownValue);
      final reminder = Reminder(serviceNameController.text, dueDate,
          double.parse(amountController.text), remindDate, dropDownValue);
      widget.reminderManager.updateReminder(
        reminder,
        LocalUser(uid: widget.userId),
        widget.dbKey,
      );
      // update the amount in Firebase
      _updateUserAmount(double.parse(amountController.text));
      // Cancel the old Notification and set a new one
      widget.notificationService
          .cancelNotificationWithID(widget.dueDate.millisecond);
      // Schedule the Notification
      if (dropDownValue != '')
        widget.notificationService.scheduleNotifications(reminder);
      createSnackBar("Item Updated", context);
      Navigator.pop(context);
    }
  }

  DateTime calculateRemindDate(String newValue) {
    DateTime tempDate = DateTime.now();
    switch (newValue) {
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
          title: Text(
            'Edit',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
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
                  validator: (val) {
                    if (val == null) return ("Enter a Valid Service Name");
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: "Amount"),
                  validator: (amount) {
                    if (amount == null) return ("Enter the amount");
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Select Due Date',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DateTimeField(
                      format: format,
                      initialValue: dueDate,
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            currentDate: dueDate,
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                      onSaved: (data) => setState(() {
                        dueDate = data!;
                        dropDownValue = '';
                      }),
                      onChanged: (data) {
                        if (data != null)
                          setState(() {
                            dueDate = data;
                            dropDownValue = '';
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
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
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
                    value: dropDownValue,
                    icon: Icon(Icons.keyboard_arrow_down),
                    onChanged: (String? newValue) {
                      // check for valid Reminder Time
                      if (newValue!.isEmpty) {
                        setState(() {
                          dropDownValue = newValue;
                        });
                      }
                      else {
                        if (calculateRemindDate(newValue)
                                .compareTo(DateTime.now()) >=
                            0) {
                          setState(() {
                            dropDownValue = newValue;
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
                        onPressed: _handleDeleteBtn,
                        child: Text("Delete"),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 13, vertical: 8),
                            textStyle: TextStyle(
                              fontSize: 18,
                            ))),
                    const SizedBox(
                      width: 130,
                    ),
                    ElevatedButton(
                        onPressed: _editReminder,
                        child: Text("Save Changes"),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.green.shade400,
                            padding: EdgeInsets.symmetric(
                                horizontal: 13, vertical: 8),
                            textStyle: TextStyle(
                              fontSize: 18,
                            ))),
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

  void _handleDeleteBtn() {
    // Delete the reminder
    widget.reminderManager
        .deleteReminder(widget.dbKey, LocalUser(uid: widget.userId));
    // update the amount in Firebase
    widget.reminderManager
        .updateAmount(widget.userId, totalAmount - double.parse(widget.amount));
    createSnackBar('Reminder Deleted', context);
    // Go back
    Navigator.pop(context);
  }
}
