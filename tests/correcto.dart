// Código generado automáticamente desde el lenguaje Ruta.
// No editar a mano.

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


void main() {
  final robot = Robot('Tito');
  
  num speed = 2;
  num distancia = 10.5;
  num contador = (10 - 3) * 2 + distancia / 5;
  num limite = 30;
  robot.forward(10 * speed + 5);
  robot.forward((distancia + 2) * 3);
  robot.forward(20 / 5 - 1);
  robot.turnRight();
  robot.turnLeft();
  for (var _rutaRepeat0 = 0; _rutaRepeat0 < (4).toInt(); _rutaRepeat0++) {
    robot.forward(speed * 2);
    robot.turnRight();
    contador = contador - 1;
  }
  if (contador < limite) {
    robot.forward(5);
    robot.stop();
  } else {
    robot.forward(1);
    robot.turnLeft();
  }
  if (speed >= 2) {
    speed = speed + 1;
    robot.forward(speed);
  }
  if (speed == 3) {
    robot.stop();
  }
  if (distancia != 0) {
    robot.forward(distancia);
  }
  if (contador <= limite) {
    robot.turnRight();
  }
  if (limite > contador) {
    robot.turnLeft();
  }
  robot.returnTo('base');
}
