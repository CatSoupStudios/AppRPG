List<String> generarMisionesInteligencia(int nivel) {
  int minBase = 5 + (nivel ~/ 2);

  List<String> plantillas = [
    'Lee un artículo o capítulo durante ${minBase + 4} minutos 📖',
    'Resuelve un acertijo lógico o matemático 🧩',
    'Escribe una idea de negocio creativa 💡',
    'Aprende una palabra nueva en otro idioma y úsala en una frase 🌎',
    'Haz un resumen en tu libreta de algo que leíste 📝',
    'Mira un video educativo de al menos ${minBase + 3} minutos 🎥',
    'Explica un concepto difícil a alguien (o a ti mismo) 🗣️',
    'Resuelve 5 operaciones matemáticas sin calculadora ➗',
    'Lee sobre una cultura diferente durante ${minBase + 2} minutos 🌍',
    'Haz una lista de tus 3 mejores ideas del día 🧠',
    'Medita sobre un problema y anota posibles soluciones 🧘‍♂️',
    'Investiga una curiosidad científica 🧪',
    'Haz un crucigrama, sudoku o puzzle mental 🧩',
    'Estudia el significado de una cita filosófica 🏛️',
    'Haz un reto de memoria (memoriza una frase, número, etc) 🧲',
    'Haz una pregunta incómoda sobre el mundo y busca la respuesta 🔎',
    'Lee una biografía de un personaje histórico durante ${minBase + 2} minutos 📚',
    'Diseña un mapa mental de un tema que te interese 🗺️',
    'Juega un juego de lógica o estrategia por ${minBase + 1} minutos ♟️',
    'Corrige un error ortográfico en algún texto tuyo ✍️',
    'Busca una palabra en el diccionario que no conozcas 📔',
    'Escribe una pequeña historia de 3 frases 🧙‍♂️',
    'Escucha un podcast de ciencia, historia o filosofía 🎧',
    'Reflexiona sobre una decisión que hayas tomado últimamente 🤔',
    'Haz una lista de tus habilidades y cómo mejorarlas 📝',
    'Inventa un chiste inteligente y cuéntalo 😏',
    'Lee las noticias y filtra una fake news 🗞️',
    'Convierte una experiencia del día en una lección aprendida 📘',
    'Realiza una actividad ambidiestra (escribe o dibuja con la otra mano) ✍️',
    'Haz una mini-investigación sobre un tema trending en ${minBase} minutos 🚀',
  ];

  plantillas.shuffle();

  return plantillas.take(30).toList();
}
