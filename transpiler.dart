
import 'dart:io';

import 'token.dart';
import 'errores.dart';

/// Traduce un programa Ruta ya tokenizado a Dart equivalente y lo escribe
/// en un archivo `.dart`.
class Transpilador {
  final List<Token> tokens;
  int _posicion = 0;

  final StringBuffer _cuerpo = StringBuffer();
  final Set<String> _variables = {};
  int _indentacion = 1;
  int _ciclosAnidados = 0;

  Transpilador(this.tokens);

  Token get _actual => tokens[_posicion];

  bool _coincide(TipoToken tipo) => _actual.tipo == tipo;

  Token _avanzar() {
    final token = _actual;

    if (!_coincide(TipoToken.finArchivo)) {
      _posicion++;
    }

    return token;
  }

  Token _esperar(TipoToken tipo, String mensaje) {
    if (_coincide(tipo)) {
      return _avanzar();
    }

    throw ErrorSintactico(
      mensaje:
          '$mensaje Se encontró "${_actual.lexema.isEmpty ? "fin de archivo" : _actual.lexema}".',
      linea: _actual.linea,
      columna: _actual.columna,
    );
  }

  /// Genera el código Dart y lo guarda en [rutaSalida].
  void escribirArchivo(String rutaSalida) {
    File(rutaSalida).writeAsStringSync(generar());
  }

  /// Devuelve el programa Dart equivalente como texto.
  String generar() {
    _cuerpo.clear();
    _variables.clear();
    _posicion = 0;
    _indentacion = 1;
    _ciclosAnidados = 0;

    _esperar(
      TipoToken.robot,
      'El programa debe comenzar con la palabra reservada "robot".',
    );

    final nombreRobot = _esperar(
      TipoToken.identificador,
      'Se esperaba el nombre del robot.',
    ).lexema;

    _linea("final robot = Robot('$nombreRobot');");
    _linea('');

    _listaInstrucciones({TipoToken.finArchivo});

    _esperar(
      TipoToken.finArchivo,
      'Se esperaba el final del archivo.',
    );

    return '''
// Código generado automáticamente desde el lenguaje Ruta.
// No editar a mano.

$_runtimeRobot

void main() {
$_cuerpo}
''';
  }

  void _listaInstrucciones(Set<TipoToken> cierres) {
    if (cierres.contains(_actual.tipo)) {
      throw ErrorSintactico(
        mensaje: 'Se esperaba al menos una instrucción.',
        linea: _actual.linea,
        columna: _actual.columna,
      );
    }

    while (!_coincide(TipoToken.finArchivo) &&
        !cierres.contains(_actual.tipo)) {
      _instruccion();
    }
  }

  void _instruccion() {
    switch (_actual.tipo) {
      case TipoToken.identificador:
        _asignacion();
        break;

      case TipoToken.forward:
        _avanzar();
        _escribirIndentacion();
        _cuerpo.write('robot.forward(');
        _expresion();
        _cuerpo.writeln(');');
        break;

      case TipoToken.turn:
        _avanzar();
        if (_coincide(TipoToken.right)) {
          _avanzar();
          _linea('robot.turnRight();');
        } else if (_coincide(TipoToken.left)) {
          _avanzar();
          _linea('robot.turnLeft();');
        } else {
          throw ErrorSintactico(
            mensaje: 'Después de "turn" se esperaba "right" o "left".',
            linea: _actual.linea,
            columna: _actual.columna,
          );
        }
        break;

      case TipoToken.stop:
        _avanzar();
        _linea('robot.stop();');
        break;

      case TipoToken.repeat:
        _ciclo();
        break;

      case TipoToken.ifToken:
        _condicional();
        break;

      case TipoToken.returnToken:
        _retorno();
        break;

      default:
        throw ErrorSintactico(
          mensaje: 'Se esperaba una instrucción válida de Ruta.',
          linea: _actual.linea,
          columna: _actual.columna,
        );
    }
  }

  void _asignacion() {
    final nombre = _esperar(
      TipoToken.identificador,
      'Se esperaba el nombre de la variable.',
    ).lexema;

    _esperar(
      TipoToken.asignacion,
      'Se esperaba "=" después del nombre de la variable.',
    );

    _escribirIndentacion();

    if (_variables.add(nombre)) {
      _cuerpo.write('num $nombre = ');
    } else {
      _cuerpo.write('$nombre = ');
    }

    _expresion();
    _cuerpo.writeln(';');
  }

  void _ciclo() {
    _esperar(TipoToken.repeat, 'Se esperaba "repeat".');

    final indice = '_rutaRepeat$_ciclosAnidados';
    _ciclosAnidados++;

    _escribirIndentacion();
    _cuerpo.write('for (var $indice = 0; $indice < (');
    _expresion();
    _cuerpo.writeln(').toInt(); $indice++) {');

    _esperar(
      TipoToken.llaveIzquierda,
      'Se esperaba "{" para iniciar el bloque del ciclo.',
    );

    _indentacion++;
    _listaInstrucciones({TipoToken.llaveDerecha});
    _indentacion--;

    _esperar(
      TipoToken.llaveDerecha,
      'Se esperaba "}" para cerrar el ciclo.',
    );

    _ciclosAnidados--;
    _linea('}');
  }

