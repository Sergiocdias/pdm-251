import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Modelo de Usuario
class Usuario {
  final int id;
  final String nome;
  final String email;
  final String telefone;
  final String website;
  final String empresa;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.website,
    required this.empresa,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['name'],
      email: json['email'],
      telefone: json['phone'],
      website: json['website'],
      empresa: json['company']['name'],
    );
  }
}

void main() {
  runApp(ApiListViewApp());
}

class ApiListViewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API ListView Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UsuariosPage(),
    );
  }
}

class UsuariosPage extends StatefulWidget {
  @override
  _UsuariosPageState createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  late Future<List<Usuario>> futureUsuarios;
  List<Usuario> _usuarios = [];
  List<Usuario> _usuariosFiltrados = [];
  TextEditingController _controllerPesquisa = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarUsuarios();
  }

  Future<void> carregarUsuarios() async {
    futureUsuarios = fetchUsuarios();
    futureUsuarios.then((value) {
      setState(() {
        _usuarios = value;
        _usuariosFiltrados = value;
      });
    });
  }

  Future<List<Usuario>> fetchUsuarios() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/users'))
        .timeout(Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar usuários');
    }
  }

  void _pesquisarUsuario(String query) {
    final resultados = _usuarios.where((user) {
      final nomeLower = user.nome.toLowerCase();
      final emailLower = user.email.toLowerCase();
      final buscaLower = query.toLowerCase();

      return nomeLower.contains(buscaLower) || emailLower.contains(buscaLower);
    }).toList();

    setState(() {
      _usuariosFiltrados = resultados;
    });
  }

  @override
  void dispose() {
    _controllerPesquisa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('Lista de Usuários'),
  actions: [
    SizedBox(width: 12), // espaçamento à esquerda do botão
    IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () {
        carregarUsuarios();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lista recarregada')),
        );
      },
      tooltip: 'Recarregar lista',
    ),
    SizedBox(width: 16), // espaçamento à direita do botão
  ],
),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controllerPesquisa,
              decoration: InputDecoration(
                labelText: 'Pesquisar usuário',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _pesquisarUsuario,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Usuario>>(
              future: futureUsuarios,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Indicador de progresso enquanto carrega
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Mensagem de erro amigável
                  return Center(
                    child: Text(
                      'Erro ao carregar usuários.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  // Lista carregada com sucesso
                  return RefreshIndicator(
                    onRefresh: carregarUsuarios,
                    child: ListView.builder(
                      itemCount: _usuariosFiltrados.length,
                      itemBuilder: (context, index) {
                        Usuario user = _usuariosFiltrados[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(user.id.toString()),
                            ),
                            title: Text(user.nome),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.email),
                                Text('📞 ${user.telefone}'),
                                Text('🌐 ${user.website}'),
                                Text('🏢 ${user.empresa}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}