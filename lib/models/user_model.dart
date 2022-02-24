class User {
  final int id;
  final String name;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.avatar,
  });
}

final allUserList = [_jack, _addison, _angel, _deanna];

 User currentUser = _jack;

final User _jack = User(id: 0, name: 'Jack', avatar: 'assets/images/user.png');

final User botSuMed =
    User(id: 110, name: 'SuMed', avatar: 'assets/images/bot.png');

final User _addison =
    User(id: 1, name: 'Addison', avatar: 'assets/images/user.png');

final User _angel =
    User(id: 2, name: 'Angel', avatar: 'assets/images/user.png');

final User _deanna =
    User(id: 3, name: 'Deanna', avatar: 'assets/images/user.png');
/* 
final User jason = User(id: 4, name: 'Json', avatar: 'assets/images/Jason.jpg');

final User judd = User(id: 5, name: 'Judd', avatar: 'assets/images/Judd.jpg');

final User leslie =
    User(id: 6, name: 'Leslie', avatar: 'assets/images/Leslie.jpg');

final User nathan =
    User(id: 7, name: 'Nathan', avatar: 'assets/images/Nathan.jpg');

final User stanley =
    User(id: 8, name: 'Stanley', avatar: 'assets/images/Stanley.jpg');

final User virgil =
    User(id: 9, name: 'Virgil', avatar: 'assets/images/Virgil.jpg');
 */