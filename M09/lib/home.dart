import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:m09/event_model.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  void initState() {
    readData();
    super.initState();
  }

  Future testData() async {
    await Firebase.initializeApp();
    print('init Done');
    FirebaseFirestore db = await FirebaseFirestore.instance;
    print('init Firestore Done');

    var data = await db.collection('event_detail').get().then((event) {
      for (var doc in event.docs) {
        print('${doc.id} => ${doc.data()}');
      }
    });
  }

  Future readData() async {
    await Firebase.initializeApp();
    FirebaseFirestore db = await FirebaseFirestore.instance;
    var data = await db.collection('event_detail').get();
    setState(() {
      details = data.docs.map((doc) => EventModel.fromDocSnapshot(doc)).toList();
    });
  }

  addRand() async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    EventModel insertData = EventModel(
      judul: getRandString(5),
      keterangan: getRandString(30),
      tanggal: getRandString(10),
      is_like: Random().nextBool(),
      pembicara: getRandString(20),
    );
    await db.collection('event_detail').add(insertData.toMap());
    setState(() {
      details.add(insertData);
    });
    readData();
  }

  deleteEvent(String documentId) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    await db.collection('event_detail').doc(documentId).delete();
    setState(() {
      details.removeWhere((element) => element.id == documentId);
    });
  }

  void _showUpdateDialog(int position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController judulController =
            TextEditingController(text: details[position].judul);
        TextEditingController keteranganController =
            TextEditingController(text: details[position].keterangan);
        TextEditingController tanggalController =
            TextEditingController(text: details[position].tanggal);
        TextEditingController pembicaraController =
            TextEditingController(text: details[position].pembicara);

        return AlertDialog(
          title: Text('Perbarui Data'),
          content: Column(
            children: [
              TextFormField(
                controller: judulController,
                decoration: InputDecoration(labelText: 'Judul'),
              ),
              TextFormField(
                controller: keteranganController,
                decoration: InputDecoration(labelText: 'Keterangan'),
              ),
              TextFormField(
                controller: tanggalController,
                decoration: InputDecoration(labelText: 'Tanggal'),
              ),
              TextFormField(
                controller: pembicaraController,
                decoration: InputDecoration(labelText: 'Pembicara'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                updateEvent(
                  position,
                  judulController.text,
                  keteranganController.text,
                  tanggalController.text,
                  pembicaraController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('Perbarui'),
            ),
          ],
        );
      },
    );
  }

  void updateEvent(int pos, String judul, String keterangan, String tanggal,
      String pembicara) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    await db.collection('event_detail').doc(details[pos].id).update({
      'Judul': judul,
      'Keterangan': keterangan,
      'tanggal': tanggal,
      'Pembicara': pembicara,
    });
    setState(() {
      details[pos].judul = judul;
      details[pos].keterangan = keterangan;
      details[pos].tanggal = tanggal;
      details[pos].pembicara = pembicara;
    });
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  List<EventModel> details = [];
  @override
  Widget build(BuildContext context) {
    testData();
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloud Firestore'),
      ),
      body: ListView.builder(
        itemCount: (details != null) ? details.length : 0,
        itemBuilder: (context, position) {
          return ListTile(
            title: Text(details[position].judul),
            subtitle: Text(
              '${details[position].keterangan}' +
                  '\nHari : ${details[position].tanggal}' +
                  '\nPembicara: ${details[position].pembicara}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: details[position].is_like,
                  onChanged: (bool? value) {
                    updateEventCheckbox(position);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showUpdateDialog(position);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    if (details[position].id != null) {
                      _showDeleteConfirmationDialog(details[position].id!);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('tak bisa dihapus'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              // Tambahkan logika ketika item diklik
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addRand();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Penghapusan'),
          content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                deleteEvent(documentId);
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void updateEventCheckbox(int position) async {
    FirebaseFirestore db = await FirebaseFirestore.instance;
    await db.collection('event_detail').doc(details[position].id).update({
      'is_like': !details[position].is_like,
    });
    setState(() {
      details[position].is_like = !details[position].is_like;
    });
  }
}
