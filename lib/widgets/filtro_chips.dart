import 'package:flutter/material.dart';

class FiltroChips extends StatelessWidget {
  final List<String> ramos;
  final String filtroSelecionado;
  final Function(String) onSelecionar;

  const FiltroChips({
    super.key,
    required this.ramos,
    required this.filtroSelecionado,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children:
              ramos.map((ramo) {
                final bool selecionado = filtroSelecionado == ramo;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(ramo[0].toUpperCase() + ramo.substring(1)),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                    elevation: 2,
                    pressElevation: 4,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    side: const BorderSide(color: Colors.orangeAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    selected: selecionado,
                    selectedColor: Colors.orange,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selecionado ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (_) => onSelecionar(ramo),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
