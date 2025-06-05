class InquiryQuery {
  final int? id;
  final String date;
  final int type;
  final String content;
  final String category;
  final int status;
  final String userEmail;

  InquiryQuery(
    {
      this.id,
      required this.date,
      required this.type,
      required this.content,
      required this.category,
      required this.status,
      required this.userEmail
    }
  );
}