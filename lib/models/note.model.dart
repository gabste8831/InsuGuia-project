class Note {
  final int? id;
  final int patientId;
  final String content;
  final DateTime date;
  // campos de auditoria
  final String recordedDoctorName;
  final String recordedNurseName;

  Note({
    this.id,
    required this.patientId,
    required this.content,
    required this.date,
    required this.recordedDoctorName,
    required this.recordedNurseName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'content': content,
      'date': date.toIso8601String(),
      'recordedDoctorName': recordedDoctorName,
      'recordedNurseName': recordedNurseName,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      patientId: map['patientId'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      // fallback para evitar erro se o campo vier nulo de um banco antigo
      recordedDoctorName: map['recordedDoctorName'] ?? 'Não registrado',
      recordedNurseName: map['recordedNurseName'] ?? 'Não registrado',
    );
  }
}
