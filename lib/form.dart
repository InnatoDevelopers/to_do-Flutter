import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Formulario extends StatefulWidget {
  final String id;
  final String queHacer;
  Formulario({Key key, this.id, this.queHacer}) : super(key: key);

  @override
  _FormularioState createState() => _FormularioState();
}

class _FormularioState extends State<Formulario> {
  final _formKey = GlobalKey<FormState>();
  String queHacer = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.id != null && widget.queHacer != null){
      setState(() {
        queHacer=widget.queHacer;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id != null ? "Actualizar Elemento" : "Agregar Elemento"),
        centerTitle: true,
      ),
      body: Container(
          padding: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: queHacer,
                  decoration:
                      InputDecoration(labelText: "¿Qué tengo que hacer?"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Di que tienes que hacer.";
                    } else {
                      setState(() {
                        queHacer = value;
                      });
                      return null;
                    }
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: FlatButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          if(widget.id != null){
                             Firestore.instance
                              .collection("to_do").document(widget.id)
                              .updateData({"queHacer": queHacer}).then((onUpdated) {
                                print("actualizado");
                            Navigator.pop(context);
                          });
                          }else{
                             Firestore.instance
                              .collection("to_do")
                              .add({"queHacer": queHacer}).then((onaded) {
                                print("guardado");
                            Navigator.pop(context);
                          });
                          }
                         
                        }
                      },
                      child: Text(widget.id != null ?  "Actualizar": "Guardar"),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
