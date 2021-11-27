import 'package:analog/Model/LocalUser.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Model/Reminder.dart';

class DatabaseManager {

  final String remChild = 'REMINDERS';
  final String totalAmountChild = 'TOTAL_AMOUNT';
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference();

  // Save the Reminder in the Firebase
  void saveReminder(Reminder rem, LocalUser user) {
    _databaseReference.child(user.uid).child(remChild).push().set(rem.toJson());
  }

  // Updates the reminder with new Value
  void updateReminder(Reminder newRem, LocalUser user, String key) {
    _databaseReference.child(user.uid).child(remChild).child(key).set(newRem.toJson());
  }

  // Deletes the Reminder
  void deleteReminder(String reminderKey, LocalUser user) {
    _databaseReference.child(user.uid).child(remChild).child(reminderKey).remove();
  }

  // Get the reminder from the Firebase
  Query getMessageQuery(String uid) {
    return _databaseReference.child(uid).child(remChild);
  }

  // Returns the DB Reference to Firebase
  getDatabaseRef() {
    return _databaseReference;
  }

  // Gets all the Reminders from the FireBase
  Future<List<Reminder>> getAllReminders(LocalUser user) async {
    print("Called Get All Reminders");
    List<Reminder> allRem = [];
    _databaseReference.child(user.uid).child(remChild).once().then((DataSnapshot snapshot) {
      var data = snapshot.value;
      data.forEach((key, value) {
        final reminderValue = Reminder.fromJson(value);
          allRem.add(reminderValue);
      });
    });
    print(allRem);
    return allRem;
  }
  // Get the User Information: Total Amount
  getUserInfo(String uid) async {
    var jsonOutput;
    await _databaseReference.child(uid).child(totalAmountChild).once().then((value) =>
    jsonOutput = value.value);
    print('Total from DB: $jsonOutput');
    if (jsonOutput != null)
      return double.parse(jsonOutput['total_amount'].toString());
    return 0.0;
  }

  // Updates the Total Amount in Firebase DB
  void updateAmount(String userId, double totalAmount) {
    _databaseReference.child(userId).child(totalAmountChild).update({'total_amount': totalAmount});
  }
}
