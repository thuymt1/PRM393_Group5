import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/supabase_provider.dart';
import 'auth_repository.dart';
import 'profile_repository.dart';
import 'host_application_repository.dart';
import 'homestay_repository.dart';
import 'booking_repository.dart';
import 'article_repository.dart';
import 'admin_repository.dart';
import 'notification_repository.dart';
import 'review_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(ref.watch(supabaseClientProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(ref.watch(supabaseClientProvider)),
);

final hostApplicationRepositoryProvider = Provider<HostApplicationRepository>(
  (ref) => SupabaseHostApplicationRepository(ref.watch(supabaseClientProvider)),
);

final homestayRepositoryProvider = Provider<HomestayRepository>(
  (ref) => SupabaseHomestayRepository(ref.watch(supabaseClientProvider)),
);

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => SupabaseBookingRepository(ref.watch(supabaseClientProvider)),
);

final articleRepositoryProvider = Provider<ArticleRepository>(
  (ref) => SupabaseArticleRepository(ref.watch(supabaseClientProvider)),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => SupabaseAdminRepository(ref.watch(supabaseClientProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => AppNotificationRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(profileRepositoryProvider),
    ref.watch(bookingRepositoryProvider),
  ),
);

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => SupabaseReviewRepository(ref.watch(supabaseClientProvider)),
);
