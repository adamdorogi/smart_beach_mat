class User {
  String name;
  int skinType;
  String gender;
  DateTime dob;

  User({this.name, this.skinType, this.gender, this.dob});

  @override
  String toString() {
    return 'User(name: $name, skinType: $skinType, gender: $gender, dob: $dob)';
  }
}
