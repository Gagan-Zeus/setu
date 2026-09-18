/// Build-time configuration.
///
/// The publishable (anon) key is designed to ship inside the client — Row
/// Level Security decides what any signed-in user can read. The service-role
/// key and the SMTP credentials must NEVER appear here: they live in
/// Supabase's server-side config, and anything in an APK is extractable.
///
/// Override per environment with:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
library;

class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://idngqijhodyahdgodybt.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_xncVWHE3-FItxOHmt9TtCQ_awa9FPch',
  );

  /// Set false to force the local-only sign-in path, e.g. for a demo with no
  /// signal at all.
  static const useSupabase = bool.fromEnvironment(
    'USE_SUPABASE',
    defaultValue: true,
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
