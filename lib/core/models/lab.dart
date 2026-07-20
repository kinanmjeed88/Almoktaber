import 'package:isar/isar.dart';

part 'lab.g.dart';

@collection
class Lab {
  Id id = Isar.autoIncrement;

  late String name;

  late String location;

  late int capacity;

  List<String> equipment = [];

  Lab({
    required this.name,
    required this.location,
    required this.capacity,
    this.equipment = const [],
  });

  Lab.empty();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'capacity': capacity,
      'equipment': equipment,
    };
  }

  factory Lab.fromJson(Map<String, dynamic> json) {
    return Lab(
      name: json['name'] as String,
      location: json['location'] as String,
      capacity: json['capacity'] as int,
      equipment: (json['equipment'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    )..id = json['id'] as int;
  }
}
