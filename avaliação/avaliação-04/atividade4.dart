import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

Future<void> main() async {
  // Inicializa o FFI
  sqfliteFfiInit();

  // Abre o banco de dados
  var databaseFactory = databaseFactoryFfi;
  final db = await databaseFactory.openDatabase('alunos.db');

  // Cria a tabela se não existir
  await db.execute('''
  CREATE TABLE IF NOT EXISTS TB_ALUNO (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL CHECK(length(nome) <= 50)
  )
  ''');

  print('Banco de dados aberto e tabela TB_ALUNO criada (se não existia).');

  while (true) {
    print('\nEscolha uma opção:');
    print('1 - Inserir aluno');
    print('2 - Listar alunos');
    print('3 - Deletar aluno');
    print('0 - Sair');
    stdout.write('Opção: ');
    String? option = stdin.readLineSync();

    if (option == '1') {
      await inserirAluno(db);
    } else if (option == '2') {
      await listarAlunos(db);
    } else if (option == '3') {
      await deletarAluno(db);
    } else if (option == '0') {
      print('Encerrando...');
      await db.close();
      break;
    } else {
      print('Opção inválida. Tente novamente.');
    }
  }
}

Future<void> inserirAluno(Database db) async {
  stdout.write('Digite o nome do aluno (até 50 caracteres): ');
  String? nome = stdin.readLineSync();

  if (nome == null || nome.trim().isEmpty) {
    print('Nome inválido. Não pode ser vazio.');
    return;
  }
  if (nome.length > 50) {
    print('Nome muito longo. Máximo 50 caracteres.');
    return;
  }

  int id = await db.insert('TB_ALUNO', {'nome': nome.trim()});
  print('Aluno inserido com ID: $id');
}

Future<void> listarAlunos(Database db) async {
  List<Map<String, Object?>> alunos = await db.query('TB_ALUNO');

  if (alunos.isEmpty) {
    print('Nenhum aluno encontrado.');
    return;
  }

  print('\nLista de alunos:');
  for (var aluno in alunos) {
    print('ID: ${aluno['id']} - Nome: ${aluno['nome']}');
  }
}

Future<void> deletarAluno(Database db) async {
  stdout.write('Digite o ID do aluno que deseja deletar: ');
  String? input = stdin.readLineSync();

  if (input == null || input.trim().isEmpty) {
    print('ID inválido.');
    return;
  }

  int? id = int.tryParse(input);
  if (id == null) {
    print('ID inválido. Deve ser um número inteiro.');
    return;
  }

  int count = await db.delete('TB_ALUNO', where: 'id = ?', whereArgs: [id]);

  if (count > 0) {
    print('Aluno com ID $id deletado com sucesso.');
  } else {
    print('Nenhum aluno encontrado com o ID $id.');
  }
}

