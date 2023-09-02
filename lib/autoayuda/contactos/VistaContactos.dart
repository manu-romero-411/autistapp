import 'package:autistapp/inicio/ajustes.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class VistaContactos extends StatefulWidget {
  final Ajustes ajustes;
  const VistaContactos({Key? key, required this.ajustes}) : super(key: key);

  @override
  _VistaContactosState createState() => _VistaContactosState();
}

class _VistaContactosState extends State<VistaContactos> {
  Iterable<Contact> contacts = const Iterable.empty();
  @override
  void initState() {
    super.initState();
  }

  void showContacts() async {
    if (await Permission.contacts.request().isGranted) {
      contacts = await ContactsService.getContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title:
                Text("hola", style: TextStyle(color: widget.ajustes.fgColor))),
        body: SingleChildScrollView(
          child: Column(children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contacto = contacts.elementAt(index);
                return ListTile(
                  title: Text(contacto.displayName!),
                  onTap: () {
                    launchUrl(Uri.parse('tel:${contacto.phones!.first.value}'));
                  },
                );
              },
            ),
            FloatingActionButton(onPressed: () {
              setState(() {
                showContacts();
              });
              ();
            })
          ]),
        ));
  }
}

//                    launch('tel:${contact.phones!.first.value}');
