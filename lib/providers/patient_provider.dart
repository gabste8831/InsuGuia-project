import 'package:flutter/material.dart';
import '../models/patient.model.dart';
import '../models/note.model.dart';
import '../models/glycemia.model.dart';
import '../services/database_service.dart';

class PatientProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Patient> _patients = [];
  List<Note> _currentPatientNotes = [];
  List<Glycemia> _currentPatientGlycemias = [];

  bool _isLoading = false;

  List<Patient> get patients => _patients;
  List<Note> get currentPatientNotes => _currentPatientNotes;
  List<Glycemia> get currentPatientGlycemias => _currentPatientGlycemias;
  bool get isLoading => _isLoading;

  PatientProvider() {
    loadPatients();
  }

  // FUNÇÕES DE PACIENTES

  Future<void> loadPatients() async {
    _setLoading(true);
    try {
      _patients = await _databaseService.getPatients();
    } catch (e) {
      print('Erro ao carregar pacientes: $e');
    }
    _setLoading(false);
  }

  Future<void> addPatient(Patient patient) async {
    await _databaseService.insertPatient(patient);
    await loadPatients();
  }

  Future<void> updatePatient(Patient patient) async {
    await _databaseService.updatePatient(patient);
    await loadPatients();
    notifyListeners();
  }

  Future<void> deletePatient(int id) async {
    try {
      await _databaseService.deletePatient(id);
      await loadPatients();
      notifyListeners();
    } catch (e) {
      print("Erro ao deletar paciente: $e");
      rethrow;
    }
  }

  // FUNÇÕES DE NOTAS (EVOLUÇÃO)

  Future<void> loadNotes(int patientId) async {
    try {
      _currentPatientNotes =
          await _databaseService.getNotesForPatient(patientId);
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar notas: $e");
    }
  }

  Future<void> addNote(
      int patientId, String content, String docName, String nurseName) async {
    try {
      final newNote = Note(
        patientId: patientId,
        content: content,
        date: DateTime.now(),
        recordedDoctorName: docName,
        recordedNurseName: nurseName,
      );

      await _databaseService.insertNote(newNote);
      await loadNotes(patientId);
    } catch (e) {
      print("ERRO CRÍTICO AO ADICIONAR NOTA: $e");
      rethrow;
    }
  }

  // FUNÇÕES DE GLICEMIA

  Future<void> loadGlycemias(int patientId) async {
    try {
      _currentPatientGlycemias =
          await _databaseService.getGlycemiasForPatient(patientId);
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar glicemias: $e");
    }
  }

  Future<void> addGlycemia(int patientId, int value) async {
    try {
      final newGlycemia =
          Glycemia(patientId: patientId, value: value, date: DateTime.now());
      await _databaseService.insertGlycemia(newGlycemia);
      await loadGlycemias(patientId);
    } catch (e) {
      print("Erro ao adicionar glicemia: $e");
    }
  }

  // HELPER DE CARREGAMENTO
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
