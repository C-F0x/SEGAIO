class Project {
  final String id;
  final String name;
  final String path;
  final String type;
  final String createdAt;
  int sortIndex;
  final int errState;

  Project({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.createdAt,
    required this.sortIndex,
    required this.errState,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    path: json['path'] ?? '',
    type: json['variety'] ?? '',
    createdAt: json['create_at'] ?? '',
    sortIndex: json['sort_index'] ?? 0,
    errState: json['err_state'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'variety': type,
    'create_at': createdAt,
    'sort_index': sortIndex,
    'err_state': errState,
  };
}