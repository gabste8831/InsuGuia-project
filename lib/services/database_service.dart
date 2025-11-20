import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import '../models/patient.model.dart';
import '../models/note.model.dart';
import '../models/glycemia.model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'insuguia_FINAL_v8.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // tabela pacientes
    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sex TEXT NOT NULL,
        age INTEGER NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        creatinine REAL NOT NULL,
        location TEXT NOT NULL,
        doctorNotes TEXT,
        doctorName TEXT NOT NULL,
        nurseName TEXT NOT NULL,
        isCorticoid INTEGER NOT NULL,
        syringeScale INTEGER NOT NULL
      )
    ''');

    // tabela notas
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        recordedDoctorName TEXT,
        recordedNurseName TEXT,
        FOREIGN KEY(patientId) REFERENCES patients(id) ON DELETE CASCADE
      )
    ''');

    // tabela clicemias
    await db.execute('''
      CREATE TABLE glycemias(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        value INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY(patientId) REFERENCES patients(id) ON DELETE CASCADE
      )
    ''');
  }

  // CRUD paciente
  Future<int> insertPatient(Patient patient) async {
    Database db = await database;
    return await db.insert('patients', patient.toMap());
  }

  Future<List<Patient>> getPatients() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('patients');
    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  Future<int> updatePatient(Patient patient) async {
    Database db = await database;
    return await db.update('patients', patient.toMap(),
        where: 'id = ?', whereArgs: [patient.id]);
  }

  Future<void> deletePatient(int id) async {
    Database db = await database;
    await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD notas
  Future<int> insertNote(Note note) async {
    Database db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotesForPatient(int patientId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes',
        where: 'patientId = ?', whereArgs: [patientId], orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  // CRUD glicemias
  Future<int> insertGlycemia(Glycemia glycemia) async {
    Database db = await database;
    return await db.insert('glycemias', glycemia.toMap());
  }

  Future<List<Glycemia>> getGlycemiasForPatient(int patientId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('glycemias',
        where: 'patientId = ?', whereArgs: [patientId], orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Glycemia.fromMap(maps[i]));
  }
}
