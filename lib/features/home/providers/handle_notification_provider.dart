import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:push_app_notification/config/constants/storage_keys.dart';
import 'package:push_app_notification/features/home/models/get_notifications_model.dart';
import 'package:push_app_notification/features/home/models/push_message.dart';
import 'package:push_app_notification/features/home/services/handle_notification_service.dart';
import 'package:push_app_notification/features/shared/services/service_exception.dart';
import 'package:push_app_notification/features/shared/services/storage_service.dart';

final handleNotificationProvider =
    StateNotifierProvider<HandleNotificationNotifier, HandleNotificationState>(
        (ref) {
  return HandleNotificationNotifier(ref);
});

class HandleNotificationNotifier
    extends StateNotifier<HandleNotificationState> {
  HandleNotificationNotifier(this.ref) : super(HandleNotificationState());
  final StateNotifierProviderRef ref;

  getNotifications() async {
    try {
      final userId = await StorageService.get<int>(StorageKeys.userId);
      final GetNotificationsResponse response =
          await GetNotificationsService.getNotifications(userId: userId!);
      
      state = state.copyWith(
        savedNotifications: response.notifications
      );
      print('> ${response.notifications}');
    } catch (e) {
      print("Error in sendNotificationProvider: $e");
      throw ServiceException(
          '> ocurrió un error en el sendNotificationProvider: $e');
    }
  }
}

class HandleNotificationState {
  final Map<String, dynamic> message;
  final List<PushMessage> savedNotifications;

  HandleNotificationState({
    this.message = const {},
    this.savedNotifications = const [],
  });

  HandleNotificationState copyWith({
    Map<String, dynamic>? message,
    List<PushMessage>? savedNotifications,
  }) {
    return HandleNotificationState(
      message: message ?? this.message,
      savedNotifications: savedNotifications ?? this.savedNotifications,
    );
  }
}
