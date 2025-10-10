import 'package:equatable/equatable.dart';
import 'package:tokitracker/features/home/domain/entities/base_mode.dart';

class Episode extends Equatable {
  final int id;
  final String name;
  final String? date;
  final BaseMode baseMode;
  final String? offlinePath; // For offline mode support

  const Episode({
    required this.id,
    required this.name,
    this.date,
    required this.baseMode,
    this.offlinePath,
  });

  String getUrl() => '/${baseMode.toUrlPath()}/$id';

  bool get isOffline => offlinePath != null && offlinePath!.isNotEmpty;

  @override
  List<Object?> get props => [id, name, date, baseMode, offlinePath];
}
