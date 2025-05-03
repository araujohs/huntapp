import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../widgets/grupo_estabelecimento.dart';
import '../widgets/filtro_chips.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_favoritos.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> dados = [];
  List<dynamic> resultados = [];
  final TextEditingController _controller = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? contaGoogle;

  String filtroSelecionado = '';
  Set<String> favoritos = {};

  List<String> ramos = [];

  @override
  void initState() {
    super.initState();
    carregarJson();
    carregarFavoritos();
  }

  void alternarFavorito(String comercio) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoritos.contains(comercio)) {
        favoritos.remove(comercio);
      } else {
        favoritos.add(comercio);
      }
    });
    await prefs.setStringList('favoritos', favoritos.toList());
  }

  Future<void> fazerLoginComGoogle() async {
    try {
      final conta = await _googleSignIn.signIn();
      if (conta != null) {
        setState(() {
          contaGoogle = conta;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bem-vindo(a), ${conta.displayName}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao fazer login com o Google.')),
      );
    }
  }

  Future<void> carregarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final salvos = prefs.getStringList('favoritos') ?? [];
    setState(() {
      favoritos = salvos.toSet();
    });
  }

  Future<void> carregarJson() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/huntapp.json');

    if (await file.exists()) {
      final conteudo = await file.readAsString();
      final List<dynamic> jsonData = json.decode(conteudo);
      aplicarDados(jsonData);
    } else {
      final conteudoPadrao = await rootBundle.loadString('assets/huntapp.json');
      final List<dynamic> jsonData = json.decode(conteudoPadrao);
      await file.writeAsString(json.encode(jsonData));
      aplicarDados(jsonData);
    }
  }

  void aplicarDados(List<dynamic> jsonData) {
    final Set<String> ramosUnicos =
        jsonData
            .map((item) => item['Ramo'].toString().split(','))
            .expand((r) => r)
            .map((r) => r.trim().toLowerCase())
            .toSet();

    setState(() {
      dados = jsonData;
      resultados = jsonData;
      ramos = ramosUnicos.toList()..sort();
    });
  }

  void buscar(String termo) {
    termo = termo.toLowerCase();
    setState(() {
      filtroSelecionado = '';
      resultados =
          dados.where((item) {
            return item['Ramo'].toLowerCase().contains(termo);
          }).toList();
    });
  }

  void filtrarPorRamo(String ramo) {
    setState(() {
      if (filtroSelecionado == ramo) {
        filtroSelecionado = '';
        resultados = dados;
      } else {
        filtroSelecionado = ramo;
        resultados =
            dados
                .where(
                  (item) => item['Ramo']
                      .toLowerCase()
                      .split(',')
                      .map((e) => e.trim())
                      .contains(ramo),
                )
                .toList();
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text(
              'HuntApp',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B66FC), // azul baseado no fundo da imagem
              ),
            ),
          ],
        ),
        actions: [
          if (contaGoogle != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundImage: NetworkImage(contaGoogle!.photoUrl ?? ''),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.login, color: Colors.white),
              tooltip: 'Entrar com Google',
              onPressed: fazerLoginComGoogle,
            ),
          IconButton(
            icon: const Icon(Icons.star, color: Colors.red),
            tooltip: 'Ver favoritos',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => TelaFavoritos(
                        dados: dados.cast<Map<String, dynamic>>(),
                        favoritos: favoritos,
                        onToggleFavorito: alternarFavorito,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fundo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controller,
                onChanged: buscar,
                decoration: const InputDecoration(
                  hintText: 'Buscar por ramo...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              height: 48,
              child: FiltroChips(
                ramos: ramos,
                filtroSelecionado: filtroSelecionado,
                onSelecionar: filtrarPorRamo,
              ),
            ),
            Expanded(
              child:
                  resultados.isEmpty
                      ? const Center(
                        child: Text(
                          'Nenhum resultado encontrado',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                      : ListView(
                        children:
                            ramos.map((ramo) {
                              final grupo =
                                  resultados
                                      .where(
                                        (item) => item['Ramo']
                                            .toLowerCase()
                                            .contains(ramo),
                                      )
                                      .toList();
                              if (grupo.isEmpty) return const SizedBox.shrink();
                              return GrupoEstabelecimento(
                                ramo: ramo,
                                grupo: grupo.cast<Map<String, dynamic>>(),
                                favoritos: favoritos,
                                onToggleFavorito: (comercio) async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  setState(() {
                                    if (favoritos.contains(comercio)) {
                                      favoritos.remove(comercio);
                                    } else {
                                      favoritos.add(comercio);
                                    }
                                  });
                                  await prefs.setStringList(
                                    'favoritos',
                                    favoritos.toList(),
                                  );
                                },
                              );
                            }).toList(),
                      ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/img-rodape.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
