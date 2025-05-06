import 'dart:convert';

class Dependente {
  late String _nome;

  Dependente(String nome) {
    this._nome = nome;
  }

  Map<String, dynamic> toJson() {
    return {'nome': _nome};
  }
}

class Funcionario {
  late String _nome;
  late List<Dependente> _dependentes;

  Funcionario(String nome, List<Dependente> dependentes) {
    this._nome = nome;
    this._dependentes = dependentes;
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': _nome,
      'dependentes': _dependentes.map((d) => d.toJson()).toList()
    };
  }
}

class EquipeProjeto {
  late String _nomeProjeto;
  late List<Funcionario> _funcionarios;

  EquipeProjeto(String nomeprojeto, List<Funcionario> funcionarios) {
    _nomeProjeto = nomeprojeto;
    _funcionarios = funcionarios;
  }

  Map<String, dynamic> toJson() {
    return {
      'nomeProjeto': _nomeProjeto,
      'funcionarios': _funcionarios.map((f) => f.toJson()).toList()
    };
  }
}

void main() {
  var dep1 = Dependente("Igor");
  var dep2 = Dependente("Tiago");
  var dep3 = Dependente("Rafael");

  var func1 = Funcionario("Amanda", [dep1]);
  var func2 = Funcionario("Bruno", [dep2, dep3]);

  var funcionarios = [func1, func2];

  var equipe = EquipeProjeto("Projeto Novatech", funcionarios);

  print(jsonEncode(equipe.toJson()));
}
