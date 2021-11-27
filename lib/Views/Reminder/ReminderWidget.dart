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
    final formattedDueDate = DateFormat('MMM dd, yyyy').format(dueDate);

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 8,
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
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black45, size: 24),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit Item Click')));
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => EditService(
                          dbKey: dbKey,
                          serviceName: serviceName,
                          dueDate: dueDate,
                          amount: amount,
                          remindDate: remindDate,
                          userId: userId,
                      )));
                    },
                  ),
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
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('\$$amount', style: TextStyle(color: Colors.redAccent, fontSize: 19),)
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text('Notify $remindDate ${DateFormat('MMM dd, yyyy').format(dueDate)}', style: TextStyle(color: Colors.black54, fontSize: 14),)
                  ),
                ],
              ),
            ),
          ),
         /*  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              ListTile(
                title: Text(serviceName),
                subtitle: Text(
                  dueDate,
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  '\$ $amount',
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  'Remind Set to $remindDate',
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(primary: Colors.greenAccent),
                    onPressed: () {
                      // Perform some action
                    },
                    child: const Text('EDIT'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(primary: Colors.redAccent),
                    onPressed: () {
                      // Perform some action
                    },
                    child: const Text('DELETE'),
                  ),
                ],
              )
            ],
          ),*/
        ),
      ),
    );
  }
}
