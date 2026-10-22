
import 'dart:io';

import 'lector.dart';
import 'lexer.dart';
import 'parser.dart';
import 'errores.dart';

void main(List<String> argumentos) {
  if (argumentos.isEmpty) {
    print('Uso: dart run main.dart <archivo.ruta>');
    exitCode = 1;
    return;
  }

  final rutaArchivo = argumentos[0];

  try {
    // Paso 1: leer el archivo fuente.
    final lector = Lector();
    final codigo = lector.leerArchivo(rutaArchivo);

    // Paso 2: realizar el análisis léxico.
    final lexer = Lexer(codigo);
    final tokens = lexer.analizar();

    print('=== ANÁLISIS LÉXICO ===');

    for (final token in tokens) {
      print(token);
    }

    // Paso 3: comprobar la estructura sintáctica.
    final parser = Parser(tokens);
    parser.analizar();

    print('\n=== RESULTADO ===');
    print('Análisis léxico correcto.');
    print('Análisis sintáctico correcto.');
    print('El programa Ruta cumple la gramática.');
  } on ErrorRuta catch (error) {
    stderr.writeln('\n$error');
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('Error al leer el archivo: ${error.message}');
    exitCode = 1;
  } catch (error) {
    stderr.writeln('Error inesperado: $error');
    exitCode = 1;
  }
}
