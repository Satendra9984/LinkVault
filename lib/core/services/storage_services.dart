// lib/core/services/storage_service.dart
import 'package:isar/isar.dart';
import 'package:link_vault/src/splash/data/models/settings_model.dart';
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
        anonKey: 'public-anon-key',
      );
    } else {
      supabase = await Supabase.initialize(
        url: 'https://nppcmheydvhbrvqygxed.supabase.co',
        anonKey: 'public-anon-key',
      );
    }
    
    _supabaseClient = supabase.client;
  }

  Future<void> _initializeIsar() async {
    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open(
      [
        IsarAppSettingsModelSchema,
      ],
      directory: dir.path,
    );

    _isar = isar;
  }

  Isar get isar => _isar;
  SupabaseClient get supabaseClient => _supabaseClient;
}
