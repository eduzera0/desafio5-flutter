class LivroData {
  int id;
  String titulo;
  String resumo;

  LivroData({
    required this.id,
    required this.titulo,
    required this.resumo
  });

  factory LivroData.fromJson(Map<String, dynamic> json){
    return new LivroData(
      id: json['id'],
      titulo: json['titulo'],
      resumo: json['resumo']
    );
  }
}