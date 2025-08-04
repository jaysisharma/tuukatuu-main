import 'package:flutter/material.dart';
import '../services/error_service.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? color;
  final String? errorType;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
    this.color,
    this.errorType,
  });

  @override
  Widget build(BuildContext context) {
    final displayIcon = icon ?? (errorType != null ? ErrorService.getErrorIcon(errorType!) : Icons.error_outline);
    final displayColor = color ?? Theme.of(context).colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              displayIcon,
              size: 64,
              color: displayColor,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: displayColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: displayColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget for showing loading states
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 32,
            height: size ?? 32,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Widget for showing empty states
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;
  final Color? color;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.onAction,
    this.actionText,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? Colors.grey;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: displayColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Widget for showing network error with retry
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      errorType: ErrorService.networkError,
      message: customMessage ?? ErrorService.getErrorMessage(ErrorService.networkError),
      onRetry: onRetry,
    );
  }
}

// Widget for showing server error with retry
class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const ServerErrorWidget({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      errorType: ErrorService.serverError,
      message: customMessage ?? ErrorService.getErrorMessage(ErrorService.serverError),
      onRetry: onRetry,
    );
  }
}

// Widget for showing authentication error
class AuthenticationErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const AuthenticationErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      errorType: ErrorService.authenticationError,
      message: ErrorService.getErrorMessage(ErrorService.authenticationError),
      onRetry: onRetry,
    );
  }
} 