  void _condicional() {
    _esperar(TipoToken.ifToken, 'Se esperaba "if".');

    _escribirIndentacion();
    _cuerpo.write('if (');
    _condicion();
    _cuerpo.writeln(') {');

    _esperar(
      TipoToken.then,
      'Se esperaba "then" después de la condición.',
    );

    _indentacion++;
    _listaInstrucciones({
      TipoToken.elseToken,
      TipoToken.end,
    });
    _indentacion--;

    if (_coincide(TipoToken.elseToken)) {
      _avanzar();
      _linea('} else {');

      _indentacion++;
      _listaInstrucciones({TipoToken.end});
      _indentacion--;
    }

    _esperar(
      TipoToken.end,
      'Se esperaba "end" para cerrar la condición.',
    );

    _linea('}');
  }

  void _retorno() {
    _esperar(TipoToken.returnToken, 'Se esperaba "return".');

    final base = _esperar(
      TipoToken.identificador,
      'Se esperaba el nombre de la base después de "return".',
    ).lexema;

    _linea("robot.returnTo('$base');");
  }

  void _condicion() {
    _expresion();

    if (!_esOperadorComparacion(_actual.tipo)) {
      throw ErrorSintactico(
        mensaje:
            'Se esperaba un operador de comparación: <, >, <=, >=, == o !=.',
        linea: _actual.linea,
        columna: _actual.columna,
      );
    }

    _cuerpo.write(' ${_avanzar().lexema} ');
    _expresion();
  }

  bool _esOperadorComparacion(TipoToken tipo) {
    return tipo == TipoToken.menor ||
        tipo == TipoToken.mayor ||
        tipo == TipoToken.menorIgual ||
        tipo == TipoToken.mayorIgual ||
        tipo == TipoToken.igualdad ||
        tipo == TipoToken.diferente;
  }

  void _expresion() {
    _termino();

    while (_coincide(TipoToken.suma) || _coincide(TipoToken.resta)) {
      _cuerpo.write(' ${_avanzar().lexema} ');
      _termino();
    }
  }

  void _termino() {
    _factor();

    while (_coincide(TipoToken.multiplicacion) ||
        _coincide(TipoToken.division)) {
      _cuerpo.write(' ${_avanzar().lexema} ');
      _factor();
    }
  }

  void _factor() {
    if (_coincide(TipoToken.numero) ||
        _coincide(TipoToken.identificador)) {
      _cuerpo.write(_avanzar().lexema);
      return;
    }

    if (_coincide(TipoToken.parentesisIzquierdo)) {
      _avanzar();
      _cuerpo.write('(');
      _expresion();
      _esperar(
        TipoToken.parentesisDerecho,
        'Se esperaba ")" para cerrar la expresión.',
      );
      _cuerpo.write(')');
      return;
    }

    throw ErrorSintactico(
      mensaje: 'Se esperaba un número, un identificador o "(".',
      linea: _actual.linea,
      columna: _actual.columna,
    );
  }

  void _linea(String texto) {
    _escribirIndentacion();
    _cuerpo.writeln(texto);
  }

  void _escribirIndentacion() {
    _cuerpo.write('  ' * _indentacion);
  }

  static const String _runtimeRobot = r'''
class Robot {
  final String nombre;
  double x = 0;
  double y = 0;
  /// 0 = este, 1 = sur, 2 = oeste, 3 = norte
  int direccion = 0;
  bool detenido = false;

  Robot(this.nombre);

  void forward(num distancia) {
    if (detenido) {
      print('$nombre está detenido y no puede avanzar.');
      return;
    }

    final d = distancia.toDouble();

    switch (direccion % 4) {
      case 0:
        x += d;
        break;
      case 1:
        y -= d;
        break;
      case 2:
        x -= d;
        break;
      case 3:
        y += d;
        break;
    }

    print('$nombre avanza $distancia. Posición: (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})');
  }

  void turnRight() {
    if (detenido) return;
    direccion = (direccion + 1) % 4;
    print('$nombre gira a la derecha. Dirección: ${_nombreDireccion()}');
  }

  void turnLeft() {
    if (detenido) return;
    direccion = (direccion + 3) % 4;
    print('$nombre gira a la izquierda. Dirección: ${_nombreDireccion()}');
  }

  void stop() {
    detenido = true;
    print('$nombre se detiene.');
  }

  void returnTo(String base) {
    x = 0;
    y = 0;
    direccion = 0;
    detenido = false;
    print('$nombre regresa a la base "$base". Posición: (0.00, 0.00)');
  }

  String _nombreDireccion() {
    switch (direccion % 4) {
      case 0:
        return 'este';
      case 1:
        return 'sur';
      case 2:
        return 'oeste';
      default:
        return 'norte';
    }
  }
}
''';
}
