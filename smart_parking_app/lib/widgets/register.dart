import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_parking_app/widgets/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _username = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  bool _obscureText = true;

  void _register(String username, String password) async {
    try {
      final url = Uri.https(
        'smart-parking-app-6f2db-default-rtdb.asia-southeast1.firebasedatabase.app',
        'users.json',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          // Add other user-related data if needed
        }),
      );

      if (response.statusCode == 200) {
        print('User registration successful');
        print("Your username: $username , Pwd: $password");
        // Handle successful registration, e.g., navigate to the home screen
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Login(),
            ));
      } else {
        print('User registration failed. Status code: ${response.statusCode}');
        // Handle registration failure
      }
    } catch (error) {
      print('Error during registration: $error');
      // Handle error
    }
  }

   void showError(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Please enter your username and password'),
      duration: Duration(seconds: 5),
    );
    // Use the ScaffoldMessenger to show the SnackBar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/pexels-kelly-2655864.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.dstATop))
        ),
        child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child:  Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
            const Text(
              'Register',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
                controller: _username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(17))),
                )),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _pwd,
              obscureText: _obscureText,
              decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(17))),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(_obscureText
                          ? Icons.visibility
                          : Icons.visibility_off))),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    _username.text.isEmpty && _pwd.text.isEmpty ? showError(context) : _register(_username.text, _pwd.text);
                  });
                },
                child: const Text('Register')),
            //SizedBox(height: 15,),
          ]),
                ),
            )
          ],
        )
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Login(),));
        },
        child: Icon(Icons.undo),
      ),
    );
  }
}
