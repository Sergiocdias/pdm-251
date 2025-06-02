import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() async {
  final username = 'email';
  final password = 'senha_do_app';

  stdout.write('Digite o e-mail do destinatário: ');
  String? destinatario = stdin.readLineSync();

  stdout.write('Digite o assunto: ');
  String? assunto = stdin.readLineSync();

  stdout.write('Digite a mensagem: ');
  String? corpoMensagem = stdin.readLineSync();

  final smtpServer = SmtpServer(
    'smtp.gmail.com',
    port: 587,
    username: username,
    password: password,
    ssl: false,
  );

  final message = Message()
    ..from = Address(username, 'Sergio')
    ..recipients.add(destinatario ?? '')
    ..subject = assunto ?? ''
    ..text = corpoMensagem ?? '';

  try {
    final sendReport = await send(message, smtpServer);
    print('\n✅ E-mail enviado com sucesso!');
    print('📬 Destinatário: $destinatario');
    print('📝 Assunto: $assunto');
  } catch (e) {
    print('\n❌ Erro ao enviar o e-mail: $e');
  }
}