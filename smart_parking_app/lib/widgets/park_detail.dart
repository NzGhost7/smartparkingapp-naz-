//show the detail about the parking
//can be use by all_park and searchPark
import 'package:flutter/material.dart';

class ParkDetail extends StatelessWidget {
  //const ParkDetail({super.key});
  final String id;
  final String name;
  final String address;
  final String desc;
  final int noOfPark;
  final int parkUse;

  ParkDetail(
      {required this.id,
      required this.name,
      required this.address,
      required this.desc,
      required this.noOfPark,
      required this.parkUse});

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
        title: Text('Parking Detail'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
              Text(
                'Parking Name: ',
                textAlign: TextAlign.left,
              ),
              ListTile(
                title: Text(name),
              ),
              SizedBox(height: 10,),
              Text('Location/Address: '),
              ListTile(
                title: Text(address),
              ),
              SizedBox(height: 10,),
              Text('Description: '),
              ListTile(
                title: Text(desc),
              ),
              SizedBox(height: 10,),
              Text('Total Parking: '),
              ListTile(
                title: Text(noOfPark.toString()),
              ),
              SizedBox(height: 10,),
              Text('Parking Used: '),
              ListTile(
                title: Text(parkUse.toString()),
              ),
              SizedBox(height: 10,),
              Text('Parking Available: '),
              ListTile(
                title:
                    Text(_calculateParkingAvailable(noOfPark, parkUse)),
              )
            ],
                ),
                ),
            )
          ],
        )
      ),
    );
  }
}

// Text(name),
//               SizedBox(height: 10,),
//               Text(address),
//               SizedBox(height: 10,),
//               Text(desc),
//               SizedBox(height: 10,),
//               Text(noOfPark.toString()),
//               SizedBox(height: 10,),
//               Text(parkUse.toString()),
