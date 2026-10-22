
/// Categorías de tokens que reconoce el lenguaje Ruta.
enum TipoToken {
  // Palabras reservadas
  robot,
  forward,
  turn,
  stop,
  right,
  left,
  repeat,
  ifToken,
  then,
  elseToken,
  end,
  returnToken,

  // Elementos léxicos
  identificador,
  numero,

  // Operadores aritméticos
  asignacion,
  suma,
  resta,
  multiplicacion,
  division,

  // Operadores de comparación
  menor,
  mayor,
  menorIgual,
  mayorIgual,
  igualdad,
  diferente,

  // Símbolos de agrupación
  parentesisIzquierdo,
  parentesisDerecho,
  llaveIzquierda,
  llaveDerecha,

  // Control del análisis
  finArchivo,
}

/// Representa un token identificado en el código fuente.
class Token {
  final TipoToken tipo;
  final String lexema;
  final int linea;
  final int columna;

  const Token({
    required this.tipo,
    required this.lexema,
    required this.linea,
    required this.columna,
  });

  @override
  String toString() {
    return '${tipo.name}("$lexema") '
        'línea $linea, columna $columna';
  }
}
