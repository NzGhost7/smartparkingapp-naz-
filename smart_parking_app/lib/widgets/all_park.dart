//home page for the user who login
import 'package:flutter/material.dart';
import 'package:smart_parking_app/models/park.dart';
import 'package:smart_parking_app/widgets/complain_page.dart';
import 'package:smart_parking_app/widgets/park_detail.dart';
import 'package:smart_parking_app/widgets/park_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AllParkList extends StatefulWidget {
  //const AllParkList({super.key});
  final String uid;
  AllParkList({required this.uid});

  @override
  State<AllParkList> createState() => _AllParkListState();
}

class _AllParkListState extends State<AllParkList> {
  final TextEditingController _searchLocation = TextEditingController();
  var _isLoading = true;
  String? _error;
  late List<Park> _allPark = [];
  late List<Park> _searchResults = [];
  late String uid;

  void initState() {
    super.initState();
    uid = widget.uid;
    _loadPark();
    search();
  }

  //load data from database and put into the _park array
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

      final List<Park> _loadedParks = parkData.entries.map((entry) {
        var key = entry.key;
        var value = entry.value;

        return Park(
          uid: value['uid'], // Assuming uid is needed, adjust as needed
          id: key,
          name: value['name'],
          address: value['address'],
          desc: value['description'],
          noOfPark: value['noOfPark'],
          parkUse: value['parkUse'],
        );
      }).toList();

      setState(() {
        _allPark = _loadedParks;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Error occurred! Please try again later';
      });
    }
  }

  void search() {
    String query = _searchLocation.text.toLowerCase();

    if (query.isEmpty) {
      // If the search query is empty, reset the search results
      setState(() {
        _searchResults = _allPark;
      });
    } else {
      // Filter parks based on the search query
      _searchResults = _allPark
          .where((park) =>
              park.name.toLowerCase().contains(query) ||
              park.address.toLowerCase().contains(query))
          .toList();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    await _loadPark();
    search();
    setState(() {
      _isLoading = false;
    });
  }

  String _calculateParkingAvailable(int num1, int num2) {
    int total = num1 - num2;
    if (total < 0) {
      total = 0;
    }
    return total.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('All Parking'),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(children: <Widget>[
            DrawerHeader(
              //padding: EdgeInsets.all(50),
              child: Center(
                child: Text(
                  'Hello, $uid!',
                  style: TextStyle(
                      fontFamily: 'Monsterrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                        'images/Flexible Self-Adhesive Paved Parking Lot -- 7-7_8 x 6-3_16_  20 x 16cm.jpg'),
                    fit: BoxFit.cover),
              ),
            ),
            ListTile(
                title: const Text('Your Parking'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ParkList(
                                uid: uid,
                              )));
                }),
            ListTile(
                title: const Text('Complain'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentPage(),
                      ));
                }),
            ListTile(
                title: const Text('Log Out'),
                onTap: () {
                  uid = '';
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login', // Use the route name for the login screen
                    (Route<dynamic> route) =>
                        false, // Remove all existing routes
                  );
                }),
          ]),
        ),
        body: RefreshIndicator(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: _searchLocation,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'Search Location',
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                        ),
                        onPressed: () {
                          setState(() {
                            _searchResults = _allPark
                                .where((park) =>
                                    park.name.toLowerCase().contains(
                                        _searchLocation.text.toLowerCase()) ||
                                    park.address.toLowerCase().contains(
                                        _searchLocation.text.toLowerCase()))
                                .toList();
                          });
                        },
                        child: Icon(
                          Icons.search,
                          size: 20, // Set the icon size
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                      child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(
                            _searchResults[index].name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(_searchResults[index].address),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Available'),
                              SizedBox(
                                height: 7,
                              ),
                              Text(
                                _calculateParkingAvailable(
                                    _searchResults[index].noOfPark,
                                    _searchResults[index].parkUse),
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ParkDetail(
                                    id: _searchResults[index].id,
                                    name: _searchResults[index].name,
                                    address: _searchResults[index].address,
                                    desc: _searchResults[index].desc,
                                    noOfPark: _searchResults[index].noOfPark,
                                    parkUse: _searchResults[index].parkUse,
                                  ),
                                ));
                          },
                        ),
                      );
                    },
                  )),
                ],
              ),
            ),
            onRefresh: _refresh));
  }
}

// 