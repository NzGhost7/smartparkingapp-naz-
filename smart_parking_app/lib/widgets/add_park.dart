//Add Parking Page
import 'package:flutter/material.dart';
import 'package:smart_parking_app/models/park.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPark extends StatefulWidget {
  //const AddPark({Key? key}) : super(key: key);
  final String uid;
  AddPark({required this.uid});

  @override
  State<AddPark> createState() => _AddParkState();
}

class _AddParkState extends State<AddPark> {
  String uid = '';
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredAddress = '';
  var _enteredDesc = '';
  var _enteredNoPark = 1;
  var _enteredParkUse = 0;
  var _isSending = false;

  void initState() {
    super.initState();
    uid = widget.uid;
  }

  void _savePark() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isSending = true;
    });

    _formKey.currentState!.save();

    final url = Uri.https(
      'smart-parking-app-6f2db-default-rtdb.asia-southeast1.firebasedatabase.app', // Replace with your Firebase project ID
      'parks.json',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'uid': widget.uid, // Assuming you have access to the user's ID
        'name': _enteredName,
        'address': _enteredAddress,
        'description': _enteredDesc,
        'noOfPark': _enteredNoPark,
        'parkUse': _enteredParkUse
      }),
    );

    print(response.body);
    print(response.statusCode);

    final Map<String, dynamic> resData = json.decode(response.body);

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop(
      Park(
        uid: widget.uid, // Assuming you have access to the user's ID
        id: resData['name'],
        name: _enteredName,
        address: _enteredAddress,
        desc: _enteredDesc,
        noOfPark: _enteredNoPark,
        parkUse: _enteredParkUse,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Parking'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
                key: _formKey,
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Parking Name',
                          hintText: 'Enter Parking Name',
                          border: OutlineInputBorder(borderSide: BorderSide())),
                      onChanged: (value) {
                        setState(() {
                          _enteredName = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'Enter Location',
                          border: OutlineInputBorder(borderSide: BorderSide())),
                      onChanged: (value) {
                        setState(() {
                          _enteredAddress = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter Description',
                          border: OutlineInputBorder(borderSide: BorderSide())),
                      onChanged: (value) {
                        setState(() {
                          _enteredDesc = value;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Total number of Parking',
                        hintText: 'Enter No. of Parks',
                        border: OutlineInputBorder(borderSide: BorderSide()),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _enteredNoPark = int.parse(value);
                        });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              _formKey.currentState!.reset();
                            },
                            child: const Text('Reset')),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _savePark,
                          child: const Text('Submit'),
                        ),
                      ],
                    )
                  ],
                ))),
      ),
    );
  }
}
