/// Usuário autenticado.
class AppUser {
  final String id;
  final String nome;
  final String email;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.nome,
    required this.email,
    this.avatarUrl,
  });

  /// Iniciais para o avatar quando não há foto.
  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }
}
