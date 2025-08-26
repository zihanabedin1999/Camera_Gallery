import 'package:flutter/material.dart';
import 'gallery_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Assets Gallery',
      home: const GalleryScreen(),
    );
  }
}
