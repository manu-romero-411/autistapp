/*import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarController _calendarController;
  Map<DateTime, List> _events; // Puedes usar esta estructura para almacenar los eventos/color de cada día

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _events = {}; // Inicializa tu mapa de eventos aquí
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario Mensual'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          TableCalendar(
            calendarController: _calendarController,
            events: _events,
            onDaySelected: (date, events) {
              // Navegar a otra vista aquí pasando el `date` seleccionado
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DayViewPage(selectedDate: date),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DayViewPage extends StatelessWidget {
  final DateTime selectedDate;

  DayViewPage({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    // Implementa la vista detallada del día aquí
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Día'),
      ),
      body: Center(
        child: Text('Vista para el día $selectedDate'),
      ),
    );
  }
}
*/