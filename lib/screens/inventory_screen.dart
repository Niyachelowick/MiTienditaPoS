// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:punto_de_venta/components/appbar.dart';
import 'package:punto_de_venta/components/botones.dart';
import 'package:punto_de_venta/core/app_colors.dart';
import 'package:punto_de_venta/core/estilos_texto.dart';
import 'package:punto_de_venta/Backend/database_helper.dart';
import 'package:punto_de_venta/screens/scan_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventarioPageState();
}

class _InventarioPageState extends State<InventoryScreen> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> productos = [];
  
  final codigoCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();
  final precioCtrl = TextEditingController();
  ScrollController subirPantalla = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String prodType = "Unidad";
  bool isGranel = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.addListener(() async {
        if (_focusNode.hasFocus) {
          await Future.delayed(const Duration(milliseconds: 1000));
          subirPantalla.animateTo(
            subirPantalla.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
      // _focusNode.requestFocus();
    });
  }

  Future<void> _cargarProductos() async {
    final data = await dbHelper.getProductos();
    setState(() {
      productos = data;
    });
  }

  Future<void> _agregarProducto() async {
    final result = await dbHelper.getProductoPorCodigo(codigoCtrl.text);
    String tipo = 'unidad';
    if (isGranel) {
        tipo = 'peso';
    }

    if (result.isNotEmpty) {
      if (precioCtrl.text == '---') {
        dbHelper.descontinuarProducto({'codigo': codigoCtrl.text});
        codigoCtrl.clear();
        nombreCtrl.clear();
        cantidadCtrl.clear();
        precioCtrl.clear();
        isGranel = false;
        _cargarProductos();
        return;
      }
      
      if (codigoCtrl.text.isEmpty) {
        dbHelper.actualizarProductoPorNombre({
          'nombre': nombreCtrl.text,
          'cantidad': double.tryParse(cantidadCtrl.text),
          'precio': double.tryParse(precioCtrl.text),
          'tipo_venta': tipo,
        });
      } else {
        dbHelper.actualizarProducto({
          'codigo': codigoCtrl.text,
          'nombre': nombreCtrl.text,
          'cantidad': double.tryParse(cantidadCtrl.text),
          'precio': double.tryParse(precioCtrl.text),
          'tipo_venta': tipo,
        });
      }
    } else if (nombreCtrl.text.isEmpty ||
        cantidadCtrl.text.isEmpty ||
        precioCtrl.text.isEmpty) {
      return;
    } else {
      if (codigoCtrl.text.isEmpty) {
        await dbHelper.insertProducto({
          'codigo':nombreCtrl.text,
          'nombre': nombreCtrl.text,
          'cantidad': double.tryParse(cantidadCtrl.text) ?? 0,
          'precio': double.tryParse(precioCtrl.text) ?? 0.0,
          'tipo_venta': tipo,
        });
      } else {
        await dbHelper.insertProducto({
          'codigo': codigoCtrl.text,
          'nombre': nombreCtrl.text,
          'cantidad': double.tryParse(cantidadCtrl.text) ?? 0,
          'precio': double.tryParse(precioCtrl.text) ?? 0.0,
          'tipo_venta': tipo,
        });
      }
    }

    codigoCtrl.clear();
    nombreCtrl.clear();
    cantidadCtrl.clear();
    precioCtrl.clear();
    isGranel = false;
    prodType="Unidad";
    _cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: presetAppBar("Inventario 📦"),
      backgroundColor: AppColors.bgColor,
      body: ListView.builder(
        controller: subirPantalla,
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Tabla
              Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 8,
                  left: 8,
                  right: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.componenColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 300,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingTextStyle: EstilosTexto.headingTables,
                      dataTextStyle: EstilosTexto.tableText,
                      columnSpacing: 30,
                      columns: const [
                        DataColumn(label: Text("Código")),
                        DataColumn(label: Text("Producto")),
                        DataColumn(label: Text("Cant.")),
                        DataColumn(label: Text("Precio")),
                      ],
                      rows: productos.map((p) {
                        return DataRow(
                          onLongPress: () {
                            codigoCtrl.text = "${p['codigo']}";
                            nombreCtrl.text = "${p['nombre']}";
                            cantidadCtrl.text = "${p['cantidad']}";
                            precioCtrl.text = "${p['precio']}";
                            if(p['tipo_venta']=='peso') {
                              setState(() {
                                isGranel=true;
                                prodType='Granel';
                              });
                            }else{
                              setState(() {
                                isGranel=false;
                                prodType='Unidad';
                              });
                            }
                          
                          },
                          cells: [
                            DataCell(Text(p['codigo'].toString())),
                            DataCell(Text(p['nombre'].toString())),
                            if (p['tipo_venta'] == 'unidad')
                              DataCell(Text(p['cantidad'].toStringAsFixed(0)))
                            else
                              DataCell(Text(p['cantidad'].toString())),
                            DataCell(Text("\$${p['precio']}")),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              //const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                //Campo para el codigo de barras con su botón para escanear
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        height: 60,
                        child: ElevatedButton(
                          style: Botones.normalButton,
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScanScreen(),
                              ),
                            );
                            if (result != null) {
                              codigoCtrl.text = result.toString();
                            }
                          },
                          child: Text(
                            "Escanear con cámara",
                            style: EstilosTexto.headingTables,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: cajaDeTexto(
                        tipoEntrada: TextInputType.number,
                        label: "Código",
                        controlador: codigoCtrl,
                      ),
                    ),
                  ],
                ),
              ),
              //Campos para el Nombre, la cantidad y el Precio
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: cajaDeTexto(
                        controlador: nombreCtrl,
                        label: "Nombre",
                        autoScroller: _focusNode,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: cajaDeTexto(
                        tipoEntrada: TextInputType.number,
                        controlador: cantidadCtrl,
                        label: "Cantidad",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: cajaDeTexto(
                        controlador: precioCtrl,
                        label: "Precio",
                        tipoEntrada: TextInputType.number,
                      ),
                    ),
                    //const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Switch(
                          activeThumbColor: AppColors.borderColor,
                          value: isGranel,
                          onChanged: (checker) {
                            setState(() {
                              isGranel = checker;
                              if (isGranel) {
                                prodType = " Granel";
                              } else {
                                prodType = "Unidad";
                              }
                            });
                          },
                        ),
                        Text(
                          "Tipo de producto:$prodType",
                          style: EstilosTexto.headingTables,
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: Botones.normalButton,
                      onPressed: _agregarProducto,
                      child: const Text(
                        "Agregar/Actualizar Producto",
                        style: EstilosTexto.headingTables,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        itemCount: 1,
      ),
    );
  }

  TextField cajaDeTexto({
    required String? label,
    required TextEditingController controlador,
    FocusNode? autoScroller,
    TextInputType? tipoEntrada,
  }) {
    return TextField(
      keyboardType: tipoEntrada,
      focusNode: autoScroller,
      style: EstilosTexto.bodyText,
      cursorColor: AppColors.borderColor,
      controller: controlador,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: EstilosTexto.floatingLabels,
        filled: true,
        fillColor: AppColors.componenColor,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor, width: 3),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
      ),
    );
  }
}
