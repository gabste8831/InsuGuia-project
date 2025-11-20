import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:insuguia_mobile/models/patient.model.dart';
import 'package:insuguia_mobile/providers/patient_provider.dart';
import 'package:insuguia_mobile/views/patient_form_screen.dart';
import 'package:provider/provider.dart';

class PatientDetailsScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final TextEditingController _newNoteController = TextEditingController();
  final TextEditingController _glycemiaController = TextEditingController();
  late TextEditingController _doctorNotesController;

  late Patient _displayPatient;

  @override
  void initState() {
    super.initState();
    _displayPatient = widget.patient;
    _doctorNotesController =
        TextEditingController(text: _displayPatient.doctorNotes);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_displayPatient.id != null) {
        final provider = Provider.of<PatientProvider>(context, listen: false);
        provider.loadNotes(_displayPatient.id!);
        provider.loadGlycemias(_displayPatient.id!);
      }
    });
  }

  @override
  void dispose() {
    _newNoteController.dispose();
    _glycemiaController.dispose();
    _doctorNotesController.dispose();
    super.dispose();
  }

  // --- AÇÕES ---

  void _saveDoctorNotes() {
    final updatedPatient =
        _displayPatient.copyWith(doctorNotes: _doctorNotesController.text);
    Provider.of<PatientProvider>(context, listen: false)
        .updatePatient(updatedPatient);
    setState(() {
      _displayPatient = updatedPatient;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Conduta salva!')));
    FocusScope.of(context).unfocus();
  }

  Future<void> _addNote() async {
    if (_newNoteController.text.trim().isEmpty) return;
    if (_displayPatient.id != null) {
      try {
        await Provider.of<PatientProvider>(context, listen: false).addNote(
            _displayPatient.id!,
            _newNoteController.text,
            _displayPatient.doctorName,
            _displayPatient.nurseName);
        _newNoteController.clear();
        FocusScope.of(context).unfocus();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _addGlycemia() {
    final String text = _glycemiaController.text;
    if (text.isEmpty) return;
    final int? value = int.tryParse(text);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Valor inválido!')));
      return;
    }
    if (_displayPatient.id != null) {
      Provider.of<PatientProvider>(context, listen: false)
          .addGlycemia(_displayPatient.id!, value);
      _glycemiaController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Medição registrada!')));
    }
  }

  // --- NAVEGAÇÃO ---

  void _editPatient() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PatientFormScreen(patientToEdit: _displayPatient)));
    if (!mounted) return;
    final provider = Provider.of<PatientProvider>(context, listen: false);
    try {
      final updatedPatient =
          provider.patients.firstWhere((p) => p.id == _displayPatient.id);
      setState(() {
        _displayPatient = updatedPatient;
        _doctorNotesController.text = updatedPatient.doctorNotes ?? '';
      });
    } catch (e) {}
  }

  void _confirmDelete() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Excluir Paciente?'),
                content: const Text(
                    'Tem certeza que deseja remover este paciente?\nIsso apagará permanentemente todo o histórico.\nEssa ação não pode ser desfeita.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white),
                      onPressed: () async {
                        if (_displayPatient.id != null) {
                          await Provider.of<PatientProvider>(context,
                                  listen: false)
                              .deletePatient(_displayPatient.id!);
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Paciente removido.')));
                          }
                        }
                      },
                      child: const Text('Excluir Definitivamente'))
                ]));
  }

  @override
  Widget build(BuildContext context) {
    final String bmiFormatted = _displayPatient.bmi.toStringAsFixed(1);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_displayPatient.name),
          actions: [
            PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _editPatient();
                  if (value == 'delete') _confirmDelete();
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Editar Dados')
                          ])),
                      const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete_forever, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir / Alta')
                          ]))
                    ]),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.description), text: 'Prescrição'),
              Tab(icon: Icon(Icons.timeline), text: 'Acompanhamento')
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPrescriptionTab(context, bmiFormatted),
            _buildMonitoringTab(context)
          ],
        ),
      ),
    );
  }

  // --- ABA 1: PRESCRIÇÃO (ATUALIZADA) ---

  Widget _buildPrescriptionTab(BuildContext context, String bmi) {
    final bool isReducedDose = !_displayPatient.isCorticoid &&
        (_displayPatient.creatinine > 1.3 || _displayPatient.age > 70);
    final bool isResistant = _displayPatient.isCorticoid;
    final bool isEvenRounding = _displayPatient.syringeScale == 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- CARD DE IDENTIFICAÇÃO E DADOS (ATUALIZADO) ---
          _buildInfoCard(
            context: context,
            title: 'Identificação e Dados Clínicos',
            icon: Icons.person, // Mudei o ícone para Pessoa
            children: [
              // Parte 1: Dados Pessoais
              _buildDetailItem('Nome Completo', _displayPatient.name),
              _buildDetailItem('Idade / Sexo',
                  '${_displayPatient.age} anos / ${_displayPatient.sex}'),

              const Divider(), // Divisor

              // Parte 2: Antropometria e Rim
              _buildDetailItem('Peso / Altura',
                  '${_displayPatient.weight} kg / ${_displayPatient.height} cm'),
              _buildDetailItem('IMC', '$bmi kg/m²'),
              _buildDetailItem(
                  'Creatinina', '${_displayPatient.creatinine} mg/dL'),

              // Parte 3: Fatores de Risco e Equipamento
              _buildDetailItem('Uso de Corticoide?',
                  isResistant ? 'SIM (Resistência)' : 'Não'),
              _buildDetailItem(
                  'Seringa/Escala', isEvenRounding ? '2 em 2 UI' : '1 em 1 UI'),

              const Divider(), // Divisor

              // Parte 4: Equipe
              _buildDetailItem('Médico(a) Resp.', _displayPatient.doctorName),
              _buildDetailItem('Enfermeiro(a)', _displayPatient.nurseName),
            ],
          ),
          const SizedBox(height: 16),

          // --- PROTOCOLO ---
          _buildInfoCard(
            context: context,
            title: 'Protocolo de Insulina',
            icon: Icons.medical_services,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isReducedDose
                      ? Colors.orange.shade50
                      : (isResistant
                          ? Colors.purple.shade50
                          : Colors.blue.shade50),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isReducedDose
                          ? Colors.orange.shade200
                          : (isResistant
                              ? Colors.purple.shade200
                              : Colors.blue.shade200)),
                ),
                child: Row(
                  children: [
                    Icon(
                        isReducedDose
                            ? Icons.warning_amber
                            : (isResistant
                                ? Icons.medication
                                : Icons.info_outline),
                        size: 16,
                        color: isReducedDose
                            ? Colors.orange[800]
                            : (isResistant
                                ? Colors.purple[800]
                                : Colors.blue[800])),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isReducedDose
                            ? 'Ajuste Renal/Idade: Dose reduzida para 0.3 U/kg.'
                            : (isResistant
                                ? 'Paciente em Corticoterapia: Manter 0.5 U/kg (Sem redução).'
                                : 'Protocolo Padrão: Dose calculada a 0.5 U/kg.'),
                        style: TextStyle(
                            fontSize: 12,
                            color: isReducedDose
                                ? Colors.orange[900]
                                : (isResistant
                                    ? Colors.purple[900]
                                    : Colors.blue[900]),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              if (isEvenRounding)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                      '⚠️ Doses arredondadas para número PAR (Seringa 2 em 2).',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic)),
                ),
              const SizedBox(height: 12),
              _buildDetailItem('Insulina Basal (NPH)',
                  '${_displayPatient.basalDose} Unidades - 1x ao dia (manhã)'),
              _buildDetailItem('Insulina Rápida (Regular)',
                  '${_displayPatient.bolusDosePerMeal} Unidades - Pré-refeições'),
              const Divider(),
              const Text('Esquema de Correção (Se Glicemia > 180):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              _buildSimpleRow('181 - 240 mg/dL', 'Aplicar + 2 UI'),
              _buildSimpleRow('241 - 300 mg/dL', 'Aplicar + 4 UI'),
              _buildSimpleRow('> 300 mg/dL', 'Aplicar + 6 UI e avisar médico'),
            ],
          ),
          const SizedBox(height: 16),

          _buildInfoCard(
            context: context,
            title: 'Diretrizes Oficiais (SBD)',
            icon: Icons.verified_user,
            children: [
              _MultiLineDetailItem('Alvo Glicêmico',
                  'Manter entre 140 e 180 mg/dL (Pacientes internados gerais).'),
              _MultiLineDetailItem('Hipoglicemia (<70)',
                  'Administrar 15g de carboidrato de absorção rápida e reavaliar em 15 min.'),
            ],
          ),
          const SizedBox(height: 16),

          _buildNotesSection(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- SEÇÃO DE EVOLUÇÃO ---

  Widget _buildNotesSection(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.history,
                      color: Theme.of(context).primaryColor, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                      child: Text('Evolução Clínica / Obs.',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)))
                ]),
                const Divider(height: 24),
                Consumer<PatientProvider>(
                  builder: (context, provider, child) {
                    final notes = provider.currentPatientNotes;
                    if (notes.isEmpty)
                      return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Nenhuma observação registrada.',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic)));
                    return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notes.length,
                        separatorBuilder: (ctx, i) => const Divider(),
                        itemBuilder: (ctx, i) {
                          final note = notes[i];
                          final dateStr =
                              DateFormat('dd/MM - HH:mm').format(note.date);
                          return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade50,
                                  radius: 14,
                                  child: Icon(Icons.circle,
                                      size: 8,
                                      color: Theme.of(context).primaryColor)),
                              title: Text(note.content,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                      '$dateStr \nResp: Dr(a). ${note.recordedDoctorName} | Enf. ${note.recordedNurseName}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600]))));
                        });
                  },
                ),
                const Divider(height: 24),
                Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _newNoteController,
                          decoration: InputDecoration(
                              hintText: 'Adicionar evolução...',
                              filled: true,
                              fillColor: Colors.blue.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none)))),
                  const SizedBox(width: 8),
                  IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
                      onPressed: _addNote)
                ])
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.edit_note,
                      color: Theme.of(context).primaryColor, size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                      child: Text('Anotações de Conduta',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)))
                ]),
                const Divider(height: 24),
                TextField(
                    controller: _doctorNotesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                        hintText: 'Digite ajustes fixos...',
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none))),
                const SizedBox(height: 16),
                Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                        onPressed: _saveDoctorNotes,
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text('Salvar Conduta'))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
            onPressed: () => _showHospitalDischargeDialog(context),
            child: const Text('Gerar Orientações de Alta')),
      ],
    );
  }

  // --- ABA 2: MONITORAMENTO ---

  Widget _buildMonitoringTab(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: _glycemiaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Nova Glicemia Capilar',
                          suffixText: 'mg/dL',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white))),
              const SizedBox(width: 16),
              FloatingActionButton.small(
                  onPressed: _addGlycemia, child: const Icon(Icons.add)),
            ],
          ),
        ),
        Expanded(
          child: Consumer<PatientProvider>(
            builder: (context, provider, child) {
              final glycemias = provider.currentPatientGlycemias;
              if (glycemias.isEmpty)
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.water_drop_outlined,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('Nenhuma medição registrada.',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 16))
                    ]));
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: glycemias.length,
                itemBuilder: (ctx, i) {
                  final item = glycemias[i];
                  final dateStr = DateFormat('dd/MM/yyyy').format(item.date);
                  final timeStr = DateFormat('HH:mm').format(item.date);
                  Color valueColor;
                  String status;
                  if (item.value < 70) {
                    valueColor = Colors.red;
                    status = 'Hipoglicemia';
                  } else if (item.value > 250) {
                    valueColor = Colors.red;
                    status = 'Hiper Severa';
                  } else if (item.value > 180) {
                    valueColor = Colors.orange;
                    status = 'Hiperglicemia (>180)';
                  } else if (item.value < 140 && item.value >= 70) {
                    valueColor = Colors.blue;
                    status = 'Atenção (<140)';
                  } else {
                    valueColor = Colors.green;
                    status = 'Alvo Terapêutico (140-180)';
                  }
                  return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor: valueColor.withOpacity(0.2),
                              child: Icon(Icons.water_drop, color: valueColor)),
                          title: Row(children: [
                            Text('${item.value}',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                            const Text(' mg/dL',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.grey))
                          ]),
                          subtitle: Text('$status • $dateStr às $timeStr')));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- ALTA E HELPERS ---

  String _generateDischargeText() {
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return '''
HOSPITAL UNIVERSITÁRIO - RESUMO DE ALTA
Data: $date

PACIENTE: ${_displayPatient.name}
IDADE: ${_displayPatient.age} anos
MÉDICO RESPONSÁVEL: ${_displayPatient.doctorName}

DIAGNÓSTICO:
Diabetes Mellitus - Paciente em terapia insulínica.

PRESCRIÇÃO PARA DOMICÍLIO:

1. INSULINA BASAL (NPH):
   - Aplicar ${_displayPatient.basalDose} Unidades, 1 vez ao dia (pela manhã).
   ${_displayPatient.syringeScale == 2 ? '(Atenção: Dose par para seringa graduada de 2 em 2).' : ''}

2. INSULINA RÁPIDA (REGULAR):
   - Aplicar ${_displayPatient.bolusDosePerMeal} Unidades antes das principais refeições.

3. MONITORAMENTO GLICÊMICO:
   - Realizar ponta de dedo (HGT) 4x ao dia.
   - Meta glicêmica: 100 a 180 mg/dL.

ORIENTAÇÕES DE SEGURANÇA (SBD):
- Hipoglicemia (<70): Ingerir 15g de carboidrato rápido.
- Hiperglicemia persistente (>300): Procurar atendimento.

Assinatura: _______________________________
             Dr(a). ${_displayPatient.doctorName}
''';
  }

  void _showHospitalDischargeDialog(BuildContext context) {
    final String dischargeText = _generateDischargeText();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Row(children: [
                  Icon(Icons.description_outlined,
                      color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text('Documento de Alta')
                ]),
                content: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                        child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2))
                                ]),
                            child: SelectableText(dischargeText,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.5))))),
                actions: [
                  TextButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar Texto'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Texto copiado!')));
                        Navigator.pop(ctx);
                      }),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Fechar'))
                ]));
  }

  Widget _buildInfoCard(
      {required BuildContext context,
      required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)))
              ]),
              const Divider(height: 24),
              ...children
            ])));
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$label:', style: TextStyle(color: Colors.grey[700])),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)))
        ]));
  }

  Widget _buildSimpleRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))
        ]));
  }

  Widget _MultiLineDetailItem(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$label:', style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))
        ]));
  }
}
