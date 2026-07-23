import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:punto_de_venta/Backend/database_helper.dart';
import 'package:punto_de_venta/components/appbar.dart';
import 'package:punto_de_venta/components/botones.dart';
import 'package:punto_de_venta/components/granel_inserter.dart';
import 'package:punto_de_venta/core/app_colors.dart';
import 'package:punto_de_venta/core/estilos_texto.dart';
//import 'package:punto_de_venta/screens/scan_screen.dart';
import 'package:punto_de_venta/screens/selling_screen_cam_canning.dart';
import 'dart:async';

class SellingScreen extends StatefulWidget {
  const SellingScreen({super.key});

  @override
  State<SellingScreen> createState() => _SellingScreenState();
}

class _SellingScreenState extends State<SellingScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> carrito = [];
  double total = 0;
  // int Cantidad=0;
  final service = FlutterBackgroundService();
  final codCtrl = TextEditingController();
  static const double globalWidth = 360;
  StreamSubscription? _carritoSubscription;
  StreamSubscription? _totalSub;

  @override
  void initState() {
    super.initState();
    _carritoSubscription = service.on('getCarrito').listen((event) {
      if (!mounted) return;
      if (event != null && event['cart'] != null) {
        final List<dynamic> rawList = event['cart'];
        setState(() {
          carrito = rawList.map((item) {
            final map = Map<String, dynamic>.from(item);
            if (map['precio'] != null) {
              map['precio'] = (map['precio'] as num).toDouble();
            }
            if (map['cantidad'] != null) {
              map['cantidad'] = (map['cantidad'] as num).toDouble();
            }
            return map;
          }).toList();
        });
      }
    });
    _totalSub = service.on('getTotal').listen((event) {
      if (!mounted) return;
      if (event != null && event['total'] != null) {
        setState(() {
          total = event['total'].toDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    _carritoSubscription?.cancel();
    _totalSub?.cancel();
    super.dispose();
  }

  Future<void> _annadirProductoGranel(String codigo, double cantidad) async {
    final producto = carrito.firstWhere(
      (item) => item['codigo'] == codigo,
      orElse: () => {},
    );

    if (producto.isNotEmpty) {
      setState(() {
        producto['cantidad'] += cantidad;
        producto['subtotal'] = producto['cantidad'] * producto['precio'];
        producto['subtotal'] = double.parse(
          producto['subtotal'].toStringAsFixed(2),
        );
      });
    } else {
      final result = await dbHelper.getProductoPorCodigo(codigo);
      if (result.isNotEmpty) {
        Map<String, dynamic> articuloVendido = {};
        articuloVendido.addAll(result.first);
        articuloVendido['cantidad'] = cantidad;
        articuloVendido['subtotal'] =
            articuloVendido['cantidad'] * articuloVendido['precio'];
        articuloVendido['subtotal'] = double.parse(
          articuloVendido['subtotal'].toStringAsFixed(2),
        );
        setState(() {
          carrito.add(articuloVendido);
        });
      }
    }
    total = carrito.fold<double>(0, (sum, item) => sum + item['subtotal']);
  }

  Future<void> _volcarTodo() async {
    if (kDebugMode) {
      print(carrito);
    }
    final detallesAFull = await dbHelper.getAllDetails();
    await dbHelper.volcarVenta(total, carrito);
    if (kDebugMode) {
      print(detallesAFull);
    }
    final repo = await dbHelper.getVentas();
    //    await Future.delayed(Duration(milliseconds: 2000));
    setState(() {
      carrito.clear();
    });
    if (kDebugMode) {
      print(repo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: presetAppBar("Venta💸"),
      backgroundColor: AppColors.bgColor,
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  height: 250,
                  width: globalWidth,
                  decoration: BoxDecoration(
                    color: AppColors.componenColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                        onLongPress: () {
                          setState(() {
                            carrito.remove(p);
                          });
                        },
                        cells: [
                          DataCell(Text(p['nombre'].toString())),
                          DataCell(
                            onTap: () {
                              setState(() {
                                p['cantidad']++;
                              });
                            },
                            onDoubleTap: () {
                              setState(() {
                                p['cantidad']--;
                              });
                            },
                            Text(p['cantidad'].toString()),
                          ),
                          DataCell(Text("\$${p['precio']}")),
                          DataCell(Text("\$${p['subtotal']}")),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(
                width: globalWidth,
                child: ElevatedButton(
                  style: Botones.normalButton,
                  onPressed: () async {
                    final passeData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellingScreenCamCanning(),
                      ),
                    );
                    if (passeData != null) {
                      setState(() {
                        //carrito = passeData['carrito'];
                        carrito.addAll(passeData['carrito']);
                        total += passeData['total'];
                      });
                      // codCtrl.text = scanCode.toString();
                      // _annadirProducto(codCtrl.text);
                    }
                  },
                  child: Text(
                    "Escanear con cámara",
                    style: EstilosTexto.headingTables,
                  ),
                ),
              ),

              //TextField(controller: codCtrl),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 10),
                child: GranelInserter(
                  onAgregar: (quantity, codificado) {
                    _annadirProductoGranel(codificado, quantity);
                  },
                ),
              ),
              Container(
                height: 50,
                width: globalWidth,
                decoration: BoxDecoration(
                  color: AppColors.componenColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Total: \$$total",
                    style: EstilosTexto.bigButtonText,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _volcarTodo();
                  total = 0.0;
                },
                child: Text("Finalizar Venta"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
