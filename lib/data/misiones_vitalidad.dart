List<String> generarMisionesVitalidad(int nivel) {
  int repsBase = 5 + (nivel * 2);
  int minBase = 5 + (nivel ~/ 2);

  List<String> plantillas = [
    'Duerme al menos ${minBase + 7} horas esta noche 😴',
    'Toma agua cada ${minBase + 1} horas durante el día 💧',
    'Haz una siesta corta de ${minBase} minutos hoy 💤',
    'Haz ${repsBase} respiraciones profundas al despertar 🫁',
    'Realiza una caminata de ${minBase + 5} minutos al aire libre 🚶‍♂️',
    'Prepara una comida saludable con al menos ${minBase + 2} ingredientes frescos 🥗',
    'Estira tu cuerpo durante ${minBase + 2} minutos al comenzar el día 🤸‍♂️',
    'Dedica ${minBase + 5} minutos a relajarte sin dispositivos 📵',
    'Haz una rutina de autocuidado (mascarilla, baño caliente, etc.) durante ${minBase + 3} minutos 🛁',
    'Come fruta o verdura ${repsBase} veces hoy 🍎',
    'Escribe una lista de ${minBase + 2} cosas por las que agradeces hoy ✍️',
    'Haz una sesión breve de meditación de ${minBase} minutos 🧘‍♂️',
    'Haz ${repsBase} sentadillas para activar la circulación 🦵',
    'Canta tu canción favorita ${repsBase} veces para liberar estrés 🎶',
    'Sal a tomar el sol durante ${minBase + 4} minutos ☀️',
    'Habla con un ser querido al menos ${repsBase ~/ 2} minutos hoy ☎️',
    'Lee algo motivador durante ${minBase + 2} minutos 📚',
    'Desconéctate de redes sociales por ${minBase * 2} minutos hoy 🔌',
    'Date un masaje en manos o cuello durante ${minBase + 2} minutos 🤲',
    'Pinta o dibuja algo sin juzgar el resultado durante ${minBase + 1} minutos 🎨',
    'Danza libremente por la casa durante ${minBase + 3} minutos 💃',
    'Haz una pausa activa cada ${minBase} horas mientras trabajas ⏰',
    'Pon música relajante durante ${minBase + 3} minutos y solo escucha 🎧',
    'Haz una postura de yoga restaurativa por ${minBase * 2} segundos 🧘‍♀️',
    'Aromatiza tu cuarto con olores que te gusten por ${minBase} minutos 🌸',
    'Lleva un snack saludable para media tarde 🥒',
    'Baila frente al espejo por ${minBase + 2} minutos 🪞',
    'Sonríe a alguien ${repsBase} veces hoy 😊',
    'Haz una limpieza ligera de tu espacio durante ${minBase + 2} minutos 🧹',
    'Visualiza algo positivo durante ${minBase * 2} segundos 🌈',
  ];

  plantillas.shuffle();

  return plantillas.take(30).toList();
}
