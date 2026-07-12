import 'package:go_router/go_router.dart';

import '../models/homestay_model.dart';
import '../models/booking_model.dart';

// Auth screens
import '../screens/auth/intro_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/choose_role_screen.dart';
import '../screens/auth/forgot_password_otp_screen.dart';

// Customer screens
import '../screens/customer/customer_home_screen.dart';
import '../screens/customer/homestay_detail_page.dart';
import '../screens/customer/filter_screen.dart';
import '../screens/customer/booking_form_screen.dart';
import '../screens/customer/booking_confirmation_page.dart';
import '../screens/customer/payment_screen.dart';
import '../screens/customer/my_bookings_screen.dart';
import '../screens/customer/cancel_booking_page.dart';
import '../screens/customer/create_review_page.dart';

// Host screens
import '../screens/host/host_dashboard_screen.dart';
import '../screens/host/host_booking_requests_screen.dart';
import '../screens/host/host_booking_detail_screen.dart';
import '../screens/host/homestay_list_screen.dart';
import '../screens/host/homestay_status_screen.dart';
import '../screens/host/add_homestay_basic_info_screen.dart';
import '../screens/host/add_homestay_location_screen.dart';
import '../screens/host/add_homestay_price_rules_screen.dart';

// Author screens
import '../screens/author/author_dashboard_screen.dart';
import '../screens/author/article_list_screen.dart';
import '../screens/author/create_article_screen.dart';
import '../screens/author/article_detail_screen.dart';

// Common screens
import '../screens/common/profile_page.dart';
import '../screens/common/edit_profile_screen.dart';
import '../screens/common/notification_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/intro',
  routes: [
    GoRoute(
      path: '/intro',
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/choose-role',
      builder: (context, state) => const ChooseRoleScreen(),
    ),
    GoRoute(
      path: '/forgot-password-otp',
      builder: (context, state) => const ForgotPasswordOtpScreen(),
    ),

    // Customer flow
    GoRoute(
      path: '/customer-home',
      builder: (context, state) {
        final initialIndex = state.extra as int? ?? 0;
        return CustomerHomeScreen(initialIndex: initialIndex);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/homestay-detail',
      builder: (context, state) {
        final homestay = state.extra as Homestay?;
        return HomestayDetailPage(homestay: homestay);
      },
    ),
    GoRoute(
      path: '/filter',
      builder: (context, state) => const FilterScreen(),
    ),
    GoRoute(
      path: '/booking-form',
      builder: (context, state) {
        final homestay = state.extra as Homestay?;
        return BookingFormScreen(homestay: homestay);
      },
    ),
    GoRoute(
      path: '/booking-confirmation',
      builder: (context, state) {
        final payload = state.extra as Map<String, dynamic>?;
        return BookingConfirmationPage(payload: payload);
      },
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) {
        final payload = state.extra as Map<String, dynamic>?;
        return PaymentScreen(payload: payload);
      },
    ),
    GoRoute(
      path: '/my-bookings',
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(
      path: '/cancel-booking',
      builder: (context, state) => const CancelBookingPage(),
    ),
    GoRoute(
      path: '/create-review',
      builder: (context, state) => const CreateReviewPage(),
    ),

    // Host flow
    GoRoute(
      path: '/host-dashboard',
      builder: (context, state) => const HostDashboardScreen(),
    ),
    GoRoute(
      path: '/host-booking-requests',
      builder: (context, state) => const HostBookingRequestsScreen(),
    ),
    GoRoute(
      path: '/host-booking-detail',
      builder: (context, state) {
        final booking = state.extra as BookingModel?;
        return HostBookingDetailScreen(booking: booking);
      },
    ),
    GoRoute(
      path: '/homestay-list',
      builder: (context, state) => const HomestayListScreen(),
    ),
    GoRoute(
      path: '/homestay-status',
      builder: (context, state) {
        final homestay = state.extra as Homestay?;
        return HomestayStatusScreen(homestay: homestay);
      },
    ),
    GoRoute(
      path: '/add-homestay-basic-info',
      builder: (context, state) => const AddHomestayBasicInfoScreen(),
    ),
    GoRoute(
      path: '/add-homestay-location',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return AddHomestayLocationScreen(args: args);
      },
    ),
    GoRoute(
      path: '/add-homestay-price-rules',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return AddHomestayPriceRulesScreen(args: args);
      },
    ),

    // Author flow
    GoRoute(
      path: '/author-dashboard',
      builder: (context, state) => const AuthorDashboardScreen(),
    ),
    GoRoute(
      path: '/article-list',
      builder: (context, state) => const ArticleListScreen(),
    ),
    GoRoute(
      path: '/create-article',
      builder: (context, state) => const CreateArticleScreen(),
    ),
    GoRoute(
      path: '/article-detail',
      builder: (context, state) {
        final article = state.extra as Map<String, dynamic>?;
        return ArticleDetailScreen(article: article);
      },
    ),

    // Common
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationScreen(),
    ),
  ],
);
