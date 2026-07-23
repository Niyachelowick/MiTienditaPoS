import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:punto_de_venta/Backend/database_helper.dart';
import 'package:punto_de_venta/components/appbar.dart';
import 'package:punto_de_venta/core/app_colors.dart';
import 'package:punto_de_venta/core/estilos_texto.dart';

class DetalleVenta extends StatefulWidget {
  final int idVenta;
  final String date, time;
  const DetalleVenta({
    super.key,
    required this.idVenta,
    required this.date,
    required this.time,
  });

  @override
  State<DetalleVenta> createState() => _DetalleVentaState();
}

class _DetalleVentaState extends State<DetalleVenta> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> detalle = [];
  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final genericDetail = await dbHelper.getDetalleVentas2(widget.idVenta);
    for (var p in genericDetail) {
      final prod = await dbHelper.getProductoPorID(p['id_producto']);
      Map<String, dynamic> repo = prod.first;
      setState(() {
        detalle.add({
          'producto': repo['nombre'],
          'precio': repo['precio'],
          'cantidad': p['cantidad'],
          'sub': p['subtotal'],
        });
      });
    }
    setState(() {});
    if (kDebugMode) {
      print(genericDetail);
      print(widget.idVenta);
      print(detalle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: presetAppBar("Detalle de la venta"),
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              bottom: 0,
              left: 16,
              right: 16,
            ),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.componenColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.date, style: EstilosTexto.headingDateTime),
                  Text(" ", style: EstilosTexto.headingDateTime),
                  Text(widget.time, style: EstilosTexto.headingDateTime),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.componenColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DataTable(
                    columnSpacing: 30,
                    headingTextStyle: EstilosTexto.headingTables,
                    dataTextStyle: EstilosTexto.bodyText,
                    columns: [
                      DataColumn(label: Text("Prod.")),
                      DataColumn(label: Text("Precio")),
                      DataColumn(label: Text("Cantidad")),
                      DataColumn(label: Text("Subtotal")),
                    ],
                    rows: detalle.map((p) {
                      return DataRow(
                        cells: [
                          DataCell(Text(p['producto'])),
                          DataCell(Text(p['precio'].toStringAsFixed(2))),
                          DataCell(Text(p['cantidad'].toStringAsFixed(3))),
                          DataCell(Text("\$${p['sub']}")),
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
