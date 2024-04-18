class HealthCheck {
  final int? id;
  final int userId;
  final String healthStatus;
  final String checkUpDate;

  HealthCheck({
    this.id,
    required this.userId,
    required this.healthStatus,
    required this.checkUpDate,
  });

  factory HealthCheck.fromMap(Map<String, dynamic> map) {
    return HealthCheck(
      id: map['id'],
      userId: map['userId'],
      healthStatus: map['healthStatus'],
      checkUpDate: map['checkUpDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'healthStatus': healthStatus,
      'checkUpDate': DateTime.now().toIso8601String(), // Automatically get the current date
    };
  }
}
