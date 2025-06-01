// features/splash/data/datasources/splash_remote_data_source.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class LocalAppSettingsRemoteDataSource {
  final SupabaseClient supabase;
  LocalAppSettingsRemoteDataSource(this.supabase);

  bool get isLoggedIn => supabase.auth.currentUser != null;
}
