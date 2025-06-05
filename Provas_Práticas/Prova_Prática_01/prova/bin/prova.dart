import 'dart:convert';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:prova/prova_email.dart';

class Cliente {
  int codigo;
  String nome;
  int tipoCliente;

  Cliente({required this.codigo, required this.nome, required this.tipoCliente});

  Map<String, dynamic> toJson() => {
        'codigo': codigo,
        'nome': nome,
        'tipoCliente': tipoCliente,
      };
}

class Vendedor {
  int codigo;
  String nome;
  double comissao;

  Vendedor({required this.codigo, required this.nome, required this.comissao});

  Map<String, dynamic> toJson() => {
        'codigo': codigo,
        'nome': nome,
        'comissao': comissao,
      };
}

class Veiculo {
  int codigo;
  String descricao;
  double valor;

  Veiculo({required this.codigo, required this.descricao, required this.valor});

  Map<String, dynamic> toJson() => {
        'codigo': codigo,
        'descricao': descricao,
        'valor': valor,
      };
}

class ItemPedido {
  int sequencial;
  String descricao;
  int quantidade;
  double valor;

  ItemPedido({required this.sequencial, required this.descricao, required this.quantidade, required this.valor});

  Map<String, dynamic> toJson() => {
        'sequencial': sequencial,
        'descricao': descricao,
        'quantidade': quantidade,
        'valor': valor,
      };
}

class PedidoVenda {
  String codigo;
  DateTime data;
  Cliente cliente;
  Vendedor vendedor;
  Veiculo veiculo;
  List<ItemPedido> items;

  PedidoVenda({
    required this.codigo,
    required this.data,
    required this.cliente,
    required this.vendedor,
    required this.veiculo,
    required this.items,
  });

  double calcularPedido() {
    return items.fold(0.0, (total, item) => total + (item.valor * item.quantidade));
  }

  Map<String, dynamic> toJson() => {
        'pedidoVenda': {
          'codigo': codigo,
          'data': data.toIso8601String(),
          'valorPedido': calcularPedido(),
          'cliente': cliente.toJson(),
          'vendedor': vendedor.toJson(),
          'veiculo': veiculo.toJson(),
          'itensPedido': items.map((item) => item.toJson()).toList(),
        }
      };
}

void main() async {
  // Instâncias de exemplo
  var cliente = Cliente(codigo: 1, nome: 'João Silva', tipoCliente: 0);
  var vendedor = Vendedor(codigo: 1, nome: 'Maria Souza', comissao: 5.5);
  var veiculo = Veiculo(codigo: 101, descricao: 'Carro Sedan 1.6', valor: 45000.00);
  var itens = [
    ItemPedido(sequencial: 1, descricao: 'Rodas Esportivas', quantidade: 1, valor: 2500.0),
    ItemPedido(sequencial: 2, descricao: 'Som Automotivo', quantidade: 1, valor: 1500.0),
  ];

  var pedido = PedidoVenda(
    codigo: 'PDV001',
    data: DateTime.now(),
    cliente: cliente,
    vendedor: vendedor,
    veiculo: veiculo,
    items: itens,
  );

  var encoder = JsonEncoder.withIndent('  ');
  var jsonFormatado = encoder.convert(pedido.toJson());

  final arquivoJson = File('sistema_revenda.json');
  await arquivoJson.writeAsString(jsonFormatado);
  print('\n📁 Arquivo JSON salvo como "sistema_revenda.json".');

  stdout.write('Digite o e-mail do destinatário: ');
  String? destinatario = stdin.readLineSync();

  stdout.write('Digite o assunto: ');
  String? assunto = stdin.readLineSync();

  stdout.write('Digite a mensagem: ');
  String? corpoMensagem = stdin.readLineSync();

  final smtpServer = gmail(gmailUsername, gmailPassword);

  final message = Message()
    ..from = Address(gmailUsername, 'Sérgio Dias')
    ..recipients.add(destinatario ?? '')
    ..subject = assunto ?? 'Revenda JSON'
    ..text = corpoMensagem ?? ''
    ..attachments = [FileAttachment(arquivoJson)];

  try {
    final sendReport = await send(message, smtpServer);
    print('\n✅ E-mail enviado com sucesso!');
    print('📬 Destinatário: $destinatario');
    print('📝 Assunto: $assunto');
  } catch (e) {
    print('\n❌ Erro ao enviar o e-mail: $e');
  }
}
