
import 'dart:io';

/// Lee el contenido de un archivo fuente del lenguaje Ruta.
class Lector {
  /// Lee un archivo .ruta y devuelve todo su contenido como texto.
  String leerArchivo(String rutaArchivo) {
    final archivo = File(rutaArchivo);

    if (!archivo.existsSync()) {
      throw FileSystemException(
        'No se encontró el archivo fuente.',
        rutaArchivo,
      );
    }

    return archivo.readAsStringSync();
  }
}
