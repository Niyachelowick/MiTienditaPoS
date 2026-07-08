import 'package:flutter/material.dart';
import 'package:punto_de_venta/components/appbar.dart';
import 'package:punto_de_venta/components/botones.dart';
import 'package:punto_de_venta/core/app_colors.dart';
import 'package:punto_de_venta/core/estilos_texto.dart';
import 'package:punto_de_venta/screens/config_scanner_screen.dart';
import 'package:punto_de_venta/screens/inventory_screen.dart';
import 'package:punto_de_venta/screens/selling_screen.dart';
import 'package:punto_de_venta/screens/ventas_historial.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: presetAppBar("MobilPoS"),
      backgroundColor: AppColors.bgColor,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 8,
                  left: 16,
                  right: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    //bot'on para el inventario
                    style: Botones.normalButton,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InventoryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Inventario 📦",
                      style: EstilosTexto.bigButtonText,
                    ),
                  ),
                ),
              ),
            ),
            //Divider(color: AppColors.bgColor,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  bottom: 8,
                  left: 16,
                  right: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    //bot'on para las ventas
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellingScreen(),
                        ),
                      );
                    },
                    style: Botones.normalButton,
                    child: Text("Venta 💸", style: EstilosTexto.bigButtonText),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                  left: 16,
                  right: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      //Agregar aqu'i el navigator hacia la pantalla del historial
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VentasHistorial(),
                        ),
                      );
                    },
                    style: Botones.normalButton,
                    child: Text(
                      "Historial de Ventas",
                      style: EstilosTexto.bigButtonText,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: Botones.normalButton,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfigScannerScreen(),
                        ),
                      );
                    }, //poner aquí la ventana de configuración del escáner.
                    child: Text(
                      "Config. Escáner",
                      style: EstilosTexto.bigButtonText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
