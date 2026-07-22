import 'package:isar/isar.dart';

part 'lab.g.dart';

@collection
class Lab {
  Id id = Isar.autoIncrement;

  late String name;

  late String location;

  Lab({
    required this.name,
    required this.location,
  });

  Lab.empty();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
    };
  }

  factory Lab.fromJson(Map<String, dynamic> json) {
    return Lab(
      name: json['name'] as String,
      location: json['location'] as String,
    )..id = json['id'] as int;
  }
}
