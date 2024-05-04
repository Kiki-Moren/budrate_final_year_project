enum Flavor {
  development,
  staging,
  production,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.development:
        return 'BUDRATE - Dev';
      case Flavor.staging:
        return 'BUDRATE - Staging';
      case Flavor.production:
        return 'BUDRATE';
      default:
        return 'title';
    }
  }

}
