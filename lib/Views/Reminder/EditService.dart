import 'package:analog/Model/LocalUser.dart';
import 'package:analog/services/DatabaseManager.dart';
import 'package:analog/services/NotificationService.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:analog/Model/Reminder.dart';
import 'package:intl/intl.dart';

class EditService extends StatefulWidget {
  EditService({Key? key, required this.userId, required this.serviceName, required this.dueDate, required this.amount, required this.remindDate, required this.dbKey}) : super(key: key);
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

  @override
  void initState() {
    super.initState();
    dropdownvalue = widget.remindDate;
    serviceNameController.text = widget.serviceName;
    dueDate = widget.dueDate;
    amountController.text = widget.amount;
    setState(() {

    });
  }

  void _editReminder() {
    if (serviceNameController.text == widget.serviceName && widget.dueDate == dueDate ||
    amountController.text == widget.amount || widget.remindDate == dropdownvalue) {
      Navigator.pop(context);
    }
    else {
      final reminder = Reminder(
          serviceNameController.text,
          dueDate,
          double.parse(amountController.text),
          calculateRemindDate(),
          dropdownvalue);
      widget.reminderManager.updateReminder(
        reminder,
        LocalUser(uid: widget.userId),
        widget.dbKey,
      );
      // Cancel the old Notification and set a new one
      widget.notificationService.cancelNotificationWithID(widget.dueDate.millisecond);
      // Schedule the Notification
      if (dropdownvalue != '')
        widget.notificationService.scheduleNotifications(reminder);
      createSnackBar("Item Updated", context);
      Navigator.pop(context);
    }
  }

  DateTime calculateRemindDate() {
    DateTime tempDate = DateTime.now();
    switch (dropdownvalue) {
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
          title: Text('Edit',
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
                            firstDate: DateTime(2000),
                            currentDate: dueDate,
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                      onSaved: (data) => setState(() {
                        dueDate = data!;
                      }),
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
                    border: Border(bottom: BorderSide(color: Colors.black45, width: 1)),
                  ),
                  child: DropdownButton(
                    isExpanded: true,
                    isDense: true,
                    value: dropdownvalue,
                    icon: Icon(Icons.keyboard_arrow_down),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                      });
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
                          widget.reminderManager.deleteReminder(widget.dbKey, LocalUser(uid: widget.userId));
                          createSnackBar('Reminder Deleted', context);
                          Navigator.pop(context);
                        },
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
}
