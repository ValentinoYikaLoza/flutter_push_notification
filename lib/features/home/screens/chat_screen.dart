import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Contactos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: 4, // Número de usuarios
            itemBuilder: (context, index) {
              String name = 'Usuario ${index + 1}';
              String abreviation =
                  name.substring(0, 1) + name.substring(name.length - 1);
              if (index == 0) {
                name = 'Miguel';
                abreviation = 'Mg';
              }
              if (index == 1) {
                name = 'José';
                abreviation = 'Js';
              }
              if (index == 2) {
                name = 'Diego';
                abreviation = 'Dg';
              }
              return ListTile(
                leading: CircleAvatar(
                  child: Text(abreviation),
                ),
                title: Text(name),
                onTap: () {
                  context.push('/chat-priv/$name');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
