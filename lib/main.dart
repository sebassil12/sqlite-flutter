import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'computadora.dart';
 
void main() {
  runApp(ComputadorasApp());
}
 
class ComputadorasApp extends StatelessWidget {
  const ComputadorasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Computadoras',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  List<Computadora> listaComputadoras = [];
 
  final _formKey = GlobalKey<FormState>();
  Computadora? computadoraActual;
 
  final tipoCtrl = TextEditingController();
  final marcaCtrl = TextEditingController();
  final cpuCtrl = TextEditingController();
  final ramCtrl = TextEditingController();
  final hddCtrl = TextEditingController();
 
  @override
  void initState() {
    super.initState();
    _cargarComputadoras();
  }
 
  Future<void> _cargarComputadoras() async {
    final data = await DBHelper.getComputadoras();
    setState(() {
      listaComputadoras = data;
    });
  }
 
  void _limpiarFormulario() {
    tipoCtrl.clear();
    marcaCtrl.clear();
    cpuCtrl.clear();
    ramCtrl.clear();
    hddCtrl.clear();
    computadoraActual = null;
  }
 
  Future<void> _guardarComputadora() async {
    if (_formKey.currentState!.validate()) {
      final nueva = Computadora(
        id: computadoraActual?.id,
        tipo: tipoCtrl.text,
        marca: marcaCtrl.text,
        cpu: cpuCtrl.text,
        ram: ramCtrl.text,
        hdd: hddCtrl.text,
      );
 
      if (computadoraActual == null) {
        await DBHelper.insertComputadora(nueva);
      } else {
        await DBHelper.updateComputadora(nueva);
      }
 
      _limpiarFormulario();
      await _cargarComputadoras();
    }
  }
 
  void _cargarEnFormulario(Computadora compu) {
    computadoraActual = compu;
    tipoCtrl.text = compu.tipo;
    marcaCtrl.text = compu.marca;
    cpuCtrl.text = compu.cpu;
    ramCtrl.text = compu.ram;
    hddCtrl.text = compu.hdd;
  }
 
  Future<void> _eliminarComputadora(int id) async {
    await DBHelper.deleteComputadora(id);
    await _cargarComputadoras();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestión de Computadoras"),
        backgroundColor: Colors.indigo[800],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Card(
                    color: Colors.white.withOpacity(0.85),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text("Formulario de Computadora", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            TextFormField(controller: tipoCtrl, decoration: InputDecoration(labelText: 'Tipo'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                            TextFormField(controller: marcaCtrl, decoration: InputDecoration(labelText: 'Marca'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                            TextFormField(controller: cpuCtrl, decoration: InputDecoration(labelText: 'CPU'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                            TextFormField(controller: ramCtrl, decoration: InputDecoration(labelText: 'RAM'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                            TextFormField(controller: hddCtrl, decoration: InputDecoration(labelText: 'HDD'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _guardarComputadora,
                                  child: Text(computadoraActual == null ? 'Agregar' : 'Actualizar'),
                                ),
                                SizedBox(width: 10),
                                OutlinedButton(
                                  onPressed: _limpiarFormulario,
                                  child: Text("Limpiar"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Lista de Computadoras", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 10),
                  ...listaComputadoras.map((compu) => Card(
                        color: Colors.white.withOpacity(0.9),
                        child: ListTile(
                          leading: Icon(Icons.computer, color: Colors.indigo),
                          title: Text("${compu.tipo} - ${compu.marca}"),
                          subtitle: Text("CPU: ${compu.cpu}, RAM: ${compu.ram}, HDD: ${compu.hdd}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: Icon(Icons.edit, color: Colors.orange), onPressed: () => _cargarEnFormulario(compu)),
                              IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _eliminarComputadora(compu.id!)),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}