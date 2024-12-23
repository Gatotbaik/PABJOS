import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref('messages');
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  // Fetch messages from Firebase Realtime Database
  void fetchMessages() {
    _messagesRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        final loadedMessages = data.entries.map((entry) {
          final value = entry.value as Map;
          return {
            "text": value["text"] ?? "",
            "isSentByMe": value["sender"] == "user",
            "time": value["time"] ?? "",
          };
        }).toList();
        setState(() {
          messages = loadedMessages;
        });
        // Scroll to the bottom when messages are updated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        print("Unexpected data format: $data");
      }
    });
  }

  // Send a message to Firebase Realtime Database
  void sendMessage(String text) async {
    if (text.isNotEmpty) {
      final newMessageRef = _messagesRef.push();
      await newMessageRef.set({
        "text": text,
        "sender": "user",
        "time": DateTime.now().toIso8601String(),
      });
      _controller.clear();

      // Scroll to the bottom after sending a message
      Future.delayed(Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController, // Attach the scroll controller
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ChatBubble(
                text: message["text"],
                isSentByMe: message["isSentByMe"],
                time: message["time"],
              );
            },
          ),
        ),
        ChatInput(
          controller: _controller,
          onSend: sendMessage,
        ),
      ],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSentByMe;
  final String time;

  const ChatBubble({
    required this.text,
    required this.isSentByMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            time,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Row(
          mainAxisAlignment:
              isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isSentByMe)
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150', // Ganti dengan URL avatar
                ),
              ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: EdgeInsets.symmetric(vertical: 4),
              constraints: BoxConstraints(maxWidth: 250),
              decoration: BoxDecoration(
                color: isSentByMe ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isSentByMe ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const ChatInput({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image, color: Colors.grey),
            onPressed: () {
              // Aksi untuk memilih gambar
            },
          ),
          IconButton(
            icon: Icon(Icons.emoji_emotions, color: Colors.grey),
            onPressed: () {
              // Aksi untuk emoji
            },
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Message...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () => onSend(controller.text),
          ),
        ],
      ),
    );
  }
}
