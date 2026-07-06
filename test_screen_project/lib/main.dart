import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';

// Auth screens
import 'screens/auth/intro_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/choose_role_screen.dart';
import 'screens/auth/forgot_password_otp_screen.dart';

// Customer screens
import 'screens/customer/customer_home_screen.dart';
import 'screens/customer/homestay_detail_page.dart';
import 'screens/customer/filter_screen.dart';
import 'screens/customer/booking_form_screen.dart';
import 'screens/customer/booking_confirmation_page.dart';
import 'screens/customer/payment_screen.dart';
import 'screens/customer/my_bookings_screen.dart';
import 'screens/customer/cancel_booking_page.dart';
import 'screens/customer/create_review_page.dart';

// Host screens
import 'screens/host/host_dashboard_screen.dart';
import 'screens/host/host_booking_requests_screen.dart';
import 'screens/host/host_booking_detail_screen.dart';
import 'screens/host/homestay_list_screen.dart';
import 'screens/host/homestay_status_screen.dart';
import 'screens/host/add_homestay_basic_info_screen.dart';
import 'screens/host/add_homestay_location_screen.dart';
import 'screens/host/add_homestay_price_rules_screen.dart';

// Author screens
import 'screens/author/author_dashboard_screen.dart';
import 'screens/author/article_list_screen.dart';
import 'screens/author/create_article_screen.dart';
import 'screens/author/article_detail_screen.dart';

// Common screens
import 'screens/common/profile_page.dart';
import 'screens/common/notification_screen.dart';

// Theme
import 'widgets/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khoi tao Supabase — chi dung cho Auth + Storage
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // ProviderScope bat buoc de Riverpod hoat dong
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hearth & Horizon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(AppTheme.accentOrange),
      initialRoute: '/intro',
      routes: {
        '/intro': (context) => const IntroScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/choose-role': (context) => const ChooseRoleScreen(),
        '/forgot-password-otp': (context) => const ForgotPasswordOtpScreen(),
        
        // Customer flow
        '/customer-home': (context) => const CustomerHomeScreen(),
        '/homestay-detail': (context) => const HomestayDetailPage(),
        '/filter': (context) => const FilterScreen(),
        '/booking-form': (context) => const BookingFormScreen(),
        '/booking-confirmation': (context) => const BookingConfirmationPage(),
        '/payment': (context) => const PaymentScreen(),
        '/my-bookings': (context) => const MyBookingsScreen(),
        '/cancel-booking': (context) => const CancelBookingPage(),
        '/create-review': (context) => const CreateReviewPage(),
        
        // Host flow
        '/host-dashboard': (context) => const HostDashboardScreen(),
        '/host-booking-requests': (context) => const HostBookingRequestsScreen(),
        '/host-booking-detail': (context) => const HostBookingDetailScreen(),
        '/homestay-list': (context) => const HomestayListScreen(),
        '/homestay-status': (context) => const HomestayStatusScreen(),
        '/add-homestay-basic-info': (context) => const AddHomestayBasicInfoScreen(),
        '/add-homestay-location': (context) => const AddHomestayLocationScreen(),
        '/add-homestay-price-rules': (context) => const AddHomestayPriceRulesScreen(),
        
        // Author flow
        '/author-dashboard': (context) => const AuthorDashboardScreen(),
        '/article-list': (context) => const ArticleListScreen(),
        '/create-article': (context) => const CreateArticleScreen(),
        '/article-detail': (context) => const ArticleDetailScreen(),
        
        // Common
        '/profile': (context) => const ProfilePage(),
        '/notifications': (context) => const NotificationScreen(),
      },
    );
  }
}
