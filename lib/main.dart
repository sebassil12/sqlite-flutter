import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'computadora.dart';
 
void main() {
  //Use const to avoid unnecessary rebuilds
  runApp(const ComputadorasApp());
}

class ComputadorasApp extends StatelessWidget {
  const ComputadorasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Computadoras',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        //Add elevatedButtonTheme to set default style for elevated buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
          ),
        ),
      ),
      // use const for the home widget to avoid unnecessary rebuilds
      home: const HomeScreen(),
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
  // Use GlobalKey<FormState> to manage the form state
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Computadora? computadoraActual;

  // Use TextEditingController to manage the text fields
  final TextEditingController tipoCtrl = TextEditingController();
  final TextEditingController marcaCtrl = TextEditingController();
  final TextEditingController cpuCtrl = TextEditingController();
  final TextEditingController ramCtrl = TextEditingController();
  final TextEditingController hddCtrl = TextEditingController();
 
  @override
  void initState() {
    super.initState();
    _cargarComputadoras();
  }

  @override
  void dispose() {
    tipoCtrl.dispose();
    marcaCtrl.dispose();
    cpuCtrl.dispose();
    ramCtrl.dispose();
    hddCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarComputadoras() async {
    try{
      final data = await DBHelper.getComputadoras();
      setState(() {
      listaComputadoras = data;
      });
    } catch (e) { // Handle error if needed
      _mostrarError("Error al cargar computadoras: $e");
    }
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

    try{
        if (computadoraActual == null) {
          await DBHelper.insertComputadora(nueva);
        } else {
          await DBHelper.updateComputadora(nueva);
        }
        _limpiarFormulario();
        await _cargarComputadoras(); 
      } catch (e) { // Handle error if needed
        _mostrarError("Error al guardar computadora: $e");
      }
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
  //Future is used to handle async operations
  Future<void> _eliminarComputadora(int id) async {
    try {
      await DBHelper.deleteComputadora(id);
      await _cargarComputadoras();
    } catch (e) {
      _mostrarError('Error al eliminar computadora: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gestión de Computadoras",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo[800],
      ),
      body: Stack(
  children: [
    Positioned.fill(
      child: Opacity(
          opacity: 0.5, // Ajusta la opacidad aquí
          child: Image.asset(
            'assets/fondo.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.topLeft,
        ),
      ),
    ),
    Positioned.fill(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
             FormularioComputadora(
                    formKey: _formKey,
                    tipoCtrl: tipoCtrl,
                    marcaCtrl: marcaCtrl,
                    cpuCtrl: cpuCtrl,
                    ramCtrl: ramCtrl,
                    hddCtrl: hddCtrl,
                    onSave: _guardarComputadora,
                    onClear: _limpiarFormulario,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Lista de Computadoras",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  ...listaComputadoras.map((compu) => Card(
                        color: Colors.black.withValues(alpha: 0.6 * 255),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: const Icon(Icons.computer, color: Colors.white),
                          title: Text("${compu.tipo} - ${compu.marca}", style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            "CPU: ${compu.cpu}, RAM: ${compu.ram}, HDD: ${compu.hdd}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                                onPressed: () => _cargarEnFormulario(compu),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _eliminarComputadora(compu.id!),
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 100), // espacio para scroll cómodo
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FormularioComputadora extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController tipoCtrl, marcaCtrl, cpuCtrl, ramCtrl, hddCtrl;
  final VoidCallback onSave, onClear;

  const FormularioComputadora({
    super.key,
    required this.formKey,
    required this.tipoCtrl,
    required this.marcaCtrl,
    required this.cpuCtrl,
    required this.ramCtrl,
    required this.hddCtrl,
    required this.onSave,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Formulario de Computadora",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: tipoCtrl.text.isNotEmpty ? tipoCtrl.text : null, // Valor inicial
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'Laptop', child: Text('Laptop')),
                  DropdownMenuItem(value: 'Escritorio', child: Text('Escritorio')),
                ],
                onChanged: (value) {
                  tipoCtrl.text = value!; // Actualiza el controlador con el valor seleccionado
                },
                validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: marcaCtrl,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: cpuCtrl,
                decoration: const InputDecoration(labelText: 'CPU'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: ramCtrl,
                decoration: const InputDecoration(labelText: 'RAM'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: hddCtrl,
                decoration: const InputDecoration(labelText: 'HDD'),
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onSave,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.clear),
                      label: const Text("Limpiar"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}