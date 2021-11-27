class Reminder {
  String serviceName;
  DateTime dueDate;
  double amount;
  DateTime remindDate;
  String setReminder;

  Reminder(this.serviceName, this.dueDate, this.amount, this.remindDate, this.setReminder);
  // Helps us convert the JSON to Object:
  // Map {key -> Value}
  // JSON: { a: “netl”, b: 34 };
  // Comes from Firebase -> JSON
  Reminder.fromJson(Map<dynamic, dynamic> json)
      : dueDate = DateTime.parse(json['DueDate'] as String),
        serviceName = json['ServiceName'] as String,
        amount = double.parse(json['Amount'].toString()),
        remindDate = DateTime.parse(json['RemindDate'] as String),
        setReminder = json['SetReminder'] as String;



// Converting the Object JSON:
// Reminder{name, date, amount} => {name: “sfdd”, date: ‘23/02/2021..}
// To send to the firebase
  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'DueDate': dueDate.toString(),
        'ServiceName': serviceName,
        'Amount': amount,
        'RemindDate': remindDate.toString(),
        'SetReminder': setReminder,
      };

  @override
  String toString() {
    return 'Reminder{serviceName: $serviceName, dueDate: $dueDate, amount: $amount, remindDate: $remindDate, setReminder: $setReminder}';
  }
}
