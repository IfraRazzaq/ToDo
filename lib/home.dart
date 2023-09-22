import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task1/profile.dart';

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 30, 92, 143),
        hintColor: Color.fromARGB(255, 30, 92, 143),
      ),
      home: TodoList(),
    );
  }
}

class TodoItem {
  String title;
  String description;
  final String imageUrl;
  String id;

  TodoItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.id,
  });
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  User? _user;
  List<TodoItem> todos = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    List<TodoItem> todoList = [];

    try {
      if (_user != null) {
        final QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('todos')
            .where('uid', isEqualTo: _user!.uid)
            .get();

        todoList = snapshot.docs.map((DocumentSnapshot document) {
          final Map<String, dynamic>? data =
              document.data() as Map<String, dynamic>?;

          if (data != null &&
              data.containsKey('title') &&
              data.containsKey('description')) {
            return TodoItem(
              title: data['title'],
              description: data['description'],
              imageUrl: data['imageUrl'] ?? '',
              id: document.id,
            );
          } else {
            return TodoItem(
                title: 'Title Missing',
                description: 'Description Missing',
                imageUrl: '',
                id: document.id);
          }
        }).toList();
      }
    } catch (e) {
      print('Error fetching to-do items: $e');
    }
    setState(() {
      todos = todoList;
    });
  }

  void _addTodo() async {
    File? _imageFile;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add what To-Do'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  } else {
                    // Handle the case where the user canceled image selection
                  }
                },
                child: Text('Select Image'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                String title = _titleController.text.trim();
                String description = _descriptionController.text.trim();

                if (title.isNotEmpty && _user != null) {
                  final newTodoRef =
                      await FirebaseFirestore.instance.collection('todos').add({
                    'uid': _user!.uid,
                    'title': title,
                    'description': description,
                    'imageUrl': '',
                  });

                  await _uploadImageToFirestore(newTodoRef.id, _imageFile!);
                  _fetchTodos();
                }

                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                _titleController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTodo(TodoItem todo) async {
    TodoItem todoToDelete = TodoItem(
      title: todo.title,
      description: todo.description,
      imageUrl: todo.imageUrl,
      id: todo.id,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this to-do?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                debugPrint(todoToDelete.title);
                await FirebaseFirestore.instance
                    .collection('todos')
                    .doc(todoToDelete.id)
                    .delete();

                _fetchTodos();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editTodo(int index, TodoItem todo) {
    TodoItem todoToEdit = TodoItem(
      title: todo.title,
      description: todo.description,
      imageUrl: todo.imageUrl,
      id: todo.id,
    );

    TextEditingController titleController =
        TextEditingController(text: todo.title);
    TextEditingController descriptionController =
        TextEditingController(text: todo.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit To-Do'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                String updatedTitle = titleController.text.trim();
                String updatedDescription = descriptionController.text.trim();
                todoToEdit.title = updatedTitle;
                todoToEdit.description = updatedDescription;

                if (updatedTitle.isNotEmpty && _user != null) {
                  await FirebaseFirestore.instance
                      .collection('todos')
                      .doc(todoToEdit.id)
                      .update({
                    'title': todoToEdit.title,
                    'description': todoToEdit.description,
                  });
                  _fetchTodos();
                }

                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadImageToFirestore(String todoId, File imageFile) async {
    if (imageFile != null) {
      try {
        final fileName = 'todo_images/todoId.png';
        final storageRef = FirebaseStorage.instance.ref().child(fileName);
        final uploadTask = storageRef.putFile(imageFile);

        await uploadTask.whenComplete(() async {
          final imageUrl = await storageRef.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('todos')
              .doc(todoId)
              .update({
            'imageUrl': imageUrl,
          });

          _fetchTodos();
        });
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _currentIndex == 0
          ? ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];

                return ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editTodo(index, todo);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteTodo(todo);
                        },
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Text('Friends Screen Content'),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _addTodo,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
