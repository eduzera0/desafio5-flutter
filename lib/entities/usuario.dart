class UsuarioData {
  int? id;
  String? nome;
  String? email;
  String? senha;
  String? confirmarSenha;
  int? status;

  UsuarioData({
    this.id, this.nome, this.email, this.senha, this.confirmarSenha, this.status
  });

  factory UsuarioData.fromJson(Map<String, dynamic> json){
    return UsuarioData(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      senha: json['senha'],
      confirmarSenha: '',
      status: json['status'],
    );
  }
}