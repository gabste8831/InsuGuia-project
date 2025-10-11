import 'package:flutter/material.dart';
import 'package:insuguia_mobile/views/patient_form_screen.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // barra no topo
      appBar: AppBar(
        title: const Text('InsuGuia Mobile'),
        backgroundColor: Colors.blue[800],
      ),

      // corpo da tela
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: const [
          // widget pronto para itens de lista.
          // dados de exemplo por enquanto, antes de vinculo ao banco
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('João da Silva'),
            subtitle: Text('Leito 201, Enfermaria A'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Maria Oliveira'),
            subtitle: Text('Leito 305, Bloco Cirúrgico'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Pedro Martins'),
            subtitle: Text('Leito 112, Cardiologia'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),

      // botão flutuante no canto inferior direito
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
