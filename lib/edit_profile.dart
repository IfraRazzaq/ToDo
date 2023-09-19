import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _emailController = TextEditingController();
  String title = 'Edit Profile!';
  String description = 'Edit your profile here.';

  @override
  void initState() {
    super.initState();
    _emailController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 30, 92, 143),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _saveProfileChanges();
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 30, 92, 143),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfileChanges() {
    String newEmail = _emailController.text.trim();
    // Update the title and description here with the new values.
    setState(() {
      title = 'New Title';
      description = 'New Description';
    });

    final snackBar = SnackBar(
      content: Text('Profile changes saved!'),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
