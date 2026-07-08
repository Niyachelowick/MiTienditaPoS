import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:punto_de_venta/core/app_colors.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String? barcode;
  bool isScanned = false; // 🔒 candado para evitar múltiples pops

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
            Navigator.pop(context, barcode); // devuelve el código leído si hay
          },
        ),
      ),
      body: Stack(
        children: [
          /// 📷 Vista de la cámara
          MobileScanner(
            onDetect: (capture) {
              if (isScanned) return; // ya devolvió, ignorar más lecturas
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                setState(() {
                  this.barcode = barcode.rawValue ?? "Código no válido";
                  isScanned = true;
                });

                // 👉 Si quieres cerrar automáticamente al leer
                Navigator.pop(context, this.barcode);
              }
            },
          ),

          /// 🟦 Overlay para marco de escaneo
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Color.fromRGBO(34, 70, 70, 0.24),
                border: Border.all(color: AppColors.borderColor, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          /// 🔤 Texto con el resultado
          if (barcode != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Código: $barcode",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
