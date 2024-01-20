//Your Parking Page
import 'package:flutter/material.dart';
import 'package:smart_parking_app/models/park.dart';
import 'package:smart_parking_app/widgets/add_park.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:smart_parking_app/widgets/park_detail.dart';

class ParkList extends StatefulWidget {
  final String uid;
  ParkList({required this.uid});

  @override
  State<ParkList> createState() => _ParkListState();
}

class _ParkListState extends State<ParkList> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String uid;
  late List<Park> _park = [];
  var _isLoading = true;
  String? _error;

  void initState() {
    super.initState();
    uid = widget.uid;
    _loadPark();
  }

  void _loadPark() async {
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

      final List<Park> _loadedParks = [];

      // Filter parks based on uid
      parkData.forEach((key, value) {
        if (value['uid'] == widget.uid) {
          _loadedParks.add(Park(
            uid: widget.uid,
            id: key,
            name: value['name'],
            address: value['address'],
            desc: value['description'],
            noOfPark: value['noOfPark'],
            parkUse: value['parkUse'],
          ));
        }
      });

      setState(() {
        _park = _loadedParks;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Error occurred! Please try again later';
      });
    }
  }

  //add parking data (dummy data)
  void _addData() async {
    final data = await Navigator.of(context).push<Park>(MaterialPageRoute(
      builder: (context) => AddPark(
        uid: uid,
      ),
    ));

    if (data != null) {
      setState(() {
        _park.add(data);
      });
    }
  }

  //delete the parking data
  void _removePark(Park park) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${park.name}?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              await _deleteParkFromDatabase(park); // Call a separate function to delete from database
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}

Future<void> _deleteParkFromDatabase(Park park) async {
  final index = _park.indexOf(park);
  setState(() {
    _park.remove(park);
  });

  final url = Uri.https(
    'smart-parking-app-6f2db-default-rtdb.asia-southeast1.firebasedatabase.app',
    'parks/${park.id}.json',
  );

  final response = await http.delete(url);

  if (response.statusCode >= 400) {
    setState(() {
      _park.insert(index, park);
    });
  }
}


  void _updateParkUse(Park park) {
    int newParkUse = park.parkUse; // Initialize with the current parkUse value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          key: _formKey,
          title: Text('Number of Park Used'),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              // Validate that the input is a valid integer
              if (int.tryParse(value) != null) {
                newParkUse = int.parse(value);
              }
            },
            decoration: InputDecoration(labelText: 'Parking been Used'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Update the parkUse value in the database
                await _updateParkUseInDatabase(context, park, newParkUse);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateParkUseInDatabase(
      BuildContext context, Park park, int newParkUse) async {
    final url = Uri.https(
      'smart-parking-app-6f2db-default-rtdb.asia-southeast1.firebasedatabase.app',
      'parks/${park.id}.json',
    );

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'parkUse': newParkUse}),
    );

    if (response.statusCode >= 400) {
      // Handle error, maybe show a message to the user
    } else {
      // Update the local state with the new parkUse value
      setState(() {
        park.parkUse = newParkUse;
      });

      Navigator.of(_formKey.currentContext!).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            child: Image(
              image: AssetImage('images/data-not-found.png'),
              fit: BoxFit.cover,
              ),
          ),
          Text('No Parking'),
        ],
      ),
    );

    if (_isLoading) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text('error'),
      );
    }

    if (_park.isNotEmpty) {
      content = Padding(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: _park.length,
          itemBuilder: (context, index) {
            return Card(
              child: GestureDetector(
                child: ListTile(
                  title: Text(_park[index].name),
                  subtitle: Text(_park[index].address),
                  trailing: TextButton(
                      onPressed: () => _removePark(_park[index]),
                      child: Icon(Icons.delete)),
                ),
                onLongPress: () => _updateParkUse(_park[index]),
                onTap: () {
                   Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParkDetail(
                              id: _park[index].id,
                              name: _park[index].name,
                              address: _park[index].address,
                              desc: _park[index].desc,
                              noOfPark: _park[index].noOfPark,
                              parkUse: _park[index].parkUse,
                            ),
                          ));
                }
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Parking'),
          centerTitle: true,
        ),
        body: content,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addData(),
          child: Icon(Icons.add),
        ));
  }
}
