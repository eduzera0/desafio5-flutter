import 'package:biblioteca_flutter/entities/tipoimovel.dart';

class ImovelData {
  int? id;
  String? titulo;
  String? descricao;
  DateTime? dataCriacao;
  double? valor;
  TipoImovelData? tipoImovel;

  ImovelData({
    this.id, this.titulo, this.descricao, this.dataCriacao, this.valor, this.tipoImovel
  });

  factory ImovelData.fromJson(Map<String, dynamic> json){
    return ImovelData(
        id: json['id'],
        titulo: json['titulo'],
        descricao: json['descricao'],
        dataCriacao: DateTime.parse(json['dataCriacao']),
        valor: json['valor'],
        tipoImovel: TipoImovelData.fromJson(json['tipoImovel']));
  }

}