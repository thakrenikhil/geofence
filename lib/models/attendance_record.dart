class AttendanceRecord {
  AttendanceRecord({
    required this.userId,
    required this.checkInAt,
    this.checkOutAt,
    required this.officeId,
  });

  final String userId;
  final DateTime checkInAt;
  final DateTime? checkOutAt;
  final String officeId;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'checkInAt': checkInAt.toIso8601String(),
        'checkOutAt': checkOutAt?.toIso8601String(),
        'officeId': officeId,
      };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
        userId: json['userId'] as String,
        checkInAt: DateTime.parse(json['checkInAt'] as String),
        checkOutAt: json['checkOutAt'] != null ? DateTime.parse(json['checkOutAt'] as String) : null,
        officeId: json['officeId'] as String,
      );
}


