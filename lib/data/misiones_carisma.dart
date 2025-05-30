List<String> generarMisionesCarisma(int nivel) {
  int repsBase = 5 + (nivel * 2);
  int minBase = 5 + (nivel ~/ 2);

  List<String> plantillas = [
    'Haz un cumplido sincero a ${repsBase} personas hoy 😏',
    'Inicia una conversación con alguien que no conozcas muy bien 🗣️',
    'Sonríe conscientemente a todos los que te cruces durante ${minBase + 3} minutos 😊',
    'Cuéntale una historia graciosa a un amigo o familiar 🤭',
    'Haz una pregunta profunda a alguien y escucha realmente la respuesta 👂',
    'Haz contacto visual durante al menos ${minBase * 2} segundos en una charla 👀',
    'Graba un audio con un mensaje positivo para un amigo y mándaselo 🎤',
    'Comparte algo personal con alguien cercano durante ${minBase} minutos 🤝',
    'Habla en público (puede ser en voz alta en casa) durante ${minBase + 1} minutos 🎤',
    'Ayuda a resolver un problema ajeno dedicando al menos ${minBase} minutos 🤲',
    'Cuenta un chiste o anécdota en grupo ${repsBase ~/ 2} veces 😂',
    'Haz una pregunta curiosa en una conversación y escucha la respuesta 👂',
    'Presenta a dos personas que no se conocen y crea una nueva conexión 🕸️',
    'Organiza una mini reunión espontánea (virtual o presencial) 🎉',
    'Da las gracias con entusiasmo al menos ${repsBase} veces hoy 🙏',
    'Haz una publicación auténtica en redes sociales sin filtros 🖼️',
    'Haz un acto de amabilidad anónima hoy 🤫',
    'Imita la postura de alguien por ${minBase} minutos y observa la reacción 🕺',
    'Expresa una opinión controversial pero sin atacar, solo con argumentos 💬',
    'Escribe una carta (real o digital) a alguien expresando admiración 💌',
    'Dile a alguien algo positivo sobre sí mism@ que normalmente no dirías 🌟',
    'Cuenta una anécdota de tu niñez y observa la reacción 😅',
    'Haz un reto de no interrumpir a nadie durante ${minBase + 2} minutos en charla 🤐',
    'Graba un video corto hablando de un tema que te apasione 🎬',
    'Ríete de ti mism@ frente a alguien por un pequeño error 😜',
    'Ofrece ayuda a alguien sin que te lo pida ${repsBase ~/ 2} veces 🤗',
    'Juega a imitar diferentes acentos o voces durante ${minBase} minutos 🎭',
    'Deja una nota positiva en un lugar público 📝',
    'Cuéntale a alguien un sueño o meta personal 🧠',
    'Haz una dinámica de “preguntas rápidas” con un amigo durante ${minBase + 1} minutos ⏱️',
  ];

  plantillas.shuffle();

  return plantillas.take(30).toList();
}
