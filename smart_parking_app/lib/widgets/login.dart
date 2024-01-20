import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_parking_app/widgets/all_park.dart';
import 'package:smart_parking_app/widgets/register.dart';
import 'package:smart_parking_app/widgets/searchPark.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _pwd = TextEditingController();
  bool _obscureText = true;

  //find the username and password

  void _login(String username, String password) async {
    try {
      print('Your username $username and password $password');
      final url = Uri.https(
        'smart-parking-app-6f2db-default-rtdb.asia-southeast1.firebasedatabase.app',
        'users.json',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> usersData = json.decode(response.body);

        // Iterate over entries to find the user with the matching username
        var foundUser = usersData.entries.firstWhere(
          (entry) => entry.value['username'] == username,
          orElse: null,
        );

        if (foundUser != null && foundUser.value['password'] == password) {
          print('Login successful');
          // Handle successful login, e.g., navigate to the home screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllParkList(
                uid: username,
              ),
            ),
          );
        } else {
          print('Invalid username or password');
        }
      } else {
        print('Error fetching user data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during login: $error');
      // Handle error
      showError(context);
    }
  }

  void skip() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SearchPark()));
  }

  void showError(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Please enter your username and password correctly'),
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
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4), BlendMode.dstATop))),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Welcome to Smart Parking App',
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Monsterrat'),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'Login',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic, fontSize: 20),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                                controller: _username,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'Enter your username',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(17))),
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
                                  border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(17))),
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
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _username.text.isEmpty && _pwd.text.isEmpty
                                        ? showError(context)
                                        : _login(_username.text, _pwd.text);
                                  });
                                },
                                child: const Text('Login')),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Register()));
                                },
                                child: const Text(
                                  'Register if you new here',
                                  style: TextStyle(color: Colors.blue),
                                ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: skip,
          tooltip: 'Skip',
          child: const Icon(
            Icons.skip_next,
          ),
        ));
  }
}
