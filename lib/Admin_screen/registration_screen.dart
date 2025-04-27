import 'package:flutter/material.dart';
import '../screens/db_helper.dart'; // Make sure this path is correct
import '../screens/login_screen.dart';

class AdminRegisterScreen extends StatefulWidget {
  @override
  _AdminRegisterScreenState createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminKeyController = TextEditingController();

  final String secretAdminKey = 'ADMIN123'; // Secret key to register as admin

  // Register the admin
  void _registerAdmin() async {
    if (_formKey.currentState!.validate()) {
      if (_adminKeyController.text == secretAdminKey) {
        try {
          // Use the insertAdmin method and save the role as "admin"
          await DBHelper.insertAdmin(
            username: _usernameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            admin: 'admin', // Save the role as 'admin'
          );

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Admin registered successfully!"),
            backgroundColor: Colors.green,
          ));

          // Navigate to a login screen or dashboard if needed
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid Admin Key"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF1F4), // Soft pinkish background
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('Admin Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) => value!.isEmpty ? 'Enter a username' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Min 6 characters' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _adminKeyController,
                decoration: InputDecoration(labelText: 'Admin Key'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Enter Admin Key' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _registerAdmin,
                child: Text(
                  'Register Admin',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
