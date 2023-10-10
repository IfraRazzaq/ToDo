import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String id;
  final String email;

  MyUser({
    required this.id,
    required this.email,
  });

  factory MyUser.fromDocument(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return MyUser(
      id: doc.id,
      email: data['email'] ?? '',
    );
  }
}

class Friends extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<Friends> {
  final TextEditingController _searchController = TextEditingController();
  List<MyUser> _users = [];
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  void _searchUsers(String query) {
    FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: query)
        .get()
        .then((querySnapshot) {
      setState(() {
        _users =
            querySnapshot.docs.map((doc) => MyUser.fromDocument(doc)).toList();
      });
    });
  }

  void _sendFriendRequest(MyUser user) {
    FirebaseFirestore.instance.collection('friendRequests').add({
      'from': _currentUserId,
      'to': user.id,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              decoration: InputDecoration(
                labelText: 'Search Friends by Email',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                var user = _users[index];
                return ListTile(
                  title: Text(user.email),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _sendFriendRequest(user);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Friend request sent to ${user.email}.'),
                        ),
                      );
                    },
                    child: Text('Send Request'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
