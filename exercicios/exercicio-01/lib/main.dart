import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Modelo de Item
class Item {
  final String nome;
  final double valor;

  Item({required this.nome, required this.valor});
}

// Modelo do Carrinho com Provider
class Carrinho with ChangeNotifier {
  final List<Item> _itens = [];

  List<Item> get itens => _itens;

  double get total => _itens.fold(0, (sum, item) => sum + item.valor);

  void adicionar(Item item) {
    _itens.add(item);
    notifyListeners();
  }

  void remover(Item item) {
    _itens.remove(item);
    notifyListeners();
  }
}

// Função principal
void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => Carrinho(), child: MyApp()),
  );
}

// App Principal
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrinho de Compras',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TelaPrincipal(),
    );
  }
}

// Tela Principal
class TelaPrincipal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final total = context.watch<Carrinho>().total;

    return Scaffold(
      appBar: AppBar(title: Text('Carrinho')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total: R\$ ${total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaItens()),
                );
              },
              child: Text('Adicionar Itens'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela de Lista de Itens
class ListaItens extends StatelessWidget {
  final List<Item> itensDisponiveis = [
    Item(nome: 'Item 1', valor: 10.0),
    Item(nome: 'Item 2', valor: 20.0),
    Item(nome: 'Item 3', valor: 30.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Itens')),
      body: ListView.builder(
        itemCount: itensDisponiveis.length,
        itemBuilder: (context, index) {
          final item = itensDisponiveis[index];
          return ListTile(
            title: Text(item.nome),
            subtitle: Text('R\$ ${item.valor.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(Icons.add_shopping_cart),
              onPressed: () {
                context.read<Carrinho>().adicionar(item);
              },
            ),
          );
        },
      ),
    );
  }
}