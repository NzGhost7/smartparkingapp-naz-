//All comment show here
import 'package:flutter/material.dart';
import 'package:smart_parking_app/models/complain.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommentPage extends StatefulWidget {
  const CommentPage({super.key});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  String? _error;
  var _isLoading = true;
  late List<String> _parkName = [];
  late List<Complain> _allComplain = [];

  void initState() {
    super.initState();
    _loadPark();
    _loadComplain();
  }

  //for the dropdown button to display all parking for the comment
  Future<void> _loadPark() async {
    final url = Uri.https(
      'smart-parking-app-6f2db-default-rtdb.asia-southeast1.firebasedatabase.app',
      'parks.json',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later';
        });
        return;
      }

      final Map<String, dynamic> parkData = json.decode(response.body);
      print('Debug2');
      print(parkData);

      // Check if there are no records in Firebase
      if (parkData == null || parkData.isEmpty) {
        // Disable loading
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List<String> _parkNames = [];

      // Extract names from each park and add to the _parkNames array
      parkData.values.forEach((value) {
        _parkNames.add(value['name']);
      });

      setState(() {
        _parkName = _parkNames;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Error occurred! Please try again later';
      });
    }
  }

  void _addComment(BuildContext context) {
    String selectedPark =
        _parkName.isNotEmpty ? _parkName[0] : ''; 
        final TextEditingController _complain = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Complain'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedPark,
                    items: _parkName.map((String park) {
                      return DropdownMenuItem<String>(
                        value: park,
                        child: Text(park),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPark = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _complain,
                    decoration:
                        InputDecoration(labelText: 'Enter your Complain'),
                    // Add controller or onChanged to handle user input
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveComplain(selectedPark,_complain.text);
                    _refresh();
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveComplain(String parkName, String complain) async {
  final url = Uri.https(
    'smart-parking-app-6f2db-default-rtdb.asia-southeast1.firebasedatabase.app', 
    'complain.json',
  );

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': DateTime.now().toString(),
        'parkName': parkName,
        'complain': complain,
      }),
    );

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      print('Complaint saved successfully!');
    } else {
      print('Failed to save complaint. Please try again.');
    }
  } catch (error) {
    print('Error occurred: $error');
  }
}

Future<void> _loadComplain() async {
  final url = Uri.https(
    'smart-parking-app-6f2db-default-rtdb.asia-southeast1.firebasedatabase.app',
    'complain.json',
  );

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> complainData = json.decode(response.body);

      final List<Complain> _loadedComplaints = complainData.entries.map((entry) {
        var key = entry.key;
        var value = entry.value;

        return Complain(
          id: key,
          parkName: value['parkName'],
          comment: value['complain'],
        );
      }).toList();

      setState(() {
        _allComplain = _loadedComplaints;
      });

      print('Complaints loaded successfully!');
    } else {
      print('Failed to load complaints. Please try again.');
    }
  } catch (error) {
    print('Error occurred: $error');
  }
}


  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    await _loadPark();
    _loadComplain();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complaint Section"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: _allComplain.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(_allComplain[index].parkName),
                  subtitle: Text(_allComplain[index].comment),
                ),
              );
            },
          )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           _addComment(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
