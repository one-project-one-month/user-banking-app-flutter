// Generated model for registration options (gender + nationality)
// Matches JSON shape:
// {
//   "genderOptions": [{"id":1,"name":"Male"}, ...],
//   "nationalityOptions": [{"id":1,"name":"Myanmar"}, ...]
// }

class OptionItem {
  final int id;
  final String name;

  OptionItem({required this.id, required this.name});

  factory OptionItem.fromJson(Map<String, dynamic> json) {
    return OptionItem(
      id:
          json['id'] is int
              ? json['id'] as int
              : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  String toString() => name;
}

class RegistrationOptions {
  final List<OptionItem> genderOptions;
  final List<OptionItem> nationalityOptions;

  RegistrationOptions({
    required this.genderOptions,
    required this.nationalityOptions,
  });

  factory RegistrationOptions.fromJson(Map<String, dynamic> json) {
    final genders = <OptionItem>[];
    final nations = <OptionItem>[];

    if (json['genderOptions'] is Iterable) {
      for (final e in json['genderOptions']) {
        if (e is Map<String, dynamic>) {
          genders.add(OptionItem.fromJson(e));
        } else if (e is Map) {
          genders.add(OptionItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    if (json['nationalityOptions'] is Iterable) {
      for (final e in json['nationalityOptions']) {
        if (e is Map<String, dynamic>) {
          nations.add(OptionItem.fromJson(e));
        } else if (e is Map) {
          nations.add(OptionItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return RegistrationOptions(
      genderOptions: genders,
      nationalityOptions: nations,
    );
  }

  Map<String, dynamic> toJson() => {
    'genderOptions': genderOptions.map((e) => e.toJson()).toList(),
    'nationalityOptions': nationalityOptions.map((e) => e.toJson()).toList(),
  };

  /// Convenience: empty/default instance
  static RegistrationOptions empty() =>
      RegistrationOptions(genderOptions: [], nationalityOptions: []);
}
