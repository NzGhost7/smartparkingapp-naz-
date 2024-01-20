class Park {
  final String uid;
  final String id;
  final String name;
  final String address;
  final String desc;
  final int noOfPark;
  late final int parkUse;

  Park(
      {required this.uid,
      required this.id,
      required this.name,
      required this.address,
      required this.desc,
      required this.noOfPark,
      required this.parkUse});
}
