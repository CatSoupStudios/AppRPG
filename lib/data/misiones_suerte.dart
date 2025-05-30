List<String> generarMisionesSuerte(int nivel) {
  int repsBase = 5 + (nivel * 2);
  int minBase = 5 + (nivel ~/ 2);

  List<String> plantillas = [
    'Lanza una moneda ${repsBase} veces hoy y anota tus resultados 🍀',
    'Haz ${repsBase ~/ 2} actividades espontáneas sin pensarlo demasiado 🤸‍♂️',
    'Juega ${minBase + 1} partidas rápidas a un juego de azar 🎲',
    'Haz una lista de ${minBase} decisiones al azar y cumple al menos una 🎯',
    'Tira un dado ${repsBase + 2} veces y deja que decida micro-acciones del día 🎲',
    'Pide a alguien elegir un número del 1 al ${repsBase + 5} y haz algo con ese número 🔢',
    'Busca ${minBase + 3} curiosidades random en internet 🌐',
    'Haz una acción amable al azar a ${minBase} personas diferentes 🤝',
    'Cambia tu playlist ${minBase + 1} veces al día por una elegida al azar 🎶',
    'Deja que una app de azar elija una actividad por ti ${repsBase ~/ 2} veces 📱',
    'Escribe ${minBase + 1} palabras al azar y úsalas en una historia corta 📝',
    'Abre un libro ${repsBase} veces al azar y anota la primera palabra que veas 📖',
    'Haz un dibujo con los ojos cerrados durante ${minBase * 2} segundos 🎨',
    'Deja que el clima decida una de tus actividades hoy (${minBase} opciones) ☀️🌧️',
    'Usa la mano no dominante para ${minBase} acciones del día ✋',
    'Haz una encuesta rápida a ${repsBase ~/ 2} personas sobre un tema random 🗣️',
    'Lanza una moneda para decidir entre ${minBase} opciones de comida 🍽️',
    'Toma una ruta diferente en tu camino al menos ${repsBase ~/ 2} veces esta semana 🚗',
    'Haz ${minBase + 2} cosas a una hora diferente a la habitual ⏰',
    'Escribe ${repsBase} deseos o metas y elige uno al azar para trabajar hoy 🎯',
    'Cambia el fondo de pantalla de tu celular ${minBase} veces 🖼️',
    'Juega piedra, papel o tijera ${repsBase} veces (aunque sea tú solo) ✋🤚✌️',
    'Haz zapping en la TV/radio y escucha el primer canal durante ${minBase * 2} minutos 📻',
    'Acepta la primera invitación espontánea que recibas hoy (o mándala tú) 💌',
    'Haz ${minBase + 2} actividades que normalmente evitarías por rutina 🔄',
    'Elige un color al azar y usa/prueba ${minBase + 1} objetos de ese color 🎨',
    'Deja una decisión importante a un dado (entre ${minBase} opciones) 🎲',
    'Haz un reto viral random por al menos ${minBase + 3} minutos 🕹️',
    'Busca una noticia completamente aleatoria y cuéntasela a alguien 📰',
    'Llama o escribe a alguien que no contactabas hace más de ${minBase} meses 📞',
  ];

  plantillas.shuffle();

  return plantillas.take(30).toList();
}
