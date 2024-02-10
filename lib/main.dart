import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Socket socket;
  final client = http.Client();
  final String url = 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    connectToServer();
    _fetchTarefas();
  }

  List<dynamic> tarefas = [];

  void _fetchTarefas() async {
    final respose = await client.get(Uri.parse('$url/todo'));

    if (respose.statusCode == 200) {
      setState(() {
        tarefas = jsonDecode(respose.body)['tasks'];
      });
    } else {
      if (!mounted) return;

      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Erro ao buscar tarefas'),
        ),
      );
    }
  }

  void connectToServer() {
    Socket socket = io(
        url,
        OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build());
    socket.connect();
    socket.connect();

    socket.onConnect((_) {
      print('Conectado ao servidor');
    });

    socket.on('nova_tarefa', (data) {
      setState(() {
        tarefas.add(data);
      });
    });

    socket.onDisconnect((_) {
      print('Desconectado do servidor');
    });

    socket.onError((error) {
      print('Erro de conexão: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Tarefas'),
        ),
        body: ListView.builder(
          itemCount: tarefas.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(tarefas[index]),
            );
          },
        ),
      ),
    );
  }
}
