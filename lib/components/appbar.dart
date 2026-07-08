
import 'package:flutter/material.dart';
import 'package:punto_de_venta/core/app_colors.dart';

AppBar presetAppBar(String titulo) {
    return AppBar(
      title: Text(titulo,style: TextStyle(fontWeight:FontWeight.bold,fontSize: 30),),
      backgroundColor: AppColors.appBarColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // side: BorderSide(
        //   width:1,
        //   color: AppColors.borderColor
        // )
      ),
    );
  }

