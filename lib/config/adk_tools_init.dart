import 'app_config.dart';

class ADKTools {
  static init({
    /// [REQUIRED] Mengatur base url Development
    required String urlDev,

    /// [OPTIONAL] Mengatur base url Stagging
    String? urlStag,

    /// [OPTIONAL] Mengatur base url Production
    String? urlProd,

    /// [REQUIRED] Mengatur Apikey
    required String apiKey,

    /// [REQUIRED] Mengatur Apikey
    required String appName,

    /// [REQUIRED] Mengatur Mode Flavor
    required Flavor appFlavor,

    /// [OPTIONAL] Mengatur base url Production
    String? boxToken,
  }) {
    ADKTools.urlDev = urlDev;
    urlStag != null ? ADKTools.urlStag = urlStag : ADKTools.urlStag = urlDev;
    urlProd != null ? ADKTools.urlProd = urlProd : ADKTools.urlProd = urlDev;

    ADKTools.apiKey = apiKey;
    ADKTools.appName = appName;
    ADKTools.appFlavor = appFlavor;

    if (boxToken != null) ADKTools.boxToken = boxToken;
  }

  static String urlDev = "http://localhost:3000";
  static String urlStag = "http://localhost:3000";
  static String urlProd = "http://localhost:3000";

  static String apiKey = "ajianaz.dev";
  static String appName = "APPNAME";
  static Flavor appFlavor = Flavor.development;

  static String boxToken = "token";
}
