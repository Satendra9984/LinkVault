// features/splash/data/datasources/splash_remote_data_source.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SplashRemoteDataSource {
  final SupabaseClient supabase;
  SplashRemoteDataSource(this.supabase);

  bool get isLoggedIn => supabase.auth.currentUser != null;
}
