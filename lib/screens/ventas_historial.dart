// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:punto_de_venta/Backend/database_helper.dart';
import 'package:punto_de_venta/components/appbar.dart';
import 'package:punto_de_venta/core/app_colors.dart';
import 'package:punto_de_venta/core/estilos_texto.dart';
import 'package:punto_de_venta/screens/detalle_venta.dart';

class VentasHistorial extends StatefulWidget {
  const VentasHistorial({super.key});

  @override
  State<VentasHistorial> createState() => _VentasHistorialState();
}

class _VentasHistorialState extends State<VentasHistorial> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> ventas = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final data = await dbHelper.getVentas();
    setState(() {
      ventas = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: presetAppBar("Historial de ventas"),
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.componenColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DataTable(
                    headingTextStyle: EstilosTexto.headingTables,
                    dataTextStyle: EstilosTexto.tableText,
                    columnSpacing: 35,
                    columns: const [
                      DataColumn(label: Text("id")),
                      DataColumn(label: Text("Fecha")),
                      DataColumn(label: Text("Hora")),
                      DataColumn(numeric: true, label: Text("Total")),
                    ],
                    rows: ventas.map((p) {
                      return DataRow(
                        onLongPress: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleVenta(
                                idVenta: p['id'],
                                date: p['fecha'].toString(),
                                time:p['hora'],
                              ),
                            ),
                          );
                        },
                        cells: [
                          DataCell(Text(p['id'].toString())),
                          DataCell(Text(p['fecha'].toString())),
                          DataCell(Text(p['hora'].toString())),
                          DataCell(Text("\$${p['total'].toStringAsFixed(2)}")),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
