class User {
  String id;
  String name;
  int skinType;
  String gender;
  String dob;
  bool isOwner;
  String createdOn;

  User(
      {this.id,
      this.name,
      this.skinType,
      this.gender,
      this.dob,
      this.isOwner,
      this.createdOn});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        skinType = int.parse(json['skin_type']),
        gender = json['gender'],
        dob = json['dob'],
        isOwner = json['is_owner'],
        createdOn = json['created_on'];

  @override
  String toString() {
    return 'User {id: $id, name: $name, skinType: $skinType, gender: $gender, dob: $dob, isOwner: $isOwner, createdOn: $createdOn}';
  }
}
