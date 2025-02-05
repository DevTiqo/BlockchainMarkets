import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Price List',
      theme: new ThemeData(primaryColor: Colors.white),
      home: CryptoList(),
    );
  }
}

class CryptoList extends StatefulWidget {
  @override
  CryptoListState createState() => CryptoListState();
}

class CryptoListState extends State<CryptoList> {
  List _cryptoList = [];
  final _saved = Set<Map>();
  final _boldStyle = new TextStyle(fontWeight: FontWeight.bold);
  bool _loading = false;
  final List<MaterialColor> _colors = [
    Colors.blue,
    Colors.indigo,
    Colors.lime,
    Colors.teal,
    Colors.cyan
  ];

  Future<void> getCryptoPrices() async {
    List cryptoDatas = [];

    print('getting crypto prices');
    String _apiURL =
        "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?id=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15";
    setState(() {
      this._loading = true;
    });
    http.Response response = await http.get(_apiURL,
        headers: {"X-CMC_PRO_API_KEY": "192f6ffc-306a-495f-8110-ebd51b64b52d"});

    Map<String, dynamic> responseJSON = json.decode(response.body);
    if (responseJSON["status"]["error_code"] == 0) {
      for (int i = 1; i <= responseJSON["data"].length; i++) {
        cryptoDatas.add(responseJSON["data"][i.toString()]);
      }
    }
    print(cryptoDatas);

    setState(() {
      this._cryptoList = cryptoDatas;
      this._loading = false;
    });
    return;
  }

  String cryptoPrice(Map crypto) {
    int decimals = 2;
    int fac = pow(10, decimals).toInt();;
    double d = (crypto['quote']['USD']['price']);
    return "\$" + (d = (d * fac).round() / fac).toString();
  }

  CircleAvatar _getLeadingWidget(String name, MaterialColor color) {
    return new CircleAvatar(
      backgroundColor: color,
      child: new Text(name[0]),
    );
  }

  _getMainBody() {
    if (_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return new RefreshIndicator(
        child: _buildCryptoList(),
        onRefresh: getCryptoPrices,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getCryptoPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('CryptoList'),
          actions: <Widget>[
            new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
          ],
        ),
        body: _getMainBody());
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (crypto) {
              return new ListTile(
                leading: _getLeadingWidget(crypto['name'], Colors.blue),
                title: Text(crypto['name']),
                subtitle: Text(
                  cryptoPrice(crypto),
                  style: _boldStyle,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return new Scaffold(
            appBar: new AppBar(
              title: const Text('Saved Cryptos'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }

  Widget _buildCryptoList() {
    return ListView.builder(
        itemCount: _cryptoList.length,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          final index = i;
          print(index);
          final MaterialColor color = _colors[index % _colors.length];
          return _buildRow(_cryptoList[index], color);
        });
  }

  Widget _buildRow(Map crypto, MaterialColor color) {
    final bool favourited = _saved.contains(crypto);

    void _fav() {
      setState(() {
        if (favourited) {
          _saved.remove(crypto);
        } else {
          _saved.add(crypto);
        }
      });
    }

    return ListTile(
      leading: _getLeadingWidget(crypto['name'], color),
      title: Text(crypto['name']),
      subtitle: Text(
        cryptoPrice(crypto),
        style: _boldStyle,
      ),
      trailing: new IconButton(
        icon: Icon(favourited ? Icons.favorite : Icons.favorite_border),
        color: favourited ? Colors.red : null,
        onPressed: _fav,
      ),
    );
  }
}
