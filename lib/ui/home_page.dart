import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:searching_gifs/ui/gif_page.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  final _controllerSearchTextField = TextEditingController();

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=RW522eZtVitNmmdZ1qqejdOJ5fjZQ3K6&limit=27&rating=G");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=RW522eZtVitNmmdZ1qqejdOJ5fjZQ3K6&q=$_search&limit=26&offset=$_offset&rating=G&lang=en");

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controllerSearchTextField,
                    decoration: InputDecoration(
                        labelText: "Pesquise aqui",
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder()),
                    style: TextStyle(color: Colors.black, fontSize: 18),
                    textAlign: TextAlign.center,
                    onSubmitted: (text) {
                      setState(() {
                        _search = text;
                        _offset = 0;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child:  Center(
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.black,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _search = _controllerSearchTextField.text;
                            _offset = 0;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        strokeWidth: 5,
                      ),
                    );
                    break;
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return _createGifsTable(context, snapshot);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null || _search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifsTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data["data"].length)
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300,
              fit: BoxFit.cover,
            ),
            /*child: Image.network(
              snapshot.data["data"][index]["images"]["fixed_height"]["url"],
              height: 300,
              fit: BoxFit.cover,
            ),*/
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshot.data["data"][index])));
            },
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"]);
            },
          );
        else
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    color: Colors.black,
                    size: 70,
                  ),
                  Text(
                    "Carregar Outros...",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offset += 26;
                });
              },
            ),
          );
      },
    );
  }
}
