import 'package:flutter/material.dart';
import '../widgets/card_estabelecimento.dart';

class TelaFavoritos extends StatelessWidget {
  final List<Map<String, dynamic>> dados;
  final Set<String> favoritos;
  final Function(String) onToggleFavorito;

  const TelaFavoritos({
    super.key,
    required this.dados,
    required this.favoritos,
    required this.onToggleFavorito,
  });

  @override
  Widget build(BuildContext context) {
    final favoritosFiltrados =
        dados
            .where((item) => favoritos.contains(item['Comercio']))
            .cast<Map<String, dynamic>>()
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meus Favoritos',
          style: TextStyle(color: Color(0xFF0B66FC)),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0B66FC)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fundo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child:
            favoritosFiltrados.isEmpty
                ? const Center(
                  child: Text(
                    'Nenhum favorito salvo.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
                : ListView.builder(
                  itemCount: favoritosFiltrados.length,
                  itemBuilder: (context, index) {
                    final item = favoritosFiltrados[index];
                    return CardEstabelecimento(
                      item: item,
                      favorito: true,
                      onFavoritar: () => onToggleFavorito(item['Comercio']),
                    );
                  },
                ),
      ),
    );
  }
}
