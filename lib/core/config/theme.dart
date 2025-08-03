import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(
      Theme.of(context).textTheme,
    );

    return ThemeData(
      primarySwatch: Colors.orange,
      scaffoldBackgroundColor: Colors.grey[50],
      fontFamily: GoogleFonts.inter().fontFamily,
      brightness: Brightness.light,
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.orange[700],
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey[900],
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey[900],
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[900],
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.grey[900],
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.grey[700],
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[900],
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[900]),
        titleTextStyle: TextStyle(color: Colors.grey[900], fontSize: 18),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[700],
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.orange[700],
        unselectedItemColor: Colors.grey[600],
        selectedIconTheme: IconThemeData(color: Colors.orange[700]),
        unselectedIconTheme: IconThemeData(color: Colors.grey[600]),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.orange[700]!),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[200],
        thickness: 1,
        space: 1,
      ),
      colorScheme: ColorScheme.light(
        primary: Colors.orange[700]!,
        secondary: Colors.orange[500]!,
        surface: Colors.white,
        background: Colors.grey[50]!,
        error: Colors.red[700]!,
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(
      Theme.of(context).textTheme,
    );

    const surfaceColor = Color(0xFF1E1E1E);
    const backgroundColor = Color(0xFF121212);
    const cardColor = Color(0xFF2C2C2C);
    
    return ThemeData(
      primarySwatch: Colors.orange,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: GoogleFonts.inter().fontFamily,
      brightness: Brightness.dark,
      cardColor: cardColor,
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.orange[300],
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey[100],
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey[100],
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[100],
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.grey[100],
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.grey[300],
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[100],
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[100]),
        titleTextStyle: TextStyle(color: Colors.grey[100], fontSize: 18),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[700],
          foregroundColor: Colors.grey[100],
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.orange[300],
        unselectedItemColor: Colors.grey[400],
        selectedIconTheme: IconThemeData(color: Colors.orange[300]),
        unselectedIconTheme: IconThemeData(color: Colors.grey[400]),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceColor,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        labelStyle: TextStyle(color: Colors.grey[300]),
        hintStyle: TextStyle(color: Colors.grey[500]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3E3E3E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.orange[700]!),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3E3E3E),
        thickness: 1,
        space: 1,
      ),
      colorScheme: ColorScheme.dark(
        primary: Colors.orange[300]!,
        secondary: Colors.orange[500]!,
        surface: surfaceColor,
        background: backgroundColor,
        error: Colors.red[300]!,
        onSurface: Colors.grey[100]!,
        onBackground: Colors.grey[100]!,
        onPrimary: Colors.grey[100]!,
      ),
      iconTheme: IconThemeData(
        color: Colors.grey[100],
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.orange[300];
          }
          return Colors.grey[400];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.orange[900];
          }
          return Colors.grey[800];
        }),
      ),
    );
  }
} 