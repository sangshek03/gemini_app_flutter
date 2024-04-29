import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class GeminiChat extends StatefulWidget {
  const GeminiChat({super.key});

  @override
  State<GeminiChat> createState() => GeminiChatState();
}

class GeminiChatState extends State<GeminiChat> {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> _messageList = [];

  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'Abhishek', lastName: 'Verma');

  final ChatUser _geminiUser =
      ChatUser(id: '2', firstName: 'Gemini', lastName: 'Google');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gemini App",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 110, 111, 110),
      ),
      body: DashChat(
          inputOptions: InputOptions(trailing: [
            IconButton(
                onPressed: _sendImageMessage, icon: const Icon(Icons.image))
          ]),
          messageOptions: const MessageOptions(
              currentUserContainerColor: Color.fromARGB(255, 68, 68, 68),
              currentUserTextColor: Color.fromARGB(255, 255, 255, 255)),
          currentUser: _currentUser,
          onSend: _sendMessage,
          messages: _messageList),
    );
  }

  void _sendMessage(ChatMessage m) {
    setState(() {
      _messageList.insert(0, m);
    });

    try {
      String question = m.text;
      List<Uint8List>? image;
      if (m.medias?.isNotEmpty ?? false) {
        image = [
          File(m.medias!.first.url).readAsBytesSync(),
        ];
      }
      // listner will be fired when ever event happenes on this stream
      gemini.streamGenerateContent(question).listen((event) {
        ChatMessage? lastMessage = _messageList.firstOrNull;
        if (lastMessage != null && lastMessage.user == _geminiUser) {
          lastMessage = _messageList.removeAt(0);
          String response = event.content?.parts?.fold(
                  "",
                  (previousValue, currentValue) =>
                      "$previousValue ${currentValue.text}") ??
              "";

          lastMessage.text += response;
          setState(() {
            _messageList = [lastMessage!, ..._messageList];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "",
                  (previousValue, currentValue) =>
                      "$previousValue ${currentValue.text}") ??
              "";

          ChatMessage message = ChatMessage(
              user: _geminiUser, createdAt: DateTime.now(), text: response);

          setState(() {
            _messageList = [message, ..._messageList];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendImageMessage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
          user: _currentUser,
          createdAt: DateTime.now(),
          text: "Who is is picture?",
          medias: [
            ChatMedia(
              url: file.path,
              fileName: "",
              type: MediaType.image,
            )
          ]);
      _sendMessage(chatMessage);
    }
  }
}
