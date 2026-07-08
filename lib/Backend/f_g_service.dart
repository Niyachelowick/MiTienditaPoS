import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:punto_de_venta/Backend/database_helper.dart';
// import 'package:punto_de_venta/Backend/ble_service.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart, // la función que se ejecuta en segundo plano
      isForegroundMode: true, // corre como foreground service en Android
      autoStart: true,
      autoStartOnBoot: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: (service) {},
      onBackground: (service) {
        return false;
      },
    ),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  final ble = FlutterReactiveBle();
  // bool isConnected = false;
  //  bool shouldReconnect=true;
  String? deviceMac;
  Uuid serviceUUID = Uuid.parse("7509cd08-fa63-49d3-8c6c-94c47731ed42");
  Uuid bleTransCodeChar = Uuid.parse("62c1b5ea-b5eb-4d66-93d8-1d0945f2864c");
  QualifiedCharacteristic? characteristic;
  StreamSubscription<DiscoveredDevice>? scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? connectionSub;
  StreamSubscription<List<int>>? response;

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }

  // PRUEBA TEMPORAL: Metemos esto dentro del listen del BLE antes de la query

  service.on("scanStart").listen((event) {
    // Aquí recibimos eventos enviados desde la UI
    scanSubscription = ble
        .scanForDevices(
          withServices: [serviceUUID],
          scanMode: ScanMode.lowLatency,
        )
        .listen((device) {
          if (kDebugMode) {
            //  print(device);
          }
          service.invoke('update', {
            'name': device.name,
            'id': device.id,
            'rssi': device.rssi,
          });
        });
  });
  service.on('scanStop').listen((event) {
    //   shouldReconnect = false;
    scanSubscription?.cancel();
    connectionSub?.cancel();
    scanSubscription = null;
  });
  service.on('connectTo').listen((id) {
    deviceMac = id?['mac']?.toString();
    if (deviceMac == null) {
      return;
    }
    if (kDebugMode) {
      print("intentando conectar a $deviceMac");
    }
    connectionSub?.cancel();
    response?.cancel();
    connectionSub = ble
        .connectToDevice(
          id: id?['mac'].toString() ?? '',
          servicesWithCharacteristicsToDiscover: {
            serviceUUID: [bleTransCodeChar],
          },
          connectionTimeout: const Duration(seconds: 5),
        )
        .listen(
          (conState) {
            if (kDebugMode) {
              print("Estado de conexión: ${conState.connectionState}");
            }
            if (conState.connectionState == DeviceConnectionState.connected) {
              characteristic = QualifiedCharacteristic(
                serviceId: serviceUUID,
                characteristicId: bleTransCodeChar,
                deviceId: deviceMac ?? 'D8:BC:38:E3:6D:DE',
              );
              // isConnected = true;
              response = ble
                  .subscribeToCharacteristic(characteristic!)
                  .listen(
                    (List<int> data) async {
                      String codigoCrudo = utf8.decode(data);
                      String codigoLimpio = codigoCrudo
                          .replaceAll('\x00', '')
                          .trim();
                      if (codigoCrudo.isNotEmpty) {
                        //Aquí van los métodos del DBhelper para consultar y sumar precios.
                        final dbHelper = DatabaseHelper();
                        final todos = await dbHelper.getProductos();
                        print(
                          "Contenido total de la tabla productos en background: $todos",
                        );

                        final producto = await dbHelper.getProductoPorCodigo(
                          codigoLimpio,
                        );
                        if (kDebugMode) {
                          print(codigoLimpio);
                          print(producto);
                        }
                      }
                    },
                    onError: (Object error) {
                      if (kDebugMode) {
                        print("error en el flujo de datos $error");
                      }
                    },
                  );
            } else if (conState.connectionState ==
                DeviceConnectionState.disconnected) {
              // isConnected = false;
            }
          },
          onError: (dynamic error) {
            if (kDebugMode) {
              print("Error BLE: $error");
            }
          },
        );
  });

  // Ejemplo: loop periódico
  // Timer.periodic(const Duration(seconds: 5), (timer) async {
  //   // service.invoke("update", {
  //   //   "timestamp": DateTime.now().toIso8601String(),
  //   // });
  //   if (isConnected) {
  //     final response = await ble.readCharacteristic(characteristic!);

  //     print("Recibido: ${utf8.decode(response)}");
  //   }

  //   if (kDebugMode) {
  //     print("Hello there");
  //   }
  // });
}
