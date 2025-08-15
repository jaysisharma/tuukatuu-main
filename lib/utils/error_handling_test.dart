import '../services/error_service.dart';

// This is a demonstration file showing how error handling works
// You can run this to see how the error categorization works

void main() {
  // Simulate the exact error from your image
  final connectionRefusedError = Exception(
    'ClientException with SocketException: Connection refused (OS Error: Connection refused, errno = 61), address = 13.234.29.215, port = 63091, uri=http://13.234.29.215:3000/api/auth/login'
  );

  // Test error categorization
  final errorType = ErrorService.handleApiError(connectionRefusedError);
  final userMessage = ErrorService.getErrorMessage(errorType);

  print('Original Error:');
  print(connectionRefusedError.toString());
  print('\n${'='*50}\n');
  
  print('Categorized Error Type: $errorType');
  print('User-Friendly Message: $userMessage');
  
  // Test other error types
  print('\n${'='*50}\n');
  print('Testing other error types:');
  
  final authError = Exception('Unauthorized: Invalid token');
  final authType = ErrorService.handleApiError(authError);
  final authMessage = ErrorService.getErrorMessage(authType);
  
  print('Auth Error Type: $authType');
  print('Auth Message: $authMessage');
  
  final serverError = Exception('Internal Server Error 500');
  final serverType = ErrorService.handleApiError(serverError);
  final serverMessage = ErrorService.getErrorMessage(serverType);
  
  print('Server Error Type: $serverType');
  print('Server Message: $serverMessage');
}

// Example of how to use in a real screen:
/*
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with ErrorHandlerMixin {
  
  Future<void> _login() async {
    try {
      // This would normally be your API call
      await ApiService.post('/auth/login', body: {
        'email': 'user@example.com',
        'password': 'password',
      });
      
      // Success - navigate to home
      Navigator.pushReplacementNamed(context, '/home');
      
    } catch (e) {
      // Instead of showing raw error like:
      // "ClientException with SocketException: Connection refused..."
      
      // We now show:
      // "No internet connection. Please check your network and try again."
      handleError(e);
    }
  }
}
*/ 