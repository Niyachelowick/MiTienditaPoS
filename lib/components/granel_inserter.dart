import 'package:flutter/material.dart';
import 'package:punto_de_venta/Backend/database_helper.dart';
import 'package:punto_de_venta/components/botones.dart';
import 'package:punto_de_venta/core/app_colors.dart';
import 'package:punto_de_venta/core/estilos_texto.dart';

class GranelInserter extends StatefulWidget {
  final Function(double quantity,String code) onAgregar;
  const GranelInserter({super.key, required this.onAgregar});

  @override
  State<GranelInserter> createState() => _GranelInserterState();
}

class _GranelInserterState extends State<GranelInserter> {
  final cantidadCrtl = TextEditingController();
  final dbHelper = DatabaseHelper();
  static const double changeQuantityBy = 1 / 8;
  double currentQuantity = 0;
  String? dropdownValue;
  List<DropdownMenuItem<String>> prods = [];
  double monto=0;
  
  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    final listaObtenida = await dbHelper.getGranelProducts();
    setState(() {
      for (var iter in listaObtenida) {
        prods.add(
          DropdownMenuItem(
            value: iter['nombre'].toString(),
            child: Text(iter['nombre'].toString()),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.componenColor,
        borderRadius: BorderRadius.circular(16),
      ),
      width: 360,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                backgroundColor: AppColors.componenSelectedColor,
                heroTag: null,
                shape: CircleBorder(),
                onPressed: () {
                  currentQuantity -= changeQuantityBy;
                  if (currentQuantity < 0) currentQuantity = 0;
                  cantidadCrtl.text = currentQuantity.toString();
                },
                child: Icon(Icons.remove, color: Colors.white),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  onChanged: (campoDeCant){
                    if(campoDeCant.startsWith('.')){
                      campoDeCant="0$campoDeCant";
                      cantidadCrtl.text=campoDeCant;
                    }
                    if(campoDeCant.isNotEmpty){
                      currentQuantity=double.parse(campoDeCant);
                    }
                  },
                  textAlign: TextAlign.center,
                  controller: cantidadCrtl,
                  style: EstilosTexto.bodyText,
                  keyboardType: TextInputType.number,
                  cursorColor: AppColors.borderColor,
                  decoration: InputDecoration(
                    hintText: "Cantidad",
                    hintStyle: TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: const Color.fromARGB(192, 19, 85, 124),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.borderColor,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
              FloatingActionButton(
                heroTag: null,
                foregroundColor: Colors.white,
                backgroundColor:AppColors.componenSelectedColor,
                shape: CircleBorder(),
                onPressed: () {
                  currentQuantity += changeQuantityBy;
                  cantidadCrtl.text = currentQuantity.toString();
                },
                child: Icon(Icons.add),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Producto por peso:", style: EstilosTexto.headingTables,),
              DropdownButton(
                dropdownColor: AppColors.bgColor,
                style: EstilosTexto.headingTables,
                hint: Text("Seleccionar Prod.",style: EstilosTexto.headingTables),
                value: dropdownValue,
                items: prods,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              
              widget.onAgregar(currentQuantity,dropdownValue??"");
            },
            style: Botones.secondaryButton,
            child: Text(
              "Añadir Producto a granel",
              style: EstilosTexto.headingTables,
            ),
          ),
        ],
      ),
    );
  }
}
