import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CardEstabelecimento extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool favorito;
  final VoidCallback onFavoritar;

  const CardEstabelecimento({
    super.key,
    required this.item,
    required this.favorito,
    required this.onFavoritar,
  });

  bool _ehCelular(String telefone) {
    final digitos = telefone.replaceAll(RegExp(r'\D'), '');
    return digitos.length >= 11 &&
        digitos.substring(digitos.length - 9, digitos.length - 8) == '9';
  }

  @override
  Widget build(BuildContext context) {
    final telefone = item['Telefone'] ?? '';
    final geo = item['Geolocalizacao'];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['Comercio'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    favorito ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                  ),
                  onPressed: onFavoritar,
                ),
                if (telefone.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      _ehCelular(telefone)
                          ? FontAwesomeIcons.whatsapp
                          : Icons.phone,
                      color: _ehCelular(telefone) ? Colors.green : Colors.blue,
                    ),
                    onPressed: () async {
                      final digitos = telefone.replaceAll(RegExp(r'\D'), '');
                      final uri =
                          _ehCelular(telefone)
                              ? Uri.parse('https://wa.me/55$digitos')
                              : Uri.parse('tel:$digitos');
                      final messenger = ScaffoldMessenger.of(context);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Não foi possível abrir o aplicativo.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                if (geo != null && geo.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  FontAwesomeIcons.mapLocationDot,
                                  color: Colors.blue,
                                ),
                                title: const Text('Abrir no Google Maps'),
                                onTap: () async {
                                  final uri = Uri.parse(
                                    'https://www.google.com/maps/search/?api=1&query=$geo',
                                  );
                                  Navigator.pop(context);
                                  if (!(await launchUrl(uri))) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Não foi possível abrir o Google Maps.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  FontAwesomeIcons.waze,
                                  color: Colors.indigo,
                                ),
                                title: const Text('Abrir no Waze'),
                                onTap: () async {
                                  final uri = Uri.parse(
                                    'https://waze.com/ul?ll=$geo&navigate=yes',
                                  );
                                  Navigator.pop(context);
                                  if (!(await launchUrl(uri))) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Não foi possível abrir o Waze.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
