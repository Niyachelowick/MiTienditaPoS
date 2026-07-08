import 'dart:async';

//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:punto_de_venta/Backend/f_g_service.dart';
import 'package:punto_de_venta/screens/main_page.dart';


Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MainApp());
}


class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:MainPage());
  }
}

