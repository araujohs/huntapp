import 'package:flutter/material.dart';
import 'card_estabelecimento.dart';

class GrupoEstabelecimento extends StatelessWidget {
  final String ramo;
  final List<Map<String, dynamic>> grupo;
  final Set<String> favoritos;
  final Function(String) onToggleFavorito;

  const GrupoEstabelecimento({
    super.key,
    required this.ramo,
    required this.grupo,
    required this.favoritos,
    required this.onToggleFavorito,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        ramo[0].toUpperCase() + ramo.substring(1),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      leading: Icon(
        ramo.contains('restaurante')
            ? Icons.restaurant
            : ramo.contains('cafeteria')
            ? Icons.coffee
            : ramo.contains('petshop')
            ? Icons.pets
            : ramo.contains('estética')
            ? Icons.spa
            : ramo.contains('vestuário')
            ? Icons.checkroom
            : Icons.store,
        color: Colors.orange,
      ),
      children:
          grupo.map((item) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder:
                  (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
              child: CardEstabelecimento(
                key: ValueKey(item['Comercio']),
                item: item,
                favorito: favoritos.contains(item['Comercio']),
                onFavoritar: () => onToggleFavorito(item['Comercio']),
              ),
            );
          }).toList(),
    );
  }
}
