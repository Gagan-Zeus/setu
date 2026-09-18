/// Build-time configuration.
///
/// The publishable (anon) key is designed to ship inside the client — it is
/// useless without a session, because Row Level Security decides what any
/// given user can read. The service-role / secret key must NEVER appear here
/// or anywhere else in this app: it bypasses RLS entirely and anyone can pull
/// it back out of a release APK.
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

  /// Set to false to force the app back onto mock data, e.g. for a demo with
  /// no signal at all.
  static const useSupabase = bool.fromEnvironment(
    'USE_SUPABASE',
    defaultValue: true,
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
