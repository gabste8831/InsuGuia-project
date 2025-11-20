import 'package:flutter/material.dart';
import 'package:insuguia_mobile/models/patient.model.dart';
import 'package:insuguia_mobile/providers/patient_provider.dart';
import 'package:provider/provider.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? patientToEdit;

  const PatientFormScreen({super.key, this.patientToEdit});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _creatinineController;
  late TextEditingController _locationController;
  late TextEditingController _doctorNameController;
  late TextEditingController _nurseNameController;

  String _selectedSex = 'Masculino';
  bool _isCorticoid = false;
  int _syringeScale = 1;

  @override
  void initState() {
    super.initState();
    final p = widget.patientToEdit;

    _nameController = TextEditingController(text: p?.name ?? '');
    _ageController = TextEditingController(text: p?.age.toString() ?? '');
    _weightController = TextEditingController(text: p?.weight.toString() ?? '');
    _heightController = TextEditingController(text: p?.height.toString() ?? '');
    _creatinineController =
        TextEditingController(text: p?.creatinine.toString() ?? '');
    _locationController = TextEditingController(text: p?.location ?? '');
    _doctorNameController = TextEditingController(text: p?.doctorName ?? '');
    _nurseNameController = TextEditingController(text: p?.nurseName ?? '');

    if (p != null) {
      _selectedSex = p.sex;
      _isCorticoid = p.isCorticoid;
      _syringeScale = p.syringeScale;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _creatinineController.dispose();
    _locationController.dispose();
    _doctorNameController.dispose();
    _nurseNameController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final provider = Provider.of<PatientProvider>(context, listen: false);

    final patientData = Patient(
      id: widget.patientToEdit?.id,
      name: _nameController.text,
      sex: _selectedSex,
      age: int.parse(_ageController.text),
      weight: double.parse(_weightController.text.replaceAll(',', '.')),
      height: double.parse(_heightController.text.replaceAll(',', '.')),
      creatinine: double.parse(_creatinineController.text.replaceAll(',', '.')),
      location: _locationController.text,
      doctorName: _doctorNameController.text,
      nurseName: _nurseNameController.text,
      doctorNotes: widget.patientToEdit?.doctorNotes ?? '',
      isCorticoid: _isCorticoid,
      syringeScale: _syringeScale,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (widget.patientToEdit != null) {
        await provider.updatePatient(patientData);
      } else {
        await provider.addPatient(patientData);
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao salvar!'), backgroundColor: Colors.red));
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.patientToEdit != null
            ? 'Dados atualizados!'
            : 'Paciente cadastrado!')));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patientToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Dados' : 'Novo Paciente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Identificação',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor)),
                const SizedBox(height: 8),
                TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        prefixIcon: Icon(Icons.person)),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obrigatório' : null),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: DropdownButtonFormField<String>(
                          value: _selectedSex,
                          decoration: const InputDecoration(labelText: 'Sexo'),
                          items: ['Masculino', 'Feminino']
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedSex = v!))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                              labelText: 'Idade', suffixText: 'anos'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || int.tryParse(v) == null
                              ? 'Inválido'
                              : null))
                ]),
                const SizedBox(height: 24),
                Text('Dados Antropométricos',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                              labelText: 'Peso', suffixText: 'kg'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) => v == null ||
                                  double.tryParse(v.replaceAll(',', '.')) ==
                                      null
                              ? 'Inválido'
                              : null)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextFormField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                              labelText: 'Altura', suffixText: 'cm'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) => v == null ||
                                  double.tryParse(v.replaceAll(',', '.')) ==
                                      null
                              ? 'Inválido'
                              : null))
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                          controller: _creatinineController,
                          decoration: const InputDecoration(
                              labelText: 'Creatinina', suffixText: 'mg/dL'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) => v == null ||
                                  double.tryParse(v.replaceAll(',', '.')) ==
                                      null
                              ? 'Inválido'
                              : null)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                              labelText: 'Leito/Local',
                              prefixIcon: Icon(Icons.bed)),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Obrigatório' : null))
                ]),
                const SizedBox(height: 24),
                Text('Protocolo e Equipamento',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor)),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Uso de Corticoides?'),
                  subtitle: const Text('Define resistência à insulina.'),
                  secondary: Icon(Icons.medication,
                      color: _isCorticoid ? Colors.orange : Colors.grey),
                  value: _isCorticoid,
                  activeColor: Colors.orange,
                  onChanged: (bool value) {
                    setState(() {
                      _isCorticoid = value;
                    });
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('Escala da Seringa/Caneta Disponível:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                ),
                Row(
                  children: [
                    Expanded(
                        child: RadioListTile<int>(
                            title: const Text('1 em 1 UI'),
                            value: 1,
                            groupValue: _syringeScale,
                            onChanged: (v) =>
                                setState(() => _syringeScale = v!))),
                    Expanded(
                        child: RadioListTile<int>(
                            title: const Text('2 em 2 UI'),
                            value: 2,
                            groupValue: _syringeScale,
                            onChanged: (v) =>
                                setState(() => _syringeScale = v!))),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Responsabilidade Técnica',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor)),
                const SizedBox(height: 8),
                TextFormField(
                    controller: _doctorNameController,
                    decoration: const InputDecoration(
                        labelText: 'Médico(a) Responsável',
                        prefixIcon: Icon(Icons.medical_services_outlined)),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obrigatório' : null),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _nurseNameController,
                    decoration: const InputDecoration(
                        labelText: 'Enfermeiro(a) Responsável',
                        prefixIcon: Icon(Icons.health_and_safety_outlined)),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Obrigatório' : null),
                const SizedBox(height: 32),
                ElevatedButton(
                    onPressed: _saveForm,
                    child: Text(isEditing
                        ? 'Salvar Alterações'
                        : 'Cadastrar Paciente')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
