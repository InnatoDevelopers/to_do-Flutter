import 'package:cloud_firestore/cloud_firestore.dart';

class ToDo {
  String queHacer;
  String id;

  String get getQueHacer => queHacer;
  String get getId => id;

  void setQueHacer(String queHacer) {
    this.queHacer = queHacer;
  }

  ToDo({this.queHacer, this.id});

  Future<List<ToDo>> getListToDo() async {
    List<ToDo> listTodo = [];
    QuerySnapshot documents =
        await Firestore.instance.collection('to_do').getDocuments();

    for (DocumentSnapshot doc in documents.documents) {
      ToDo toDo =
          ToDo(queHacer: doc.data['queHacer'].toString(), id: doc.documentID);
      listTodo.add(toDo);
    }

    return listTodo;
  }

  Future<ToDo> getToDoByID(String id) async {
    DocumentSnapshot doc =
        await Firestore.instance.collection("to_do").document(id).get();
    if (doc != null) {
      print(doc.data);
      return new ToDo(id: id, queHacer: doc.data['queHacer']);
    }
  }

  Future<void> deleteToDoByID(String id) async {
    try {
      await Firestore.instance.collection("to_do").document(id).delete();
      print("Eliminado");
    } catch (error) {
      print(error);
    }
  }
}
