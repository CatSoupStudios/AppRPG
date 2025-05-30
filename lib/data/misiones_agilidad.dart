List<String> generarMisionesAgilidad(int nivel) {
  int repsBase = 5 + (nivel * 2);
  int minBase = 5 + (nivel ~/ 2);

  List<String> plantillas = [
    'Haz ${repsBase + 3} saltos de tijera a máxima velocidad ⚡',
    'Corre en tu lugar durante ${minBase + 2} minutos sin parar 🏃‍♂️',
    'Haz una carrera de relevos improvisada con amigos o familiares (${repsBase} vueltas cada uno) 🏃‍♀️',
    'Realiza ${repsBase + 2} sentadillas con salto 🦵',
    'Sube y baja un escalón rápidamente ${repsBase * 2} veces 🪜',
    'Haz “puntas de pie” y “talones” alternados durante ${minBase * 2} segundos 👣',
    'Haz ${repsBase ~/ 2} burpees y cuenta cuántos haces en un minuto 🔥',
    'Juega a esquivar objetos (pelota, cojín, etc.) durante ${minBase + 1} minutos 🤾‍♂️',
    'Haz un circuito de obstáculos con muebles y recórrelo ${repsBase} veces 🪑',
    'Realiza un sprint de ${minBase + 3} segundos en tu patio/casa/jardín ⏱️',
    'Haz una rutina de estiramientos dinámicos durante ${minBase + 2} minutos 🧘‍♂️',
    'Realiza ${repsBase + 1} cambios de dirección rápida en un pasillo 🏃‍♂️↔️',
    'Salta a la cuerda (real o imaginaria) ${repsBase + 5} veces 🪢',
    'Haz equilibrio en un pie durante ${minBase * 2} segundos por lado 🦶',
    'Haz una rutina de baile libre durante ${minBase + 3} minutos 💃',
    'Juega “piso es lava” moviéndote rápido por la casa durante ${minBase} minutos 🌋',
    'Haz ${repsBase + 2} lagartijas y salta después de cada una 💪➡️🦵',
    'Practica “cambios de ritmo” en caminata o trote cada ${minBase} segundos 🔁',
    'Haz equilibrio en una línea recta (puede ser una cuerda o cinta) durante ${minBase + 2} minutos 🎗️',
    'Realiza movimientos de shadow boxing rápido durante ${minBase + 1} minutos 🥊',
    'Haz jumping jacks y toca el piso cada ${repsBase ~/ 2} repeticiones ⬆️⬇️',
    'Haz una mini carrera de obstáculos con cronómetro y trata de mejorar tu tiempo ⏱️',
    'Haz equilibrio sobre una pierna con los ojos cerrados por ${minBase} segundos 🚶‍♂️',
    'Haz ${repsBase} repeticiones de cambios rápidos de dirección 🏃‍♀️↔️',
    'Lanza y atrapa un objeto pequeño en el aire ${repsBase + 2} veces 🪁',
    'Haz sentadillas rápidas durante ${minBase * 2} segundos 🦵💨',
    'Salta en un solo pie cambiando cada ${repsBase ~/ 2} saltos 🦶',
    'Juega un minijuego de reacción en el celular o compu durante ${minBase + 2} minutos 📱⚡',
    'Haz una rutina HIIT corta de al menos ${minBase + 1} minutos 🏋️‍♂️',
    'Haz equilibrio en una superficie inestable (almohada, toalla) durante ${minBase * 2} segundos 🤸‍♂️',
  ];

  plantillas.shuffle();

  return plantillas.take(30).toList();
}
