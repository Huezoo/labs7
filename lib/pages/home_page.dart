import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:labs7/services/firestore.dart';


class HomePage  extends StatefulWidget{
  const HomePage ({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  // Incluir el servicio firestore
  final FirestoreService firestoreService = FirestoreService();

  //Controlador de texto
  final TextEditingController textController = TextEditingController();

  //Cuadro de dialogo
  void openNoteBox({String? docID}) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ), 
        actions: [
          //boton pa guardar
          ElevatedButton(
            onPressed: () {
              //Agregar nota nueva
              if (docID == null) {
                firestoreService.addNote(textController.text);
              }

              //actualizar nota existente
              else {
                firestoreService.updateNote(docID, textController.text);
              }

              //Limpiar el controlador de texto
              textController.clear();

              //Cerrar cuadro de dialogo
              Navigator.pop(context);

            },
            child: Text("Add"))
        ],
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notas")),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // obtener la info si hay data
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            //mostrar como lista
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                //obtener cada document individual
                DocumentSnapshot document = notesList [index];
                String docID = document.id;

                //obtener la nota de cada documento
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data ['note'];

                //mostrar como una list tile
                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    //boton pa actualizar
                    IconButton(
                    onPressed: () => openNoteBox(docID: docID),
                    icon: const Icon(Icons.settings),
                  ),

                  //boton pa borrar
                  IconButton(
                    onPressed: () => firestoreService.deleteNote(docID),
                    icon: const Icon(Icons.delete),
                  ),
                  ],)

                );
              },
            );
          }

          //si no hay data, retornemos nada
          else {
            return const Text("sin notas...");
          }
        },
      )
    );
  }
}