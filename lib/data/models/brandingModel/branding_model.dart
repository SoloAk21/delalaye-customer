class Branding {
  final int id;
  final String logoLight;
  final String logoDark;
  final String primaryColor;
  final String secondaryColor;
  final bool darkModeDefault;

  Branding({
    required this.id,
    required this.logoLight,
    required this.logoDark,
    required this.primaryColor,
    required this.secondaryColor,
    required this.darkModeDefault,
  });

  factory Branding.fromJson(Map<String, dynamic> json) => Branding(
        id: json['id'],
        logoLight: json['logoLight'],
        logoDark: json['logoDark'],
        primaryColor: json['primaryColor'],
        secondaryColor: json['secondaryColor'],
        darkModeDefault: json['darkModeDefault'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'logoLight': logoLight,
        'logoDark': logoDark,
        'primaryColor': primaryColor,
        'secondaryColor': secondaryColor,
        'darkModeDefault': darkModeDefault,
      };
}
