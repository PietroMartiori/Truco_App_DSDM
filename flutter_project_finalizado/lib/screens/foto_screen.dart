import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class FotoScreen extends StatefulWidget {
  final String titulo;
  const FotoScreen({super.key, required this.titulo});

  @override
  State<FotoScreen> createState() => _FotoScreenState();
}

class _FotoScreenState extends State<FotoScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _tirarFoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _image = photo);
    }
  }

  @override
  void initState() {
    super.initState();
    // Inicia a câmera automaticamente ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) => _tirarFoto());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.titulo, style: const TextStyle(fontSize: 14)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_image != null)
            Positioned.fill(
              child: Image.file(File(_image!.path), fit: BoxFit.cover),
            )
          else
            const Center(
              child: Icon(Icons.camera_alt, color: AppColors.textMuted, size: 64),
            ),
          
          // Moldura de foco (simulada)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neonGreen.withOpacity(0.5), width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Controles inferiores
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
                GestureDetector(
                  onTap: _tirarFoto,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_image != null) {
                      Navigator.pop(context, _image!.path);
                    }
                  },
                  icon: const Icon(Icons.check, color: AppColors.neonGreen, size: 35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
