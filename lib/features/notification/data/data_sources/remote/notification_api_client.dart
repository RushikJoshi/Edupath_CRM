import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:gtcrm/core/network/api_endpoints.dart';

part 'notification_api_client.g.dart';

@RestApi()
abstract class NotificationApiClient {
  factory NotificationApiClient(Dio dio, {String baseUrl}) =
      _NotificationApiClient;

  @GET(ApiEndpoints.notifications)
  Future<HttpResponse<dynamic>> getNotifications();

  @GET(ApiEndpoints.notificationsUnread)
  Future<HttpResponse<dynamic>> getUnreadNotifications();

  @PUT(ApiEndpoints.notificationRead)
  Future<HttpResponse<dynamic>> markAsRead(@Path('id') String id);

  @PUT(ApiEndpoints.notificationReadAll)
  Future<HttpResponse<dynamic>> markAllNotificationsRead();
}
