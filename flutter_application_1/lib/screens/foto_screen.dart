import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../widgets/foto_preview.dart';

/// Tela que abre a camera e devolve o caminho da foto para a tela anterior.
class FotoScreen extends StatefulWidget {
  /// Texto que identifica qual foto o usuario esta capturando.
  final String titulo;
  const FotoScreen({super.key, required this.titulo});

  @override
  State<FotoScreen> createState() => _FotoScreenState();
}

/// Estado que guarda a ultima foto capturada para mostrar a pre-visualizacao.
class _FotoScreenState extends State<FotoScreen> {
  /// Arquivo retornado pelo image_picker; nulo antes da primeira captura.
  XFile? _image;

  /// Solicita uma imagem a camera; ao receber, redesenha a tela com a foto.
  Future<void> _tirarFoto() async {
    final foto = await ImagePicker().pickImage(source: ImageSource.camera);
    if (foto != null) setState(() => _image = foto);
  }

  @override
  void initState() {
    // Sempre execute a inicializacao original da classe State primeiro.
    super.initState();
    // Inicia a câmera automaticamente ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) => _tirarFoto());
  }

  @override
  Widget build(BuildContext context) {
    // context permite acessar tamanho de tela, tema e navegacao.
    // Stack sobrepoe foto, moldura de foco e controles inferiores.
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
          // Mostra a foto se ela foi capturada; caso contrario, mostra o icone.
          if (_image != null)
            Positioned.fill(
              child: fotoPreview(_image!.path, fit: BoxFit.cover),
            )
          else
            const Center(
              child: Icon(Icons.camera_alt, color: AppColors.textMuted, size: 64),
            ),
          
          // Moldura de foco apenas visual (a camera e controlada pelo plugin).
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

          // Cancelar, fotografar novamente e confirmar/devolver o caminho.
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
                    final path = _image?.path;
                    // pop com resultado devolve o caminho para NovaPartidaScreen.
                    if (path != null) Navigator.pop(context, path);
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
