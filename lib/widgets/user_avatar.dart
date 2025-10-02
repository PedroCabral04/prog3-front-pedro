import 'package:flutter/material.dart';
import 'dart:convert';

class UserAvatar extends StatelessWidget {
  final String? profileImageUrl;
  final String? profileImageBase64;
  final String? fallbackText;
  final double size;
  final Color? backgroundColor;

  const UserAvatar({
    Key? key,
    this.profileImageUrl,
    this.profileImageBase64,
    this.fallbackText,
    this.size = 40,
    this.backgroundColor,
  }) : super(key: key);

  /// Detecta se o formato é AVIF pela assinatura do base64
  bool _isAvifFormat(String base64String) {
    String cleanBase64 = base64String;
    if (cleanBase64.contains(',')) {
      cleanBase64 = cleanBase64.split(',')[1];
    }
    
    // Verifica assinatura AVIF no início do base64
    return cleanBase64.startsWith('AAAAHGZ0eXBh') || 
           base64String.toLowerCase().contains('data:image/avif');
  }

  /// Constrói um widget de fallback específico para AVIF
  Widget _buildAvifFallback() {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? Colors.orange[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: size * 0.35,
            color: Colors.orange[700],
          ),
          if (size > 50)
            Text(
              'AVIF',
              style: TextStyle(
                fontSize: size * 0.12,
                color: Colors.orange[700],
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Se tem imagem em base64, usa ela
    if (profileImageBase64 != null && profileImageBase64!.isNotEmpty) {
      // Verifica se é AVIF ANTES de tentar decodificar
      if (_isAvifFormat(profileImageBase64!)) {
        // AVIF não é suportado pelo Flutter - retorna fallback específico
        return _buildAvifFallback();
      }

      try {
        // Remove prefixo data:image se existir
        String base64String = profileImageBase64!;
        if (base64String.contains(',')) {
          base64String = base64String.split(',')[1];
        }

        final bytes = base64Decode(base64String);

        return CircleAvatar(
          radius: size / 2,
          backgroundColor: backgroundColor ?? Colors.grey[300],
          child: ClipOval(
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback para outros erros de imagem
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: backgroundColor ?? Colors.red[100],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.broken_image,
                      size: size * 0.4,
                      color: Colors.red[700],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      } catch (e) {
        // Se falhar ao decodificar, usa fallback
      }
    }

    // Se tem URL, usa ela
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      print('UserAvatar - Usando URL: $profileImageUrl');
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: backgroundColor ?? Colors.grey[300],
        child: ClipOval(
          child: Image.network(
            profileImageUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('UserAvatar - Erro ao carregar URL: $error');
              return _buildFallback();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
      );
    }

    // Fallback: mostra iniciais ou ícone
    print('UserAvatar - Usando fallback');
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? Colors.blue,
      child: _buildFallback(),
    );
  }

  Widget _buildFallback() {
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      return Text(
        fallbackText![0].toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Icon(Icons.person, color: Colors.white, size: size * 0.6);
  }
}
