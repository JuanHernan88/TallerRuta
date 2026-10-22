
import 'token.dart';
import 'errores.dart';

/// Analizador léxico del lenguaje Ruta.
class Lexer {
  final String codigo;

  int _posicion = 0;
  int _linea = 1;
  int _columna = 1;

  Lexer(this.codigo);

  static const Map<String, TipoToken> _palabrasReservadas = {
    'robot': TipoToken.robot,
    'forward': TipoToken.forward,
    'turn': TipoToken.turn,
    'stop': TipoToken.stop,
    'right': TipoToken.right,
    'left': TipoToken.left,
    'repeat': TipoToken.repeat,
    'if': TipoToken.ifToken,
    'then': TipoToken.then,
    'else': TipoToken.elseToken,
    'end': TipoToken.end,
    'return': TipoToken.returnToken,
  };

  List<Token> analizar() {
    final tokens = <Token>[];

    while (!_terminado) {
      final caracter = _actual;

      if (_esEspacio(caracter)) {
        _avanzar();
        continue;
      }

      if (caracter == '\n') {
        _avanzar();
        continue;
      }

      // Los comentarios comienzan con // y terminan al final de la línea.
      if (caracter == '/' && _mirar(1) == '/') {
        _saltarComentario();
        continue;
      }

      final lineaInicial = _linea;
      final columnaInicial = _columna;

      if (_esLetra(caracter) || caracter == '_') {
        tokens.add(
          _leerIdentificador(lineaInicial, columnaInicial),
        );
        continue;
      }

      if (_esDigito(caracter)) {
        tokens.add(_leerNumero(lineaInicial, columnaInicial));
        continue;
      }

      final token = _leerOperadorOSimbolo(
        lineaInicial,
        columnaInicial,
      );

      if (token == null) {
        throw ErrorLexico(
          mensaje: "Carácter no reconocido '$caracter'.",
          linea: lineaInicial,
          columna: columnaInicial,
        );
      }

      tokens.add(token);
    }

    tokens.add(
      Token(
        tipo: TipoToken.finArchivo,
        lexema: '',
        linea: _linea,
        columna: _columna,
      ),
    );

    return tokens;
  }

  bool get _terminado => _posicion >= codigo.length;

  String get _actual => _terminado ? '' : codigo[_posicion];

  String _mirar(int desplazamiento) {
    final posicion = _posicion + desplazamiento;

    if (posicion >= codigo.length) {
      return '';
    }

    return codigo[posicion];
  }

  void _avanzar() {
    if (_terminado) return;

    if (codigo[_posicion] == '\n') {
      _linea++;
      _columna = 1;
    } else {
      _columna++;
    }

    _posicion++;
  }

  bool _esEspacio(String caracter) {
    return caracter == ' ' ||
        caracter == '\t' ||
        caracter == '\r';
  }

  bool _esLetra(String caracter) {
    if (caracter.isEmpty) return false;

    final codigoAscii = caracter.codeUnitAt(0);

    return (codigoAscii >= 65 && codigoAscii <= 90) ||
        (codigoAscii >= 97 && codigoAscii <= 122);
  }

  bool _esDigito(String caracter) {
    if (caracter.isEmpty) return false;

    final codigoAscii = caracter.codeUnitAt(0);

    return codigoAscii >= 48 && codigoAscii <= 57;
  }

  Token _leerIdentificador(int linea, int columna) {
    final inicio = _posicion;

    while (!_terminado &&
        (_esLetra(_actual) ||
            _esDigito(_actual) ||
            _actual == '_')) {
      _avanzar();
    }

    final lexema = codigo.substring(inicio, _posicion);

    return Token(
      tipo: _palabrasReservadas[lexema] ??
          TipoToken.identificador,
      lexema: lexema,
      linea: linea,
      columna: columna,
    );
  }

  Token _leerNumero(int linea, int columna) {
    final inicio = _posicion;

    while (!_terminado && _esDigito(_actual)) {
      _avanzar();
    }

    // Permite números decimales, por ejemplo 3.14.
    if (!_terminado &&
        _actual == '.' &&
        _esDigito(_mirar(1))) {
      _avanzar();

      while (!_terminado && _esDigito(_actual)) {
        _avanzar();
      }
    }

    return Token(
      tipo: TipoToken.numero,
      lexema: codigo.substring(inicio, _posicion),
      linea: linea,
      columna: columna,
    );
  }

  Token? _leerOperadorOSimbolo(int linea, int columna) {
    final caracter = _actual;
    final siguiente = _mirar(1);

    // Operadores de dos caracteres.
    if (caracter == '<' && siguiente == '=') {
      _avanzar();
      _avanzar();
      return _crearToken(TipoToken.menorIgual, '<=', linea, columna);
    }

    if (caracter == '>' && siguiente == '=') {
      _avanzar();
      _avanzar();
      return _crearToken(TipoToken.mayorIgual, '>=', linea, columna);
    }

    if (caracter == '=' && siguiente == '=') {
      _avanzar();
      _avanzar();
      return _crearToken(TipoToken.igualdad, '==', linea, columna);
    }

    if (caracter == '!' && siguiente == '=') {
      _avanzar();
      _avanzar();
      return _crearToken(TipoToken.diferente, '!=', linea, columna);
    }

    // Operadores y símbolos de un carácter.
    final TipoToken? tipo;

    switch (caracter) {
      case '=':
        tipo = TipoToken.asignacion;
        break;
      case '+':
        tipo = TipoToken.suma;
        break;
      case '-':
        tipo = TipoToken.resta;
        break;
      case '*':
        tipo = TipoToken.multiplicacion;
        break;
      case '/':
        tipo = TipoToken.division;
        break;
      case '<':
        tipo = TipoToken.menor;
        break;
      case '>':
        tipo = TipoToken.mayor;
        break;
      case '(':
        tipo = TipoToken.parentesisIzquierdo;
        break;
      case ')':
        tipo = TipoToken.parentesisDerecho;
        break;
      case '{':
        tipo = TipoToken.llaveIzquierda;
        break;
      case '}':
        tipo = TipoToken.llaveDerecha;
        break;
      default:
        return null;
    }

    _avanzar();

    return _crearToken(tipo, caracter, linea, columna);
  }

  Token _crearToken(
    TipoToken tipo,
    String lexema,
    int linea,
    int columna,
  ) {
    return Token(
      tipo: tipo,
      lexema: lexema,
      linea: linea,
      columna: columna,
    );
  }

  void _saltarComentario() {
    while (!_terminado && _actual != '\n') {
      _avanzar();
    }
  }
}
