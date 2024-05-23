import 'package:flutter/material.dart';

class ChatPrivScreen extends StatelessWidget {
  final String username;
  const ChatPrivScreen({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final String user = username;

    return Scaffold(
        appBar: AppBar(
          title: Text('Chat con $user'),
        ),
        body: _ChatPrivView(user: user));
  }
}

class _ChatPrivView extends StatefulWidget {
  final String user;

  const _ChatPrivView({
    required this.user,
  });

  @override
  State<_ChatPrivView> createState() => _ChatPrivViewState();
}

class _ChatPrivViewState extends State<_ChatPrivView> {
  final List<Map<String, String>> _messages = [];
  final String currentUser = 'Valentino';
  final TextEditingController _controller = TextEditingController();
  
  void _handleSubmitted(String text) {
    _controller.clear();
    setState(() {
      _messages.add({'sender': currentUser, 'text': text});
    });
    if (text.toLowerCase() == 'hola') {
      // Respuesta automática del usuario
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({'sender': 'Usuario', 'text': 'Hola'});
        });
      });
    }
    if (text.endsWith('?')) {
      // Respuesta automática del usuario
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({'sender': 'Usuario', 'text': 'Si'});
        });
      });
    }
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: const IconThemeData(color: Colors.cyan),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _controller,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Enviar un mensaje',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              final isCurrentUser = message['sender'] == currentUser;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: isCurrentUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: <Widget>[
                    if (!isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: CircleAvatar(
                          child: Text(widget.user[0]),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        message['text']!,
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    if (isCurrentUser)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CircleAvatar(
                          child: Text(currentUser[0]),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(height: 1.0),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _buildTextComposer(),
        ),
      ],
    );
  }
}
