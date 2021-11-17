// ignore: import_of_legacy_library_into_null_safe
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:web_service/models/result_cep.dart';
import 'package:web_service/services/via_cep_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCepController = TextEditingController();
  bool _loading = false;
  bool _enableField = true;
  bool _cepValido = false;
  String? _result;

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSearchCepTextField(),
            _buildSearchCepButton(),
            _buildResultForm()
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
      // ignore: avoid_print
      print(resultCep.localidade); // Exibindo somente a localidade no terminal

      setState(() {
        _result = resultCep.toJson();
      });

      _searching(false);
    } else {
      _searching(false);
      _showTopSnackBar(context);
    }
  }

  Widget _buildResultForm() {
    return Container(
      padding: const EdgeInsets.only(top: 20.0),
      child: Text(_result ?? ''),
    );
  }

  bool _validaCep(String cep) {
    if (cep.isEmpty) {
      setState(() {
        _cepValido = true;
      });
      return false;
    }
    setState(() {
      _cepValido = false;
    });
    _searchCep();
    return true;
  }

  void _showTopSnackBar(BuildContext context) => Flushbar(
        icon: const Icon(Icons.error, size: 32, color: Colors.red),
        shouldIconPulse: false,
        title: 'title',
        message: 'hello',
        duration: const Duration(seconds: 1),
        flushbarPosition: FlushbarPosition.TOP,
      )..show(context);
}
