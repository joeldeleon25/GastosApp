import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Necesario para dar formato a la fecha y el monto
import 'package:flutter/services.dart'; // Para usar el FilteringTextInputFormatter

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Transacciones',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaccion> _transacciones = [];
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  DateTime _fechaSeleccionada = DateTime.now();
  bool _esIngreso = true;

  void _agregarTransaccion() {
    final descripcion = _descripcionController.text;
    final monto = double.tryParse(_montoController.text) ?? 0.0;

    if (descripcion.isEmpty || monto <= 0) {
      return;
    }

    final nuevaTransaccion = Transaccion(
      descripcion: descripcion,
      monto: monto,
      fecha: _fechaSeleccionada,
      esIngreso: _esIngreso,
    );

    setState(() {
      _transacciones.add(nuevaTransaccion);
    });

    _descripcionController.clear();
    _montoController.clear();
  }

  void _seleccionarFecha() async {
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaSeleccionada = fechaSeleccionada;
      });
    }
  }

  void _eliminarTransaccion(int index) {
    setState(() {
      _transacciones.removeAt(index);
    });
  }

  double get _totalIngresos {
    return _transacciones
        .where((transaccion) => transaccion.esIngreso)
        .fold(0.0, (total, transaccion) => total + transaccion.monto);
  }

  double get _totalGastos {
    return _transacciones
        .where((transaccion) => !transaccion.esIngreso)
        .fold(0.0, (total, transaccion) => total + transaccion.monto);
  }

  double get _balance {
    return _totalIngresos - _totalGastos;
  }

  void _mostrarFormularioAgregar(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar nueva transacción'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: _montoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(labelText: 'Monto'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada)}'),
                    TextButton(
                      onPressed: _seleccionarFecha,
                      child: const Text('Seleccionar Fecha'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Tipo: '),
                    DropdownButton<bool>(
                      value: _esIngreso,
                      items: const [
                        DropdownMenuItem(
                          value: true,
                          child: Text('Ingreso'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Gasto'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _esIngreso = value ?? true;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _agregarTransaccion();
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Transacciones'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            color: Colors.blue[100],
            child: Column(
              children: [
                Text('Total Ingresos: ${NumberFormat.simpleCurrency(locale: 'en_EN').format(_totalIngresos)}'),
                Text('Total Gastos: ${NumberFormat.simpleCurrency(locale: 'en_EN').format(_totalGastos)}'),
                Text('Balance: ${NumberFormat.simpleCurrency(locale: 'en_EN').format(_balance)}'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _transacciones.length,
              itemBuilder: (context, index) {
                final transaccion = _transacciones[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(transaccion.descripcion),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(transaccion.fecha)),
                    trailing: Text(
                      NumberFormat.simpleCurrency(locale: 'en_EN').format(transaccion.monto),
                      style: TextStyle(
                        color: transaccion.esIngreso ? Colors.green : Colors.red,
                      ),
                    ),
                    onLongPress: () => _eliminarTransaccion(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioAgregar(context),
        tooltip: 'Agregar Transacción',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Transaccion {
  final String descripcion;
  final double monto;
  final DateTime fecha;
  final bool esIngreso;

  Transaccion({
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.esIngreso,
  });
}
