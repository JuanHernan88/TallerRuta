
import 'dart:io';

import 'lector.dart';
import 'lexer.dart';
import 'parser.dart';
import 'transpiler.dart';
import 'errores.dart';

void main(List<String> argumentos) {
  if (argumentos.isEmpty) {
    print('Uso: dart run main.dart <archivo.ruta>');
    exitCode = 1;
    return;
  }

  final rutaArchivo = argumentos[0];

  if (!rutaArchivo.toLowerCase().endsWith('.ruta')) {
    stderr.writeln(
      'El archivo de entrada debe ser un programa Ruta (.ruta).\n'
      'Uso: dart run main.dart <archivo.ruta>\n'
      'Ejemplo: dart run main.dart tests/correcto.ruta',
    );
    exitCode = 1;
    return;
  }

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

    // Paso 4: generar el programa Dart equivalente.
    final transpilador = Transpilador(tokens);
    final rutaSalida = _rutaArchivoDart(rutaArchivo);
    transpilador.escribirArchivo(rutaSalida);

    print('\n=== TRANSPILACIÓN ===');
    print('Código Dart generado en: $rutaSalida');
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

String _rutaArchivoDart(String rutaArchivo) {
  if (rutaArchivo.toLowerCase().endsWith('.ruta')) {
    return '${rutaArchivo.substring(0, rutaArchivo.length - 5)}.dart';
  }

  return '$rutaArchivo.dart';
}
