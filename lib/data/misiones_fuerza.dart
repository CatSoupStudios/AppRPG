List<String> generarMisionesFuerza(int nivel) {
  int repsBase = 5 + (nivel * 2);
  int minBase = 5 + (nivel ~/ 2);

  List<String> plantillas = [
    'Haz ${repsBase + 3} lagartijas al amanecer 💪',
    'Sube escaleras ${repsBase ~/ 2} veces sin descansar 🧗‍♂️',
    'Carga una mochila durante ${minBase + 1} minutos en silencio 🎒',
    'Camina ${minBase + 5} minutos con buena postura 🚶‍♂️',
    'Haz ${repsBase + 3} sentadillas profundas 🦵',
    'Sostén una plancha por ${minBase * 2} segundos 🧘‍♂️',
    'Haz ${repsBase + 4} abdominales sin pausa 🔥',
    'Trote suave durante ${minBase + 2} minutos 🏃‍♂️',
    'Haz ${repsBase + 1} jumping jacks como entrenamiento ninja 🥷',
    'Carga peso por ${minBase + 3} minutos sin usar manos 🧳',
    'Haz ${repsBase - 2} zancadas con respiración controlada 🧘‍♀️',
    'Haz ${repsBase} flexiones de brazos estilo militar 🪖',
    'Súbete a una silla y baja ${repsBase ~/ 2} veces con control 🪑',
    'Pasea cargando un objeto pesado por ${minBase} minutos 🧱',
    'Salta la cuerda ${repsBase + 5} veces (real o imaginaria) 🪢',
    'Haz una serie de yoga de fuerza de ${minBase} minutos 🧘‍♂️',
    'Camina rápido como si llegaras tarde por ${minBase + 2} minutos ⏰',
    'Sube y baja una colina imaginaria ${repsBase ~/ 2} veces 🌄',
    'Haz ${repsBase + 3} estocadas largas y profundas ⚔️',
    'Corre en tu lugar por ${minBase + 4} minutos sin parar 🌀',
    'Sostén una mochila con brazos extendidos por ${minBase * 2} segundos 🏋️‍♂️',
    'Haz una caminata en cuclillas durante ${minBase} minutos 🦍',
    'Arrástrate como soldado ${repsBase ~/ 2} metros 🪖',
    'Levanta y baja una garrafa ${repsBase} veces (o imagina una) 💧',
    'Haz sentadillas con salto ${repsBase + 1} veces 🐸',
    'Corre a ritmo medio por ${minBase + 3} minutos 🏃‍♂️💨',
    'Haz “silla invisible” durante ${minBase * 2} segundos 🪑🔥',
    'Haz burpees ${repsBase - 1} veces sin morir 🧟‍♂️',
    'Lleva un objeto en la cabeza y camina ${minBase} minutos 🤹‍♂️',
    'Pelea con aire (sombra box) por ${minBase + 1} minutos 🥊',
  ];

  plantillas.shuffle();

  return plantillas.take(30).toList();
}
