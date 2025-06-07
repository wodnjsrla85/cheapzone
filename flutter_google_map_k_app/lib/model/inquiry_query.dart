class InquiryQuery {
  final int? id; //id
  final String date; //작성일
  final int type; //문의 유형(오류제보, 고장 등)
  final String content; //문의 내용
  final String category; //문의 카테고리(주유소, 전기차충전소, 주차장)
  final int status; //처리 상태 (0 :진행중, 1 :답변완료 )
  final String userEmail; //이메일

  InquiryQuery({
    this.id,
    required this.date,
    required this.type,
    required this.content,
    required this.category,
    required this.status,
    required this.userEmail,
  });

  /// 객체를 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'category': category,
      'status': status,
      'userEmail': userEmail,
    };
  }

  // 서버에서 받은 데이터를 객체로 변환할 factory 생성자
  factory InquiryQuery.fromJson(List<dynamic> json) {
    return InquiryQuery(
      id: json[0],
      date: json[1],
      type: json[2],
      content: json[3],
      category: json[4],
      status: json[5],
      userEmail: json[6],
    );
  }
  // 기존 객체를 복사하여 일부 값만 변경된 새 객체를 만드는 메서드.
  // 객체의 불변성을 유지하면서 특정 속성만 업데이트할 때 유용
  InquiryQuery copyWith({
    int? id,
    String? date,
    int? type,
    String? content,
    String? category,
    int? status,
    String? userEmail,
  }) {
    return InquiryQuery(
      id: id ?? this.id, // 새로운 값이 없으면 기존 값을 사용
      date: date ?? this.date,
      type: type ?? this.type,
      content: content ?? this.content,
      category: category ?? this.category,
      status: status ?? this.status,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}
