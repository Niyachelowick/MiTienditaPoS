import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:punto_de_venta/Backend/database_helper.dart';
import 'package:punto_de_venta/components/botones.dart';
import 'package:punto_de_venta/core/app_colors.dart';
import 'package:punto_de_venta/core/estilos_texto.dart';

class SellingScreenCamCanning extends StatefulWidget {
  const SellingScreenCamCanning({super.key});

  @override
  State<SellingScreenCamCanning> createState() =>
      _SellingScreenCamCanningState();
}

class _SellingScreenCamCanningState extends State<SellingScreenCamCanning> {
  String? barcode;
  bool hasEnded = false;
  final dbHelper = DatabaseHelper();
  double total = 0.0;
  List<Map<String, dynamic>> carrito = [];
  ScrollController tableScroll = ScrollController();
  int lastLength = 0;

  Future<void> _annadirProducto(String codigo) async {
    final producto = carrito.firstWhere(
      (item) => item['codigo'] == codigo,
      orElse: () => {},
    );

    if (producto.isNotEmpty) {
      setState(() {
        producto['cantidad'] += 1;
        producto['subtotal'] = producto['cantidad'] * producto['precio'];
      });
    } else {
      final result = await dbHelper.getProductoPorCodigo(codigo);
      if (result.isNotEmpty) {
        Map<String, dynamic> articuloVendido = {};
        articuloVendido.addAll(result.first);
        articuloVendido['cantidad'] = 1;
        articuloVendido['subtotal'] = articuloVendido['precio'];
        setState(() {
          carrito.add(articuloVendido);
        });
      }
    }
    total = carrito.fold<double>(0, (sum, item) => sum + item['subtotal']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Escanear código"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            //Navigator.pop(context, barcode); // devuelve el código leído si hay
            Navigator.pop(context); // devuelve el código leído si hay
          },
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) async {
              if (hasEnded) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                setState(() {
                  this.barcode = barcode.rawValue ?? "Código no válido";
                  _annadirProducto(barcode.rawValue ?? "Código no válido");
                });
                const duration = Duration(milliseconds: 1000);
                sleep(duration);
                if (lastLength < carrito.length) {
                  await Future.delayed(const Duration(milliseconds: 700));
                  setState(() {
                    tableScroll.animateTo(
                      tableScroll.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  });
                }
                lastLength = carrito.length;
              }
            },
          ),

          Align(
            alignment: AlignmentGeometry.bottomCenter,
            child: SizedBox(
              height: 558, //esto controla que tan alto aparecen los componentes
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      height: 200,
                      width: 375,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(68, 49, 156, 198),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 380,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.componenColor,
                    ),
                    child: Center(
                      child: Text(
                        "\$$total",
                        style: EstilosTexto.bigButtonText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, top: 16),
                    child: Container(
                      height: 200,
                      width: 380,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.componenColor,
                      ),
                      child: SingleChildScrollView(
                        controller: tableScroll,
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columnSpacing: 30,
                          headingTextStyle: EstilosTexto.headingTables,
                          dataTextStyle: EstilosTexto.tableText,
                          columns: [
                            DataColumn(label: Text("Nombre")),
                            DataColumn(label: Text("Cantidad")),
                            DataColumn(label: Text("Precio")),
                            DataColumn(label: Text("SubTotal")),
                          ],
                          rows: carrito.map((p) {
                            return DataRow(
                              cells: [
                                DataCell(Text(p['nombre'].toString())),
                                DataCell(Text(p['cantidad'].toString())),
                                DataCell(Text("\$${p['precio']}")),
                                DataCell(Text("\$${p['subtotal']}")),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Map<String, dynamic> passingData = {
                        'carrito': carrito,
                        'total': total,
                      };
                      Navigator.pop(context, passingData);
                    },
                    style: Botones.normalButton,
                    child: Text(
                      'Finalizar escaneo',
                      style: EstilosTexto.headingTables,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
