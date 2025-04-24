import 'package:biocentral/sdk/util/logging.dart';

sealed class BiocentralException implements Exception {
  final Object? error;
  final StackTrace? stackTrace;
  final String message;

  BiocentralException({required this.message, this.error, this.stackTrace, log=true}) {
    final String gitHubIssueLink = _createGitHubIssueLink(message, error, stackTrace);
    if(log) {
      logger.e('$message\n$gitHubIssueLink', error: error, stackTrace: stackTrace);
    }
  }

  static String _createGitHubIssueLink(String message, Object? error, StackTrace? stackTrace) {
    const String advice = 'Create GitHub Issue from Exception: ';
    const String baseRepoIssueLink = 'https://github.com/biocentral/biocentral/issues/new?';

    // URL encode the title and body
    final String title = Uri.encodeComponent('[BUG] Exception in Biocentral');

    String body = 'I am facing the following error message:\n\n$message';
    if (error != null) {
      body += '\n\nError: $error';
    }
    if (stackTrace != null) {
      body += '\n\nStack Trace:\n```\n$stackTrace\n```';
    }

    body += '\n\nPlease provide any additional context or steps to reproduce the issue.';

    // URL encode the body
    final String encodedBody = Uri.encodeComponent(body);

    // Construct the full URL
    final String issueUrl = '$baseRepoIssueLink'
        'title=$title'
        '&body=$encodedBody';

    return advice + issueUrl;
  }
}

class BiocentralIOException extends BiocentralException {
  BiocentralIOException({required super.message, super.error, super.stackTrace, super.log});
}

class BiocentralNetworkException extends BiocentralException {
  BiocentralNetworkException({required super.message, super.error, super.stackTrace, super.log});
}

class BiocentralParsingException extends BiocentralException {
  BiocentralParsingException({required super.message, super.stackTrace, super.log});
}

class BiocentralServerException extends BiocentralException {
  BiocentralServerException({required super.message, super.error, super.stackTrace, super.log});
}

class BiocentralSecurityException extends BiocentralException {
  BiocentralSecurityException({required super.message, super.error, super.stackTrace, super.log});
}

class BiocentralPythonCompanionException extends BiocentralException {
  BiocentralPythonCompanionException({required super.message, super.error, super.stackTrace, super.log});
}


class BiocentralMissingServiceException extends BiocentralException {
  final String missingService;

  BiocentralMissingServiceException({required this.missingService, super.log})
      : super(
            message: 'The server you are connected to does '
                'not provide service $missingService that is required for your task!',);
}
