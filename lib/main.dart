import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:autistapp/inicio/ajustes.dart';
import 'package:autistapp/inicio/vista_bienvenida.dart';
import 'package:flutter/material.dart';
import 'package:autistapp/inicio/vista_inicio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';
import 'package:dynamic_color/dynamic_color.dart';

Workmanager workmanager = Workmanager();
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  inicializarNotificaciones();
  runApp(const AutistAppMain());
}

void inicializarNotificaciones() {
  _requestNotiPermissions();
  initializeDateFormatting('es_ES', null);
  if (Platform.isAndroid) {
    // WorkManager no funciona bien ni en iOS
    // ni en determinados sabores de Android (como MIUI).

    workmanager.initialize(workManagerCallbackDispatcher, isInDebugMode: false);
    workmanager.registerPeriodicTask(
      "1", "simpleTask",
      frequency: const Duration(hours: 1), // 1 hora.
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    //andNotifHorariasAlt();
  } else {
    if (Platform.isIOS) {
      iosNotifHorarias();
    }
  }
}

@pragma('vm:entry-point')
void workManagerCallbackDispatcher() {
  workmanager.executeTask((task, inputData) async {
    // Inicializa el plugin de notificaciones.
    andNotifHorarias();
    return Future.value(true);
  });
}

void andNotifHorarias() async {
  // Como los ajustes están guardados en un JSON, podemos generar un objeto
  // Ajustes temporal que contenga la información que necesitamos

  Ajustes ajTemp = Ajustes();
  ajTemp.cargarDatos();

  // Si en Ajustes tenemos una frecuencia de 2 ó 3 horas, habrá que restringir
  // según la hora actual.

  if (DateTime.now().hour % ajTemp.frecNotif == 0) {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Configura los detalles de la notificación.
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'autistapp_chan1', 'Avisos periódicos',
        importance: Importance.max, priority: Priority.high, showWhen: false);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Muestra la notificación.
    await flutterLocalNotificationsPlugin.show(0, '¿Tienes un momento?',
        'Entra en la app y revisa tus rutinas', platformChannelSpecifics);
  }
}

void andNotifHorariasAlt() async {
  // Inicializamos las notificaciones
  var andNotiSettings =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettings = InitializationSettings(android: andNotiSettings);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Configuramos los detalles de la notificación.
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'autistapp_chan1', 'Avisos periódicos',
      importance: Importance.max, priority: Priority.high, showWhen: false);
  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Mostramos la notificación.
  await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      '¿Tienes un momento?',
      'Entra en la app y revisa tus rutinas',
      RepeatInterval.hourly,
      platformChannelSpecifics);
}

void iosNotifHorarias() async {
  var iOSInitializationSettings = const DarwinInitializationSettings();
  var initializationSettings =
      InitializationSettings(iOS: iOSInitializationSettings);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Configura los detalles de la notificación.
  var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
  var platformChannelSpecifics =
      NotificationDetails(iOS: iOSPlatformChannelSpecifics);

  // Muestra la notificación.
  await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      '¿Tienes un momento?',
      'Entra en la app y revisa tus rutinas',
      RepeatInterval.hourly,
      platformChannelSpecifics);
}

Future<void> _requestNotiPermissions() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  if (Platform.isIOS || Platform.isMacOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  } else if (Platform.isAndroid) {
    // Solicitar permiso de notificaciones en Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestPermission();
  }
}

class AutistAppMain extends StatefulWidget {
  const AutistAppMain({super.key});
  @override
  AutistAppMainState createState() => AutistAppMainState();
}

class AutistAppMainState extends State<AutistAppMain> {
  Ajustes ajustes = Ajustes();
  bool isWelcome = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ajustes.cargarDatos();
    setState(() {
      _isLoading = false;
    });
  }

  get color => ajustes.color;

  ThemeData? getThemeData() {
    ajustes.cargarDatos();
    return ajustes.isDarkTheme
        ? ThemeData.dark()
        : !ajustes.isDarkTheme
            ? ThemeData.light()
            : null;
  }

  set theme(bool value) {
    setState(() {
      ajustes.setDarkTheme = value;
    });
  }

  set selectedColor(Color color) {
    setState(() {
      ajustes.color = color;
    });
  }

  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.blue);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.blue, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'AutistApp',
          theme: ThemeData(
            colorScheme: lightColorScheme ?? _defaultLightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          initialRoute: ajustes.welcome ? '/welcome' : "/home",
          routes: {
            '/welcome': (context) => PantallaBienvenida(
                  ajustes: ajustes,
                  onThemeChanged: (value) => theme = value,
                  onColorSelected: (colorSel) => selectedColor = colorSel,
                ),
            '/home': (context) => VistaInicio(
                  ajustes: ajustes,
                  onThemeChanged: (value) => theme = value,
                  onChangeColour: (colorSel) => selectedColor = colorSel,
                ),
          },
        );
      });
    }
  }
}
