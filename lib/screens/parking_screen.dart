import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  final StreamController<int> _availableSpacesController = StreamController<int>();
  final StreamController<int> _occupiedSpacesController = StreamController<int>();
  late int _totalSpaces;
  late int _availableSpaces;
  late int _occupiedSpaces;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Generar número aleatorio de espacios totales (50-100)
    _totalSpaces = Random().nextInt(51) + 50; // 50 to 100
    _availableSpaces = _totalSpaces;
    _occupiedSpaces = 0;
    _availableSpacesController.add(_availableSpaces);
    _occupiedSpacesController.add(_occupiedSpaces);

    // Simular flujo normal: actualizar cada 1-3 segundos
    _timer = Timer.periodic(Duration(seconds: Random().nextInt(3) + 1), (timer) {
      // Randomly decide to occupy or free a space
      bool occupy = Random().nextBool(); // 50% chance to occupy or free
      if (occupy && _availableSpaces > 0) {
        // Occupy a space
        _availableSpaces--;
        _occupiedSpaces++;
      } else if (!occupy && _occupiedSpaces > 0) {
        // Free a space
        _availableSpaces++;
        _occupiedSpaces--;
      }
      // If no action possible, do nothing
      _availableSpacesController.add(_availableSpaces);
      _occupiedSpacesController.add(_occupiedSpaces);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _availableSpacesController.close();
    _occupiedSpacesController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contador de Espacios de Estacionamiento'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Espacios Totales: $_totalSpaces',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            StreamBuilder<int>(
              stream: _availableSpacesController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'Espacios Disponibles: ${snapshot.data}',
                    style: TextStyle(fontSize: 24, color: snapshot.data! > 0 ? Colors.green : Colors.red),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 20),
            StreamBuilder<int>(
              stream: _occupiedSpacesController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'Espacios Ocupados: ${snapshot.data}',
                    style: TextStyle(fontSize: 24, color: snapshot.data! > 0 ? Colors.red : Colors.green),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
