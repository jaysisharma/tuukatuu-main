
import '../utils/country_codes.dart';

class ValidationService {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Phone validation (International format)
  static bool isValidPhone(String phone, {String? countryCode}) {
    // Remove all non-digit characters except +
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // If country code is provided, validate accordingly
    if (countryCode != null) {
      switch (countryCode) {
        case 'NP': // Nepal
          return RegExp(r'^(\+977|977)?[9][6-8]\d{8}$').hasMatch(cleanedPhone);
        case 'IN': // India
          return RegExp(r'^(\+91|91)?[6-9]\d{9}$').hasMatch(cleanedPhone);
        case 'US': // United States
        case 'CA': // Canada
          return RegExp(r'^(\+1|1)?[2-9]\d{9}$').hasMatch(cleanedPhone);
        case 'GB': // United Kingdom
          return RegExp(r'^(\+44|44)?[1-9]\d{9}$').hasMatch(cleanedPhone);
        case 'AU': // Australia
          return RegExp(r'^(\+61|61)?[2-9]\d{8}$').hasMatch(cleanedPhone);
        case 'DE': // Germany
          return RegExp(r'^(\+49|49)?[1-9]\d{10,11}$').hasMatch(cleanedPhone);
        case 'FR': // France
          return RegExp(r'^(\+33|33)?[1-9]\d{8}$').hasMatch(cleanedPhone);
        case 'JP': // Japan
          return RegExp(r'^(\+81|81)?[1-9]\d{9}$').hasMatch(cleanedPhone);
        case 'CN': // China
          return RegExp(r'^(\+86|86)?[1-9]\d{10}$').hasMatch(cleanedPhone);
        case 'KR': // South Korea
          return RegExp(r'^(\+82|82)?[1-9]\d{9}$').hasMatch(cleanedPhone);
        case 'SG': // Singapore
          return RegExp(r'^(\+65|65)?[6-9]\d{7}$').hasMatch(cleanedPhone);
        case 'MY': // Malaysia
          return RegExp(r'^(\+60|60)?[1-9]\d{8,9}$').hasMatch(cleanedPhone);
        case 'TH': // Thailand
          return RegExp(r'^(\+66|66)?[1-9]\d{8}$').hasMatch(cleanedPhone);
        case 'VN': // Vietnam
          return RegExp(r'^(\+84|84)?[1-9]\d{8,9}$').hasMatch(cleanedPhone);
        case 'PH': // Philippines
          return RegExp(r'^(\+63|63)?[2-9]\d{9}$').hasMatch(cleanedPhone);
        case 'ID': // Indonesia
          return RegExp(r'^(\+62|62)?[2-9]\d{8,9}$').hasMatch(cleanedPhone);
        case 'BD': // Bangladesh
          return RegExp(r'^(\+880|880)?[1-9]\d{9}$').hasMatch(cleanedPhone);
        case 'PK': // Pakistan
          return RegExp(r'^(\+92|92)?[1-9]\d{9}$').hasMatch(cleanedPhone);
        case 'LK': // Sri Lanka
          return RegExp(r'^(\+94|94)?[1-9]\d{8}$').hasMatch(cleanedPhone);
        case 'MV': // Maldives
          return RegExp(r'^(\+960|960)?[1-9]\d{6}$').hasMatch(cleanedPhone);
        case 'BT': // Bhutan
          return RegExp(r'^(\+975|975)?[1-9]\d{7}$').hasMatch(cleanedPhone);
        case 'MM': // Myanmar
          return RegExp(r'^(\+95|95)?[1-9]\d{9}$').hasMatch(cleanedPhone);
        case 'LA': // Laos
          return RegExp(r'^(\+856|856)?[1-9]\d{8}$').hasMatch(cleanedPhone);
        case 'KH': // Cambodia
          return RegExp(r'^(\+855|855)?[1-9]\d{8}$').hasMatch(cleanedPhone);
        case 'BN': // Brunei
          return RegExp(r'^(\+673|673)?[1-9]\d{6}$').hasMatch(cleanedPhone);
        case 'TL': // East Timor
          return RegExp(r'^(\+670|670)?[1-9]\d{7}$').hasMatch(cleanedPhone);
        default:
          // Generic validation for other countries (7-15 digits)
          return RegExp(r'^\+?[1-9]\d{6,14}$').hasMatch(cleanedPhone);
      }
    }
    
    // Default to Nepal validation if no country code provided
    return RegExp(r'^(\+977|977)?[9][6-8]\d{8}$').hasMatch(cleanedPhone);
  }

  // Password validation (minimum 8 characters, at least one letter and one number)
  static bool isValidPassword(String password) {
    return password.length >= 8 && 
           RegExp(r'[a-zA-Z]').hasMatch(password) && 
           RegExp(r'[0-9]').hasMatch(password);
  }

  // Name validation
  static bool isValidName(String name) {
    return name.trim().length >= 2 && 
           RegExp(r'^[a-zA-Z\s]+$').hasMatch(name.trim());
  }

  // Store name validation
  static bool isValidStoreName(String storeName) {
    return storeName.trim().length >= 3 && 
           storeName.trim().length <= 50;
  }

  // Store description validation
  static bool isValidStoreDescription(String description) {
    return description.trim().length >= 10 && 
           description.trim().length <= 500;
  }

  // Price validation
  static bool isValidPrice(dynamic price) {
    if (price == null) return false;
    final numPrice = double.tryParse(price.toString());
    return numPrice != null && numPrice > 0;
  }

