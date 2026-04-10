/// Single source of truth for all hard-coded configuration values.
/// Swap these out per environment; never scatter them across the codebase.
class AppConstants {
  AppConstants._();

  static const String jitsiAppId =
      'vpaas-magic-cookie-2c7a81b33b4943b396ee51b15e180056';

  static const String googleServerClientId =
      '1066416141379-luek5jjso4cdrf7jrr8inn4gdiv27hbm.apps.googleusercontent.com';

  static const String appShareUrl = 'https://meet-up-app-kappa.vercel.app/';
  static const String jitsiServerUrl = 'https://8x8.vc';
}