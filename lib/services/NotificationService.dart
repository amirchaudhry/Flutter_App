import 'package:analog/Model/Reminder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  static const channelId = 'AnalogApp';

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('polymer');

    final InitializationSettings _iniSettings = InitializationSettings(
        android: initializationSettingsAndroid);
    tz.initializeTimeZones();
    await _flutterLocalNotificationsPlugin.initialize(_iniSettings);
  }

  Future<void> scheduleNotifications(Reminder remObj) async {
    var timeDelayed = tz.TZDateTime.from(remObj.remindDate, tz.local);
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(channelId, 'Analog Reminder App',
        playSound: true,
        priority: Priority.high,
        importance: Importance.max,
        ticker: 'Analog');
    NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin.zonedSchedule(remObj.dueDate.millisecond, remObj.serviceName, '\$${remObj.amount.toString()} Due on ${DateFormat('MMM dd, yyyy').format(remObj.dueDate)}',
        timeDelayed, notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  Future<void> _cancelNotificationWithTag() async {
    await _flutterLocalNotificationsPlugin.cancel(0, tag: 'tag');
  }
}