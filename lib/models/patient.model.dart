class Patient {
  final int? id;
  final String name;
  final String sex;
  final int age;
  final double weight;
  final double height;
  final double creatinine;
  final String location;
  final String? doctorNotes;
  final String doctorName;
  final String nurseName;

  // --- NOVOS CAMPOS V8 ---
  final bool isCorticoid;
  final int syringeScale;

  Patient({
    this.id,
    required this.name,
    required this.sex,
    required this.age,
    required this.weight,
    required this.height,
    required this.creatinine,
    required this.location,
    this.doctorNotes,
    required this.doctorName,
    required this.nurseName,
    required this.isCorticoid,
    required this.syringeScale,
  });

  double get bmi {
    double heightInMeters = height / 100.0;
    return weight / (heightInMeters * heightInMeters);
  }

  // Lógica de Cálculo de Dose Segura
  double get calculationFactor {
    // 1. Se usa corticoide (Resistência), ignora redução de segurança.
    if (isCorticoid) {
      return 0.5;
    }
    // 2. Se tem problema renal ou é idoso, reduz dose.
    if (creatinine > 1.3 || age > 70) {
      return 0.3;
    }
    // 3. Padrão
    return 0.5;
  }

  double get _totalDailyDose => weight * calculationFactor;

  // Lógica de Arredondamento para Seringa
  int _roundToSyringeScale(double value) {
    if (syringeScale == 2) {
      // Arredonda para o número PAR mais próximo
      return (value / 2).round() * 2;
    }
    // Arredonda normal
    return value.round();
  }

  int get basalDose {
    double rawDose = _totalDailyDose * 0.5;
    return _roundToSyringeScale(rawDose);
  }

  int get bolusDosePerMeal {
    double rawDose = (_totalDailyDose * 0.5) / 3;
    return _roundToSyringeScale(rawDose);
  }

  // Converte para salvar no Banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sex': sex,
      'age': age,
      'weight': weight,
      'height': height,
      'creatinine': creatinine,
      'location': location,
      'doctorNotes': doctorNotes ?? '',
      'doctorName': doctorName,
      'nurseName': nurseName,
      'isCorticoid': isCorticoid ? 1 : 0, // SQLite usa 1/0 para bool
      'syringeScale': syringeScale,
    };
  }

  // Converte do Banco para o App
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      sex: map['sex'],
      age: map['age'],
      weight: map['weight'],
      height: map['height'],
      creatinine: map['creatinine'],
      location: map['location'],
      doctorNotes: map['doctorNotes'],
      doctorName: map['doctorName'] ?? '',
      nurseName: map['nurseName'] ?? '',
      isCorticoid: (map['isCorticoid'] ?? 0) == 1,
      syringeScale: map['syringeScale'] ?? 1,
    );
  }

  // Cria uma cópia (útil para editar apenas um campo)
  Patient copyWith({String? doctorNotes}) {
    return Patient(
      id: id,
      name: name,
      sex: sex,
      age: age,
      weight: weight,
      height: height,
      creatinine: creatinine,
      location: location,
      doctorNotes: doctorNotes ?? this.doctorNotes,
      doctorName: doctorName,
      nurseName: nurseName,
      isCorticoid: isCorticoid,
      syringeScale: syringeScale,
    );
  }
}