  // Coordinates validation
  static bool isValidCoordinates(Map<String, dynamic>? coordinates) {
    if (coordinates == null) return false;
    
    final lat = coordinates['latitude'];
    final lng = coordinates['longitude'];
    
    if (lat == null || lng == null) return false;
    
    final numLat = double.tryParse(lat.toString());
    final numLng = double.tryParse(lng.toString());
    
    return numLat != null && 
           numLng != null && 
           numLat >= -90 && numLat <= 90 && 
           numLng >= -180 && numLng <= 180;
  }

  // Category validation
  static bool isValidCategory(String category) {
    final validCategories = [
      'T-Mart', 'Wine & Beer', 'Fast Food', 'Pharmacy', 'Bakery', 
      'Grocery', 'Fresh Fruits', 'Vegetables', 'Dairy', 'Organic'
    ];
    return validCategories.contains(category);
  }

  // Image URL validation
  static bool isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    return url.startsWith('http://') || 
           url.startsWith('https://') || 
           url.startsWith('assets/');
  }

  // Error message helpers
  static String getEmailErrorMessage(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!isValidEmail(email)) return 'Please enter a valid email address';
    return '';
  }

  static String getPhoneErrorMessage(String phone, {String? countryCode}) {
    if (phone.isEmpty) return 'Phone number is required';
    if (!isValidPhone(phone, countryCode: countryCode)) {
      if (countryCode == 'NP') {
        return 'Please enter a valid Nepal phone number (e.g., +977 98XXXXXXXX)';
      } else if (countryCode != null) {
        final country = CountryCodes.findByCode(countryCode);
        if (country != null) {
          return 'Please enter a valid ${country.name} phone number';
        }
      }
      return 'Please enter a valid phone number';
    }
    return '';
  }

  static String getPasswordErrorMessage(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[a-zA-Z]').hasMatch(password)) return 'Password must contain at least one letter';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Password must contain at least one number';
    return '';
  }

  static String getNameErrorMessage(String name) {
    if (name.isEmpty) return 'Name is required';
    if (name.trim().length < 2) return 'Name must be at least 2 characters';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name.trim())) return 'Name can only contain letters and spaces';
    return '';
  }

  static String getStoreNameErrorMessage(String storeName) {
    if (storeName.isEmpty) return 'Store name is required';
    if (storeName.trim().length < 3) return 'Store name must be at least 3 characters';
    if (storeName.trim().length > 50) return 'Store name must be less than 50 characters';
    return '';
  }

  static String getStoreDescriptionErrorMessage(String description) {
    if (description.isEmpty) return 'Store description is required';
    if (description.trim().length < 10) return 'Store description must be at least 10 characters';
    if (description.trim().length > 500) return 'Store description must be less than 500 characters';
    return '';
  }

  static String getPriceErrorMessage(dynamic price) {
    if (price == null || price.toString().isEmpty) return 'Price is required';
    if (!isValidPrice(price)) return 'Please enter a valid price greater than 0';
    return '';
  }

  static String getCoordinatesErrorMessage(Map<String, dynamic>? coordinates) {
    if (coordinates == null) return 'Coordinates are required';
    if (!isValidCoordinates(coordinates)) return 'Please enter valid coordinates';
    return '';
  }

  static String getCategoryErrorMessage(String category) {
    if (category.isEmpty) return 'Category is required';
    if (!isValidCategory(category)) return 'Please select a valid category';
    return '';
  }

  static String getImageUrlErrorMessage(String url) {
    if (url.isEmpty) return 'Image URL is required';
    if (!isValidImageUrl(url)) return 'Please enter a valid image URL';
    return '';
  }

  // Form validation helpers
  static bool validateForm(Map<String, String> fields) {
    for (final field in fields.entries) {
      final error = _getFieldErrorMessage(field.key, field.value);
      if (error.isNotEmpty) return false;
    }
    return true;
  }

  static String _getFieldErrorMessage(String fieldName, String value) {
    switch (fieldName.toLowerCase()) {
      case 'email':
        return getEmailErrorMessage(value);
      case 'phone':
        return getPhoneErrorMessage(value);
      case 'password':
        return getPasswordErrorMessage(value);
      case 'name':
        return getNameErrorMessage(value);
      case 'storename':
        return getStoreNameErrorMessage(value);
      case 'storedescription':
        return getStoreDescriptionErrorMessage(value);
      case 'category':
        return getCategoryErrorMessage(value);
      case 'imageurl':
        return getImageUrlErrorMessage(value);
      default:
        return '';
    }
  }

  // Sanitization helpers
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  static String sanitizePhone(String phone) {
    return phone.trim().replaceAll(RegExp(r'[^\d+]'), '');
  }

  static String sanitizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String sanitizeStoreName(String storeName) {
    return storeName.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String sanitizeStoreDescription(String description) {
    return description.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // Format helpers
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 10) {
      return '+977 $cleaned';
    } else if (cleaned.length == 13 && cleaned.startsWith('977')) {
      return '+$cleaned';
    }
    return phone;
  }

  static String formatPrice(dynamic price) {
    if (price == null) return 'Rs. 0';
    final numPrice = double.tryParse(price.toString());
    if (numPrice == null) return 'Rs. 0';
    return 'Rs. ${numPrice.toStringAsFixed(2)}';
  }

  static String formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }
} 