/// Build-time configuration.
///
/// Nothing is hardcoded here. Both values come from `.env` at the repo root,
/// which is gitignored; `.env.example` shows the shape. Build with:
///
///   flutter run   --dart-define-from-file=../.env
///   flutter build apk --release --dart-define-from-file=../.env
///
/// The publishable (anon) key is designed to ship inside the client — it is
/// useless without a session, because Row Level Security decides what any
/// given user can read. Keeping it out of the repo is hygiene, not secrecy:
/// anyone can pull it back out of a release APK, so RLS is what actually
/// guards the data. The service-role / secret key must NEVER appear here or
/// anywhere else in this app; it bypasses RLS entirely.
///
/// Left unset, the app does not half-start against a project that is not
/// there — isSupabaseConfigured comes back false and main() stays on the mock
/// repository, which is the same path a field phone with no signal takes.
library;

class Env {
  Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Set to false to force the app back onto mock data, e.g. for a demo with
  /// no signal at all.
  static const useSupabase = bool.fromEnvironment(
    'USE_SUPABASE',
    defaultValue: true,
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
