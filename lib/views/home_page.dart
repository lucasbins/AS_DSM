// ignore: import_of_legacy_library_into_null_safe
// ignore_for_file: unnecessary_null_comparison

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:web_service/models/result_cep.dart';
import 'package:web_service/services/via_cep_service.dart';
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCepController = TextEditingController();
  bool _loading = false;
  bool _enableField = true;
  String _result = '';
  String _erro = '';

  @override
  void dispose() {
    super.dispose();
    _searchCepController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultar CEP'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.share,
              color: Colors.black,
            ),
            onPressed: () {
              _share(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSearchCepTextField(),
            _buildSearchCepButton(),
            _buildResultForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCepTextField() {
    return TextField(
      autofocus: false,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      style: const TextStyle(fontSize: 30),
      decoration: const InputDecoration(
        hintText: 'Cep',
        labelStyle: TextStyle(fontSize: 25, color: Colors.black),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      controller: _searchCepController,
      enabled: _enableField,
    );
  }

  Widget _buildSearchCepButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      // ignore: deprecated_member_use
      child: ElevatedButton(
        //onPressed: _searchCep,
        onPressed: () {
          _validaCep(_searchCepController.text);
        },
        child: _loading ? _circularLoading() : const Text('Consultar'),
      ),
    );
  }

  void _searching(bool enable) {
    setState(() {
      _result = enable ? '' : _result;
      _loading = enable;
      _enableField = !enable;
    });
  }

  Widget _circularLoading() {
    return const SizedBox(
      height: 15.0,
      width: 15.0,
      child: CircularProgressIndicator(),
    );
  }

  Future _searchCep() async {
    _searching(true);

    final cep = _searchCepController.text;

    if (cep.length == 8) {
      final resultCep = await ViaCepService.fetchCep(cep: cep);
      if (resultCep.erro == null) {
        setState(() {
          _result = resultCep.toJson();
        });
        _searching(false);
      } else {
        _erro = 'Cep Inválido';
        _searching(false);
        _showTopSnackBar(context, _erro);
      }
    } else {
      _erro = 'Cep Inválido';
      _searching(false);
      _showTopSnackBar(context, _erro);
    }
  }

  Widget _buildResultForm() {
    dynamic cep;
    if (_result != '') {
      cep = ResultCep.fromJson(_result);
      if (cep.erro == null) {
        return Container(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Cep: ' + cep.cep),
              Text('Logradouro: ' + cep.logradouro),
              Text('Complemento: ' + cep.complemento),
              Text('Bairro: ' + cep.bairro),
              Text('Cidade: ' + cep.localidade),
              Text('Estado: ' + cep.uf),
              Text('Ibge: ' + cep.ibge),
              Text('Gia: ' + cep.gia),
              Text('DDD: ' + cep.ddd),
              Text('Siafi: ' + cep.siafi),
            ],
          ),
        );
      } else {
        _erro = 'Cep Inválido';
        _showTopSnackBar(context, _erro);
      }
    }
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: const Text(''),
    );
  }

  bool _validaCep(String cep) {
    if (cep.isEmpty) {
      setState(() {});
      return false;
    }
    setState(() {});
    _searchCep();
    return true;
  }

  void _showTopSnackBar(BuildContext context, String erro) => Flushbar(
        icon: const Icon(Icons.error, size: 40, color: Colors.red),
        shouldIconPulse: false,
        title: 'ERRO',
        message: erro,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      )..show(context);

  void _share(BuildContext context) {
    dynamic cep;
    if (_result != '') {
      cep = ResultCep.fromJson(_result);
      Share.share(
        "cep: ${cep.cep}, Logradouro: ${cep.logradouro}, Complemento: ${cep.complemento},"
        "Bairro: ${cep.bairro}, Cidade: ${cep.localidade}, Uf: ${cep.uf}, Ibge: ${cep.ibge},"
        "Gia: ${cep.gia}, DDD: ${cep.ddd}, Siafi: ${cep.siafi}.",
      );
    }
  }
}
