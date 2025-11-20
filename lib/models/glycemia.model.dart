class Glycemia {
  final int? id;
  final int patientId;
  final int value; // Valor em mg/dL (ex: 98, 120, 200)
  final DateTime date;

  Glycemia({
    this.id,
    required this.patientId,
    required this.value,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'value': value,
      'date': date.toIso8601String(),
    };
  }

  factory Glycemia.fromMap(Map<String, dynamic> map) {
    return Glycemia(
      id: map['id'],
      patientId: map['patientId'],
      value: map['value'],
      date: DateTime.parse(map['date']),
    );
  }
}
