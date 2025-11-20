import 'package:flutter/material.dart';
import 'package:insuguia_mobile/providers/patient_provider.dart';
import 'package:insuguia_mobile/views/patient_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:insuguia_mobile/views/patient_details_screen.dart';
import 'package:insuguia_mobile/models/patient.model.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InsuGuia Mobile'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ÁREA DE BUSCA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Buscar nome, médico, leito...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon:
                    Icon(Icons.search, color: Theme.of(context).primaryColor),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),

          // LISTA PACIENTES
          Expanded(
            child: Consumer<PatientProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // lógica de filtro
                final allPatients = provider.patients;
                final filteredPatients = allPatients.where((patient) {
                  final term = _searchText;
                  // múltilos parâmetros de busca
                  return patient.name.toLowerCase().contains(term) ||
                      patient.location.toLowerCase().contains(term) ||
                      patient.doctorName.toLowerCase().contains(term) ||
                      patient.nurseName.toLowerCase().contains(term);
                }).toList();

                // Lista Vazia
                if (filteredPatients.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchText.isEmpty
                                ? Icons.person_add_alt_1
                                : Icons.search_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchText.isEmpty
                                ? 'Nenhum paciente cadastrado ainda.\nToque no botão + para iniciar.'
                                : 'Não encontramos resultados para\n"${_searchController.text}".\n\nTente buscar por nome, médico ou leito.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // exibição da Lista (cards)
                return ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: filteredPatients.length,
                  itemBuilder: (ctx, index) {
                    final patient = filteredPatients[index];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PatientDetailsScreen(patient: patient),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Avatar com Inicial
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.2),
                                child: Text(
                                  patient.name.isNotEmpty
                                      ? patient.name[0].toUpperCase()
                                      : 'P',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // infos principais
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      patient.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // leito
                                    Row(
                                      children: [
                                        Icon(Icons.bed,
                                            size: 14, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          patient.location,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                              fontSize: 13),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // responsável técnico
                                    Row(
                                      children: [
                                        Icon(Icons.medical_services,
                                            size: 12,
                                            color:
                                                Theme.of(context).primaryColor),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Dr(a). ${patient.doctorName}',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600]),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const Icon(Icons.chevron_right,
                                  color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // botão flutuante (adicionar)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PatientFormScreen()),
          );
        },
        tooltip: 'Adicionar Paciente',
        child: const Icon(Icons.add),
      ),
    );
  }
}
