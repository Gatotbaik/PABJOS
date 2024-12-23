import 'package:flutter/material.dart';

void main() {
  runApp(ChatBox());
}

class ChatBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedIndex = 0; // Index item yang dipilih

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Mengubah index berdasarkan item yang dipilih
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        centerTitle: true, // Menjadikan teks di tengah
        title: Text(
          'Chat Box',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                ChatBubble(
                  text: "Apa yang bisa saya bantu?",
                  isSentByMe: false,
                ),
                ChatBubble(
                  text: "Yes! now i'm enjoying life more than ever.",
                  isSentByMe: true,
                ),
              ],
            ),
          ),
          ChatInput(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex, // Mengatur item yang aktif
        onTap: _onItemTapped, // Menangani perubahan item yang dipilih
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
            ),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.food_bank,
              color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
            ),
            label: 'Meal Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
              color: _selectedIndex == 2 ? Colors.blue : Colors.grey,
            ),
            label: 'Grocery List',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
              color: _selectedIndex == 3 ? Colors.blue : Colors.grey,
            ),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSentByMe;

  const ChatBubble({required this.text, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          gradient: isSentByMe
              ? LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent])
              : LinearGradient(colors: [Colors.grey[300]!, Colors.grey[100]!]),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
            bottomLeft: Radius.circular(isSentByMe ? 16.0 : 0),
            bottomRight: Radius.circular(isSentByMe ? 0 : 16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSentByMe ? Colors.white : Colors.black87,
            fontSize: 16.0,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class ChatInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Icon(
            Icons.add,
            color: Colors.grey,
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.0),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
