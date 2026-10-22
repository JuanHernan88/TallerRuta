
import 'token.dart';
import 'errores.dart';

/// Analizador sintáctico descendente recursivo para el lenguaje Ruta.
class Parser {
  final List<Token> tokens;
  int _posicion = 0;

  Parser(this.tokens);

  Token get _actual => tokens[_posicion];

  bool _coincide(TipoToken tipo) => _actual.tipo == tipo;

  Token _avanzar() {
    final token = _actual;

    if (!_coincide(TipoToken.finArchivo)) {
      _posicion++;
    }

    return token;
  }

  Token _esperar(
    TipoToken tipo,
    String mensaje,
  ) {
    if (_coincide(tipo)) {
      return _avanzar();
    }

    throw ErrorSintactico(
      mensaje: '$mensaje Se encontró "${_actual.lexema.isEmpty ? "fin de archivo" : _actual.lexema}".',
      linea: _actual.linea,
      columna: _actual.columna,
    );
  }

  /// Punto de entrada: robot identificador y una o más instrucciones.
  void analizar() {
    _esperar(
      TipoToken.robot,
      'El programa debe comenzar con la palabra reservada "robot".',
    );

    _esperar(
      TipoToken.identificador,
      'Se esperaba el nombre del robot.',
    );

    _listaInstrucciones({
      TipoToken.finArchivo,
    });

    _esperar(
      TipoToken.finArchivo,
      'Se esperaba el final del archivo.',
    );
  }

  /// Analiza una lista no vacía de instrucciones hasta un cierre válido.
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
        _expresion();
        break;

      case TipoToken.turn:
        _avanzar();
        if (!_coincide(TipoToken.right) &&
            !_coincide(TipoToken.left)) {
          throw ErrorSintactico(
            mensaje: 'Después de "turn" se esperaba "right" o "left".',
            linea: _actual.linea,
            columna: _actual.columna,
          );
        }
        _avanzar();
        break;

      case TipoToken.stop:
        _avanzar();
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
    _esperar(
      TipoToken.identificador,
      'Se esperaba el nombre de la variable.',
    );

    _esperar(
      TipoToken.asignacion,
      'Se esperaba "=" después del nombre de la variable.',
    );

    _expresion();
  }

  void _ciclo() {
    _esperar(
      TipoToken.repeat,
      'Se esperaba "repeat".',
    );

    _expresion();

    _esperar(
      TipoToken.llaveIzquierda,
      'Se esperaba "{" para iniciar el bloque del ciclo.',
    );

    _listaInstrucciones({
      TipoToken.llaveDerecha,
    });

    _esperar(
      TipoToken.llaveDerecha,
      'Se esperaba "}" para cerrar el ciclo.',
    );
  }

  void _condicional() {
    _esperar(
      TipoToken.ifToken,
      'Se esperaba "if".',
    );

    _condicion();

    _esperar(
      TipoToken.then,
      'Se esperaba "then" después de la condición.',
    );

    _listaInstrucciones({
      TipoToken.elseToken,
      TipoToken.end,
    });

    if (_coincide(TipoToken.elseToken)) {
      _avanzar();

      _listaInstrucciones({
        TipoToken.end,
      });
    }

    _esperar(
      TipoToken.end,
      'Se esperaba "end" para cerrar la condición.',
    );
  }

  void _retorno() {
    _esperar(
      TipoToken.returnToken,
      'Se esperaba "return".',
    );

    _esperar(
      TipoToken.identificador,
      'Se esperaba el nombre de la base después de "return".',
    );
  }

  void _condicion() {
    _expresion();

    if (!_esOperadorComparacion(_actual.tipo)) {
      throw ErrorSintactico(
        mensaje: 'Se esperaba un operador de comparación: <, >, <=, >=, == o !=.',
        linea: _actual.linea,
        columna: _actual.columna,
      );
    }

    _avanzar();
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

  /// expresion = termino { ("+" | "-") termino }
  void _expresion() {
    _termino();

    while (_coincide(TipoToken.suma) ||
        _coincide(TipoToken.resta)) {
      _avanzar();
      _termino();
    }
  }

  /// termino = factor { ("*" | "/") factor }
  void _termino() {
    _factor();

    while (_coincide(TipoToken.multiplicacion) ||
        _coincide(TipoToken.division)) {
      _avanzar();
      _factor();
    }
  }

  /// factor = NUMERO | IDENTIFICADOR | "(" expresion ")"
  void _factor() {
    if (_coincide(TipoToken.numero) ||
        _coincide(TipoToken.identificador)) {
      _avanzar();
      return;
    }

    if (_coincide(TipoToken.parentesisIzquierdo)) {
      _avanzar();
      _expresion();

      _esperar(
        TipoToken.parentesisDerecho,
        'Se esperaba ")" para cerrar la expresión.',
      );

      return;
    }

    throw ErrorSintactico(
      mensaje: 'Se esperaba un número, un identificador o "(".',
      linea: _actual.linea,
      columna: _actual.columna,
    );
  }
}
