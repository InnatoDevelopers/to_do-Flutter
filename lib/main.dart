import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './ToDo.class.dart';
import './form.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '¿Qué debo hacer?'),
      routes: {"/form": (context) => new Formulario()},
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ToDo toDo = new ToDo();
  List<ToDo> listTodo = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //listener Firestore
    Firestore.instance.collection("to_do").snapshots().listen((onData) {
      if (onData.documentChanges.length == 1) {
        for (DocumentChange docChange in onData.documentChanges) {
          DocumentSnapshot doc = docChange.document;
          if (docChange.type == DocumentChangeType.added) {
            ToDo newToDo =
                new ToDo(id: doc.documentID, queHacer: doc.data["queHacer"]);
            setState(() {
              listTodo.add(newToDo);
            });
          } else if (docChange.type == DocumentChangeType.modified) {
            for (var i = 0; i < listTodo.length; i++) {
              if (listTodo[i].getId == doc.documentID) {
                ToDo tempToDo = listTodo[i];
                tempToDo.setQueHacer(doc.data["queHacer"].toString());
                listTodo[i] = tempToDo;
                setState(() {
                  listTodo = listTodo;
                });
              }
            }
          } else if (docChange.type == DocumentChangeType.removed) {
            listTodo.removeWhere((item) => item.getId == doc.documentID);
            setState(() {
              listTodo = listTodo;
            });
          }
        }
      }
    });

    this.getListToDo();
  }

  Future<void> getListToDo() async {
    List<ToDo> listTemp = await toDo.getListToDo();

    if (listTemp != null) {
      setState(() {
        listTodo = listTemp;
      });
    }
  }

  void _toForm() {
    Navigator.of(context).pushNamed("/form");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView(
        children: listTodo.map((value) {
          return Card(
            borderOnForeground: true,
            child: Container(
                padding: EdgeInsets.only(left: 10.0),
                height: 100,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        value.getQueHacer,
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 15.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.delete_forever,
                            size: 40.0,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            await toDo.deleteToDoByID(value.getId);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 15.0),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_right,
                            size: 40.0,
                          ),
                          onPressed: () async {
                            ToDo todoByID = await toDo.getToDoByID(value.getId);

                            Navigator.of(context).push(new MaterialPageRoute(
                                builder: (context) => new Formulario(
                                      queHacer: todoByID.getQueHacer,
                                      id: value.getId,
                                    )));
                          },
                        ),
                      ),
                    )
                  ],
                )),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toForm,
        tooltip: 'Agregar',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
