//@dart=2.12

enum LittleLightRoutePage { Login, Main }

extension RouteName on LittleLightRoutePage {
  String get name => this.toString().split(".").last.toLowerCase();
}