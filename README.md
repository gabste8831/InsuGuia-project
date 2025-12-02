# 🩺 InsuGuia Mobile

> **Projeto de Extensão Acadêmico** | Desenvolvimento para Plataformas Móveis
> **Unidavi** - Centro Universitário para o Desenvolvimento do Alto Vale do Itajaí

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)

## Sobre o Projeto

O **InsuGuia Mobile** é um aplicativo desenvolvido como protótipo acadêmico de um Sistema de Suporte à Decisão Clínica (CDSS). O objetivo é auxiliar profissionais de saúde no manejo de pacientes internados não-críticos com diabetes, facilitando o cálculo de doses de insulina e o acompanhamento glicêmico.

O projeto foi desenvolvido com base em uma demanda real apresentada pelo **Dr. Itairan da Silva Terres** (Endocrinologista), seguindo diretrizes da Sociedade Brasileira de Diabetes (SBD).

## Funcionalidades Principais

### Inteligência Clínica (Cálculos & Segurança)
* **Cálculo Automático:** Define a Dose Total Diária (TDD), Basal (NPH) e Bolus (Rápida) com base no peso.
* **Segurança Renal e Geriátrica:** Detecta automaticamente riscos (Creatinina > 1.3 ou Idade > 70) e reduz o fator de dose (de 0.5 para 0.3 U/kg).
* **Ajuste para Corticoides:** Identifica resistência insulínica e impede a redução indevida de doses.
* **Arredondamento Inteligente:** Adapta a prescrição para seringas de escala 1:1 ou 2:2 unidades.

### Gestão e Monitoramento
* **Prontuário Eletrônico (Timeline):** Histórico de evoluções com data, hora e assinatura do responsável (Médico/Enfermeiro).
* **Monitoramento Glicêmico:** Registro de HGT com feedback visual (Semáforo: 🔴 Hipoglicemia/Hiper, 🟢 Alvo, 🟠 Alerta).
* **CRUD Completo:** Gestão de pacientes com persistência local.
* **Busca Avançada:** Filtragem por nome, leito ou equipe médica.
* **Geração de Alta:** Criação automática de texto padronizado para orientações de alta hospitalar.

## Screenshots

| Tela Inicial (Lista) | Cadastro/Edição | Prescrição & Cálculos | Evolução Clínica & Acompanhamento |
|:---:|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/30eae843-6325-4ab2-8f1b-c77530034f10" width="200" /> | <img src="https://github.com/user-attachments/assets/ec6cf427-87c7-41cb-a739-5a1a9f1d8cb9" width="200" /> | <img src="https://github.com/user-attachments/assets/9e3d5d46-6894-4a60-9f77-23e339e13dce" width="200" /><br><br><img src="https://github.com/user-attachments/assets/e445c513-64de-46c8-bd82-629005e9c179" width="200" /> | <img src="https://github.com/user-attachments/assets/5bf9dcdf-fe8f-45db-a160-0acf0714c532" width="200" /><br><br><img src="https://github.com/user-attachments/assets/4e903d4c-ebc0-4f27-8d53-b04273a7a9c7" width="200" /> |

## Tecnologias Utilizadas

* **Framework:** [Flutter](https://flutter.dev/) (SDK >=3.3.4)
* **Linguagem:** Dart
* **Gerenciamento de Estado:** `provider`
* **Banco de Dados Local:** `sqflite` (SQLite)
* **Tipografia:** `google_fonts` (Poppins)
* **Arquitetura:** MVVM (Model-View-ViewModel adaptado)

## Autores

| [<img src="https://github.com/gabste8831.png" width="75px;"/>](https://github.com/gabste8831) |
| :---: | 
| **Gabriel Steffens** | 
| [GitHub](https://github.com/gabste8831) | 

## Como Rodar o Projeto

Pré-requisitos: Ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.

1. **Clone o repositório:**
   ```bash
   git clone (https://github.com/gabste8831/InsuGuia-project.git)
   cd insuguia_mobile
   flutter pub get
   flutter run

 **Atenção**
Este aplicativo é um protótipo acadêmico desenvolvido para fins de avaliação na disciplina de Desenvolvimento para Plataformas Móveis. Embora utilize diretrizes médicas reais, NÃO deve ser utilizado como única fonte para tomada de decisão clínica em ambiente real sem a devida validação e certificação pelos órgãos competentes.
