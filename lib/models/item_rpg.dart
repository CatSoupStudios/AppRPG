class ItemRPG {
  final String id;
  final String nombre;
  final String emoji;
  final String descripcion;
  final bool consumible;

  ItemRPG({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.descripcion,
    this.consumible = false,
  });
}
