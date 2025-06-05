class Bookmark {
  final String email;
  final String name;
  final int type;
  final String date;
  final String address;
  final bool status;

  Bookmark(
    {
      required this.email,
      required this.name,
      required this.type,
      required this.date,
      required this.address,
      required this.status
    }
  );
}