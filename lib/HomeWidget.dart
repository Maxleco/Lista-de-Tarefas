import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

final bool firstOpen = false;

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List _listTarefas = [];
  Map<String, dynamic> _lastItemRemoved = Map();
  TextEditingController _textController = TextEditingController();

  Future<File> _getFile() async {
    final Directory diretorio = await getApplicationDocumentsDirectory();
    return File(diretorio.path + "/dados.json");
  }

  _salvarTarefa() {
    String textoDigitado = _textController.text;
    Map<String, dynamic> dados = Map();
    dados["title"] = textoDigitado;
    dados["checked"] = false;
    setState(() {
      _listTarefas.add(dados);
    });
    _salvarArquivos();
    _textController.text = "";
  }

  _salvarArquivos() async {
    final arquivo = await _getFile();
    String listaString = json.encode(_listTarefas);
    arquivo.writeAsString(listaString);
  }

  _lerArquivos() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    //_salvarArquivos();
    // Then -> Após finalizar a chamada da função
    //  será execuado uma função anônima
    //  onde o parâmetro representa o valor retornado da função
    _lerArquivos().then((list) {
      setState(() {
        _listTarefas = json.decode(list);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _listTarefas.length,
              itemBuilder: (context, index) {
                return _itemCheckBox(context, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              //useSafeArea: true,
              context: context,
              builder: (contex) {
                return AlertDialog(
                  title: Text("Adicionar Tarefas"),
                  content: TextField(
                    controller: _textController,
                    decoration: InputDecoration(labelText: "Digite sua tarefa"),
                    onChanged: (text) {},
                  ),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("CANCELAR"),
                    ),
                    FlatButton(
                      onPressed: () {
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                      child: Text("SALVAR"),
                    ),
                  ],
                );
              });
        },
      ),
    );
  }

  Widget _itemCheckBox(BuildContext context, int index) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _lastItemRemoved = _listTarefas[index];
        _listTarefas.removeAt(index);
        _salvarArquivos();
        final snackBar = SnackBar(
          content: Text("Tarefa Removida!!"),
          action: SnackBarAction(
            label: "Desfazer",
            //textColor: Colors.white,
            onPressed: () {
              setState(() {
                _listTarefas.insert(index, _lastItemRemoved);
              });
              _salvarArquivos();
            },
          ),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      },
      key: ValueKey(DateTime.now().millisecondsSinceEpoch),
      child: CheckboxListTile(
        value: _listTarefas[index]["checked"],
        title: Text(_listTarefas[index]["title"]),
        onChanged: (bool checkedValue) {
          setState(() {
            _listTarefas[index]["checked"] = checkedValue;
          });
          _salvarArquivos();
        },
      ),
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
