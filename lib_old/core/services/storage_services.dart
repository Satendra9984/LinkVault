// lib/core/services/storage_service.dart
import 'package:isar/isar.dart';
import 'package:link_vault/src/app_initializaiton/data/models/settings_model.dart';
import 'package:link_vault/shared/data/models/user_profile_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  late final Isar _isar;
  late final SupabaseClient _supabaseClient;

  Future<void> initialize() async {
    await Future.wait(
      [
        _initializeSupabase(),
        _initializeIsar(),
      ],
    );
  }

  Future<void> _initializeSupabase() async {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'production');

    late final Supabase supabase;

    if (flavor == 'development') {
      supabase = await Supabase.initialize(
        url: 'https://nppcmheydvhbrvqygxed.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wcGNtaGV5ZHZoYnJ2cXlneGVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzODM0MjUsImV4cCI6MjA2MDk1OTQyNX0.T_LqK6VDuDlCGCWoiofXnCmaXqyjk-rLdpCWhMEWaT0',
      );
    } else {
      supabase = await Supabase.initialize(
        url: 'https://nppcmheydvhbrvqygxed.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wcGNtaGV5ZHZoYnJ2cXlneGVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzODM0MjUsImV4cCI6MjA2MDk1OTQyNX0.T_LqK6VDuDlCGCWoiofXnCmaXqyjk-rLdpCWhMEWaT0',
      );
    }
    
    _supabaseClient = supabase.client;
  }

  Future<void> _initializeIsar() async {
    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open(
      [
        IsarAppSettingsModelSchema,
        UserProfileModelSchema,
      ],
      directory: dir.path,
    );

    _isar = isar;
  }

  Isar get isar => _isar;
  SupabaseClient get supabaseClient => _supabaseClient;
}
