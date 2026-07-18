import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/supabase_provider.dart';
import 'auth_repository.dart';
import 'profile_repository.dart';
import 'host_application_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(ref.watch(supabaseClientProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(ref.watch(supabaseClientProvider)),
);

final hostApplicationRepositoryProvider = Provider<HostApplicationRepository>(
  (ref) => SupabaseHostApplicationRepository(ref.watch(supabaseClientProvider)),
);
