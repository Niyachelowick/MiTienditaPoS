import 'package:flutter/material.dart';
import 'package:punto_de_venta/core/app_colors.dart';

class Botones {
  static ButtonStyle normalButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppColors.componenColor),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        //side: BorderSide(color: AppColors.borderColor),
      ),
    ),
  );
  static ButtonStyle secondaryButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(const Color.fromARGB(167, 49, 156, 198),),
    shadowColor: WidgetStateProperty.all(Color.fromRGBO(0, 0, 0, 128)),
    elevation: WidgetStateProperty.all(30),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        //side: BorderSide(color: AppColors.borderColor),
      ),
    ),
  );
}