import 'package:isar/isar.dart';

part 'phone_record.g.dart';

@collection
class PhoneRecord {
  Id id = Isar.autoIncrement;

  late String labName;
  late String phoneNumber;
  late String province;

  PhoneRecord({
    required this.labName,
    required this.phoneNumber,
    required this.province,
  });

  PhoneRecord.empty();
}
