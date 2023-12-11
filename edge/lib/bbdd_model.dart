class UserModel {
  final int number;
  final DateTime date;

  const UserModel({
    required this.number,
    required this.date,
  });

  toJson() {
    return {
      "date": date,
      "number": number,
    };
  }
}
