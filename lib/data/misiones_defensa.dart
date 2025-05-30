List<String> generarMisionesDefensa(int nivel) {
  int repsBase = 5 + (nivel * 2);
  int minBase = 5 + (nivel ~/ 2);

  List<String> plantillas = [
    'Haz ${repsBase + 2} respiraciones profundas cuando sientas estrés 🛡️',
    'Aguanta una “plancha” (plank) por ${minBase * 2} segundos 🧘‍♂️',
    'Escribe ${repsBase} pensamientos negativos y transfórmalos en positivos ✍️',
    'Tómate ${minBase + 1} minutos para meditar o solo respirar en calma 😌',
    'Visualiza un escudo protector durante ${minBase + 2} minutos 🛡️',
    'Identifica y pon límite a ${minBase} cosas/personas tóxicas hoy 🚫',
    'Escribe ${repsBase + 1} veces “soy más fuerte de lo que pienso” 💪',
    'Haz ${repsBase} sentadillas mientras piensas en lo que te da paz 🦵',
    'Dedica ${minBase + 3} minutos a proteger tu espacio personal (limpieza, organización) 🧹',
    'Evita que te interrumpan durante ${minBase * 2} minutos en una actividad importante 🚷',
    'Realiza ${repsBase ~/ 2} minutos de estiramientos defensivos 🧘‍♂️',
    'Expresa tus límites con claridad a ${minBase} personas 🗣️',
    'Haz una lista de ${minBase + 1} cosas que te hacen sentir seguro/a 🔐',
    'Ponte en una posición de “postura de poder” por ${minBase + 2} minutos 🦸',
    'Repite un mantra de defensa personal ${repsBase} veces (elige uno propio) 🕉️',
    'Ignora deliberadamente ${minBase} comentarios negativos hoy 🙉',
    'Dedica ${minBase + 1} minutos a tu hobby favorito para recargar energía 🖌️',
    'Apunta ${repsBase ~/ 2} pequeñas victorias que hayas tenido en la semana 🏆',
    'Refuerza tus contraseñas o tu seguridad digital en ${minBase} cuentas 🔒',
    'Haz ${repsBase} repeticiones de tu ejercicio favorito de defensa (boxeo, yoga, etc.) 🥊',
    'Regálate ${minBase + 3} minutos de silencio sin celular 📵',
    'Escribe una carta de auto-defensa (aunque sea solo para ti) ✉️',
    'Imagina cómo bloquearías un ataque con superpoderes durante ${minBase * 2} segundos 🦸‍♂️',
    'Haz un “checklist” de defensa emocional de ${minBase + 1} puntos 📋',
    'Protege tus emociones ignorando ${minBase} chismes hoy 🤐',
    'Haz una actividad donde debas decir “no” a algo tentador ${repsBase ~/ 2} veces ✋',
    'Busca ${minBase} datos sobre cómo protegerte física/emocionalmente hoy 📚',
    'Juega un videojuego de defensa (tower defense, etc.) por ${minBase + 3} minutos 🎮',
    'Pon un objeto simbólico de protección en tu entorno por ${minBase + 1} horas 🧿',
    'Evita responder mensajes durante ${minBase + 2} minutos cuando estés ocupado/a 📴',
  ];

  plantillas.shuffle();

  return plantillas.take(30).toList();
}
