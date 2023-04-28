import 'package:little_light/models/item_info/destiny_item_info.dart';

import 'base_notification_action.dart';

abstract class ActionNotification extends BaseNotification {
  final DestinyItemInfo item;
  bool _isFinished = false;
  bool _shouldPlayDismissAnimation = false;
  bool _dismissAnimationFinished = false;
  Set<String> _errorMessages = {};
  final DateTime _createdAt;
  DateTime get createdAt => _createdAt;

  ActionNotification({required this.item}) : _createdAt = DateTime.now();

  double get progress;

  bool get active;

  @override
  String get id;

  bool get finishedWithSuccess => _isFinished;
  bool get shouldPlayDismissAnimation => _shouldPlayDismissAnimation;
  bool get dismissAnimationFinished => _dismissAnimationFinished;
  bool get hasError => _errorMessages.isNotEmpty;
  Set<String> get errorMessages => _errorMessages;

  void error(String message) async {
    _errorMessages.add(message);
    notifyListeners();
    await Future.delayed(const Duration(seconds: 4));
    _shouldPlayDismissAnimation = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _dismissAnimationFinished = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    dismiss();
  }

  void success() async {
    _isFinished = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _shouldPlayDismissAnimation = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _dismissAnimationFinished = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    dismiss();
  }
}
