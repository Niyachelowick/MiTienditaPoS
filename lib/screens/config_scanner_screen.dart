import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:punto_de_venta/components/appbar.dart';
import 'package:punto_de_venta/core/app_colors.dart';
import 'package:punto_de_venta/core/estilos_texto.dart';

class ConfigScannerScreen extends StatefulWidget {
  const ConfigScannerScreen({super.key});

  @override
  State<ConfigScannerScreen> createState() => _ConfigScannerScreenState();
}

class _ConfigScannerScreenState extends State<ConfigScannerScreen> {
  bool isScanning = false;
  Map<String, dynamic>? repo;
  String? isConected;

  @override
  void initState() {
    super.initState();
    service.on('isConnected').listen((event) {
      Map<String, dynamic>? conChecker = event;
      if (conChecker?['conState']) {
        setState(() {
          isConected = 'Conectado';
        });
      } else {
        setState(() {
          isConected = 'Desconectado';
        });
      }
    });
  }

  final service = FlutterBackgroundService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: presetAppBar("Configuración"),
      backgroundColor: AppColors.bgColor,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Usar Escáner Bluetooth",
                  style: EstilosTexto.headingTables,
                ),
                Switch(
                  activeThumbColor: AppColors.borderColor,
                  value: isScanning,
                  onChanged: (awa) {
                    setState(() {
                      isScanning = awa;
                    });
                    if (awa) {
                      service.invoke('scanStart');
                      service.on('update').listen((event) {
                        setState(() {
                          repo = event;
                        });
                        if (kDebugMode) {
                          print(repo);
                        }
                      });
                    } else {
                      service.invoke('scanStop');
                      setState(() {
                        repo = null;
                      });
                    }
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsGeometry.only(left: 16, right: 16),
              child: Text(
                isConected ?? 'Desconectado',
                style: EstilosTexto.bodyText,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.componenColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DataTable(
                  headingTextStyle: EstilosTexto.headingTables,
                  dataTextStyle: EstilosTexto.tableText,
                  columns: [
                    DataColumn(label: Text("Nombre")),
                    DataColumn(label: Text("RSSI")),
                  ],
                  rows: [
                    DataRow(
                      onLongPress: () {
                        service.invoke('scanStop');
                        service.invoke('connectTo', {'mac': repo?['id']});
                      },
                      cells: [
                        DataCell(Text(repo?['name'] ?? 'noName')),
                        DataCell(Text(repo?['rssi'].toString() ?? 'nada')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
