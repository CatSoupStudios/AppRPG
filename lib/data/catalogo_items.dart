import '../models/item_rpg.dart';

final Map<String, ItemRPG> catalogoItems = {
  'pocion': ItemRPG(
    id: 'pocion',
    nombre: 'Poción',
    emoji: '🧪',
    descripcion: 'Restaura energía o salud. Se puede usar desde el inventario.',
    consumible: true,
  ),
  'piedra_runica': ItemRPG(
    id: 'piedra_runica',
    nombre: 'Piedra Rúnica',
    emoji: '🪨',
    descripcion: 'Fragmento mágico utilizado para mejorar habilidades.',
    consumible: false,
  ),
  'oro': ItemRPG(
    id: 'oro',
    nombre: 'Oro',
    emoji: '🪙',
    descripcion: 'Moneda dorada utilizada para comerciar con el mercader.',
    consumible: false,
  ),
};
