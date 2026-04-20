import 'package:flutter/material.dart';
import 'screens/product_page.dart';

void main() => runApp(const PaymentApp());

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'payment app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const ProductPage(),
    );
  }
}