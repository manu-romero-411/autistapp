import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class SendNot extends StatefulWidget {
  const SendNot({Key? key}) : super(key: key);

  @override
  State<SendNot> createState() => _SendNotState();
}

class _SendNotState extends State<SendNot> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _time = TextEditingController();

  DateTime dateTime = DateTime.now();
  tz.TZDateTime scheduledDate = tz.TZDateTime.from(DateTime.now(), tz.local);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("ic_launcher");

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
      macOS: null,
      linux: null,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails()
            .then((value) {
          // Aquí puedes manejar el evento de clic en la notificación
        });
      },
    );
  }

  tz.TZDateTime _convertTime(int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, now.hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  showNotification() {
    if (_title.text.isEmpty || _desc.text.isEmpty) {
      return;
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "ScheduleNotification001",
      "Notify Me",
      importance: Importance.high,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: null,
      linux: null,
    );

    // flutterLocalNotificationsPlugin.show(
    //     01, _title.text, _desc.text, notificationDetails);

    scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    try {
      flutterLocalNotificationsPlugin.zonedSchedule(
          01, _title.text, _desc.text, _convertTime(55), notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'Ths s the data');
    } catch (e) {
      print("Error at zonedScheduleNotification----------------------------$e");
      if (e ==
          "Invalid argument (scheduledDate): Must be a date in the future: Instance of 'TZDateTime'") {
        Fluttertoast.showToast(msg: "Select future date");
      }
    }
  }

  Future zonedScheduleNotification(String note, DateTime date, occ) async {
    // IMPORTANT!!
    //tz.initializeTimeZones(); --> call this before using tz.local (ideally put it in your init state)

    tz.initializeTimeZones();

    int id = Random().nextInt(10000);
    print(date.toString());
    print(tz.TZDateTime.parse(tz.local, date.toString()).toString());
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        occ,
        note,
        tz.TZDateTime.parse(tz.local, date.toString()),
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'your channel id', 'your channel name',
              channelDescription: 'your channel description',
              largeIcon: DrawableResourceAndroidBitmap("logo"),
              icon: "ic_launcher",
              playSound: true,
              sound: RawResourceAndroidNotificationSound('bell_sound')),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return id;
    } catch (e) {
      print("Error at zonedScheduleNotification----------------------------$e");
      if (e ==
          "Invalid argument (scheduledDate): Must be a date in the future: Instance of 'TZDateTime'") {
        Fluttertoast.showToast(msg: "Select future date");
      }
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  label: const Text("Notification Title"),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _desc,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  label: const Text("Notification Description"),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _date,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    suffixIcon: InkWell(
                      child: const Icon(Icons.date_range),
                      onTap: () async {
                        final DateTime? newlySelectedDate =
                            await showDatePicker(
                          context: context,
                          initialDate: dateTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2095),
                        );

                        if (newlySelectedDate == null) {
                          return;
                        }

                        setState(() {
                          dateTime = newlySelectedDate;
                          // _date.text =
                          //     "${dateTime.year}/${dateTime.month}/${dateTime.day}";
                        });
                      },
                    ),
                    label: const Text("Date")),
              ),
              const SizedBox(
                height: 16.0,
              ),
              TextField(
                controller: _time,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    suffixIcon: InkWell(
                      child: const Icon(
                        Icons.timer_outlined,
                      ),
                      onTap: () async {
                        final TimeOfDay? slectedTime = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());

                        if (slectedTime == null) {
                          return;
                        }

                        _time.text =
                            "${slectedTime.hour}:${slectedTime.minute}:${slectedTime.period.toString()}";

                        DateTime newDT = DateTime(
                          dateTime.year,
                          dateTime.month,
                          dateTime.day,
                          slectedTime.hour,
                          slectedTime.minute,
                        );
                        setState(() {
                          dateTime = newDT;
                        });
                      },
                    ),
                    label: const Text("Time")),
              ),
              const SizedBox(
                height: 24.0,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  onPressed: () async {
                    showNotification();
                  },
                  child: const Text("Show Notification")),
            ],
          ),
        ),
      ),
    );
  }
}
