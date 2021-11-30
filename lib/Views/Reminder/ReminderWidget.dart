import 'package:flutter/material.dart';
import 'package:analog/Views/Reminder/EditService.dart';
import 'package:intl/intl.dart';

class ReminderWidget extends StatelessWidget {
  const ReminderWidget({Key? key, required this.userId, required this.dbKey, required this.serviceName, required this.dueDate, required this.amount, required this.remindDate}) : super(key: key);
  final String serviceName;
  final DateTime dueDate;
  final String amount;
  final String remindDate;
  final String dbKey;
  final String userId;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: InkWell(
          onTap: () { _openEditPage(context); },
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 6,
            shadowColor: Colors.black54,
            child: Padding (
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: ListTile(
                leading:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Color(0xFF8DD1EF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(serviceName[0].toLowerCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.deepPurple),),
                      ),
                    ),
                  ],
                ),
                trailing:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('\$$amount', style: TextStyle(color: Colors.redAccent, fontSize: 22),),
                  ],
                ),
                title: Text(serviceName, style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text('Notify $remindDate ${DateFormat('MMM dd, yyyy').format(dueDate)}', style: TextStyle(color: Colors.black54, fontSize: 14),)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openEditPage(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => EditService(
      dbKey: dbKey,
      serviceName: serviceName,
      dueDate: dueDate,
      amount: amount,
      remindDate: remindDate,
      userId: userId,
    )));
  }
}
