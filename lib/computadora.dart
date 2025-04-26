class Computadora {
  int? id;
  String tipo;
  String marca;
  String cpu;
  String ram;
  String hdd;
 
  Computadora({this.id, required this.tipo, required this.marca, required this.cpu, required this.ram, required this.hdd});
 
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'tipo': tipo,
      'marca': marca,
      'cpu': cpu,
      'ram': ram,
      'hdd': hdd,
    };
    if (id != null) map['id'] = id;
    return map;
  }
 
  factory Computadora.fromMap(Map<String, dynamic> map) {
    return Computadora(
      id: map['id'],
      tipo: map['tipo'],
      marca: map['marca'],
      cpu: map['cpu'],
      ram: map['ram'],
      hdd: map['hdd'],
    );
  }
}
