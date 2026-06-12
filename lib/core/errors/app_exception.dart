enum AppErrorType {
	network,
	timeout,
	unauthorized,
	sessionExpired,
	badRequest,
	validation,
	server,
	invalidResponse,
	unknown,
}

class AppException implements Exception {
	const AppException({
		required this.type,
		required this.userMessage,
		this.statusCode,
		this.errorCode,
		this.debugMessage,
		this.fieldErrors = const <String, String>{},
	});

	final AppErrorType type;
	final String userMessage;
	final int? statusCode;
	final String? errorCode;
	final String? debugMessage;
	final Map<String, String> fieldErrors;

	@override
	String toString() => userMessage;
}
