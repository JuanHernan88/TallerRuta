
/// Clase base para los errores encontrados al analizar un programa Ruta.
class ErrorRuta implements Exception {
  final String tipo;
  final String mensaje;
  final int linea;
  final int columna;

  const ErrorRuta({
    required this.tipo,
    required this.mensaje,
    required this.linea,
    required this.columna,
  });

  @override
  String toString() {
    return '$tipo en línea $linea, columna $columna: $mensaje';
  }
}

/// Error producido cuando aparece un carácter o elemento no reconocido.
class ErrorLexico extends ErrorRuta {
  ErrorLexico({
    required String mensaje,
    required int linea,
    required int columna,
  }) : super(
          tipo: 'Error léxico',
          mensaje: mensaje,
          linea: linea,
          columna: columna,
        );
}

/// Error producido cuando los tokens no cumplen la gramática de Ruta.
class ErrorSintactico extends ErrorRuta {
  ErrorSintactico({
    required String mensaje,
    required int linea,
    required int columna,
  }) : super(
          tipo: 'Error sintáctico',
          mensaje: mensaje,
          linea: linea,
          columna: columna,
        );
}
