import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel{
  String? id;
  String judul;
  String keterangan;
  String tanggal;
  bool is_like;
  String pembicara;

  EventModel(
    {this.id,
    required this.judul,
    required this.keterangan,
    required this.tanggal,
    required this.is_like,
    required this.pembicara}
  );

  Map<String, dynamic> toMap() {
    return {
      'Judul': judul,
      'Keterangan': keterangan,
      'Pembicara': pembicara,
      'is_like': is_like,
      'tanggal': tanggal
    };
  }
  EventModel.fromDocSnapshot(DocumentSnapshot<Map<String, dynamic>>doc)
    : id = doc.id,
      judul = doc.data()?['Judul'],
      keterangan = doc.data()?['Keterangan'],
      pembicara = doc.data()?['Pembicara'],
      is_like = doc.data()?['is_like'],
      tanggal = doc.data()?['tanggal'];
}