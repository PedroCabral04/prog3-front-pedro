import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/models.dart';
import '../widgets/user_avatar.dart';

class UserDetailScreen extends StatelessWidget {
  final User user;

  const UserDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Usuário'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar grande no topo
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: UserAvatar(
                  profileImageUrl: user.profileImageUrl,
                  profileImageBase64: user.profileImageBase64,
                  fallbackText: user.fullName?.isNotEmpty == true
                      ? user.fullName![0].toUpperCase()
                      : user.email[0].toUpperCase(),
                  size: 120,
                  backgroundColor: Colors.blue[100],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Teste de imagem direta
            if (user.profileImageBase64 != null &&
                user.profileImageBase64!.isNotEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Teste de Imagem Base64 (Formato AVIF)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Builder(
                          builder: (context) {
                            try {
                              String base64String = user.profileImageBase64!;
                              if (base64String.contains(',')) {
                                base64String = base64String.split(',')[1];
                              }
                              final bytes = base64.decode(base64String);

                              return Image.memory(
                                bytes,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        Text(
                                          'AVIF não suportado',
                                          style: TextStyle(fontSize: 8),
                                        ),
                                        Text(
                                          '${bytes.length} bytes',
                                          style: TextStyle(fontSize: 8),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            } catch (e) {
                              return Center(
                                child: Text(
                                  'Erro: $e',
                                  style: TextStyle(fontSize: 8),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Flutter não suporta AVIF nativamente.\nUse JPEG, PNG ou WebP.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

            if (user.profileImageUrl != null &&
                user.profileImageUrl!.isNotEmpty)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Image.network(
                  user.profileImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text('Erro URL', style: TextStyle(fontSize: 10)),
                    );
                  },
                ),
              ),

            SizedBox(height: 24),

            // Nome do usuário
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações Pessoais',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildInfoRow(
                      context,
                      'Nome Completo',
                      user.fullName ?? 'Não informado',
                      Icons.person,
                    ),

                    _buildInfoRow(context, 'Email', user.email, Icons.email),

                    _buildInfoRow(
                      context,
                      'ID do Usuário',
                      '#${user.id}',
                      Icons.badge,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Informações da Role
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Permissões e Acesso',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildInfoRow(
                      context,
                      'Função (Role)',
                      user.role.name,
                      Icons.security,
                    ),

                    _buildInfoRow(
                      context,
                      'ID da Função',
                      '#${user.role.id}',
                      Icons.key,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Informações técnicas
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações Técnicas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildInfoRow(
                      context,
                      'Tipo de Imagem',
                      _getImageType(),
                      Icons.image,
                    ),

                    if (_isAvifFormat())
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          border: Border.all(color: Colors.orange[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: Colors.orange[700],
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Formato não suportado',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Flutter não suporta AVIF. Use JPEG, PNG ou WebP.',
                                    style: TextStyle(
                                      color: Colors.orange[700],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (user.profileImageUrl != null &&
                        user.profileImageUrl!.isNotEmpty)
                      _buildInfoRow(
                        context,
                        'URL da Imagem',
                        user.profileImageUrl!,
                        Icons.link,
                        isUrl: true,
                      ),

                    if (user.profileImageBase64 != null &&
                        user.profileImageBase64!.isNotEmpty)
                      _buildInfoRow(
                        context,
                        'Tamanho da Imagem',
                        '${(user.profileImageBase64!.length / 1024).round()} KB',
                        Icons.storage,
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),

            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.bug_report),
                  label: Text('Debug'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Debug Info'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('User ID: ${user.id}'),
                              Text('Email: ${user.email}'),
                              Text('Full Name: ${user.fullName}'),
                              Text(
                                'Profile Image URL: ${user.profileImageUrl}',
                              ),
                              Text(
                                'Has Base64: ${user.profileImageBase64 != null && user.profileImageBase64!.isNotEmpty}',
                              ),
                              if (user.profileImageBase64 != null)
                                Text(
                                  'Base64 length: ${user.profileImageBase64!.length}',
                                ),
                              Text('Role: ${user.role.name}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),

                ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text('Editar'),
                  onPressed: () {
                    Navigator.of(context).pop('edit');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),

                OutlinedButton.icon(
                  icon: Icon(Icons.arrow_back),
                  label: Text('Voltar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isUrl = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                isUrl
                    ? Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getImageType() {
    if (user.profileImageBase64 != null &&
        user.profileImageBase64!.isNotEmpty) {
      // Detectar formato da imagem base64
      String base64String = user.profileImageBase64!;
      if (base64String.startsWith('AAAAHGZ0eXBh')) {
        return 'Arquivo AVIF (Base64) - Não suportado pelo Flutter';
      } else if (base64String.startsWith('/9j/')) {
        return 'Arquivo JPEG (Base64)';
      } else if (base64String.startsWith('iVBOR')) {
        return 'Arquivo PNG (Base64)';
      } else if (base64String.startsWith('data:')) {
        String mimeType = base64String.split(';')[0].split(':')[1];
        return 'Arquivo $mimeType (Base64)';
      }
      return 'Arquivo (Base64)';
    } else if (user.profileImageUrl != null &&
        user.profileImageUrl!.isNotEmpty) {
      return 'URL Externa';
    } else {
      return 'Imagem padrão';
    }
  }

  bool _isAvifFormat() {
    if (user.profileImageBase64 != null &&
        user.profileImageBase64!.isNotEmpty) {
      String base64String = user.profileImageBase64!;
      return base64String.startsWith('AAAAHGZ0eXBh') ||
          base64String.contains('data:image/avif');
    }
    return false;
  }
}
