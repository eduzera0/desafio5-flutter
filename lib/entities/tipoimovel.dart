class TipoImovelData {
  int? id;
  String nome;

  TipoImovelData({
    this.id, required this.nome
  });

  factory TipoImovelData.fromJson(Map<String, dynamic> json){
    return TipoImovelData(
      id: json['id'],
      nome: json['nome']
    );
  }
}