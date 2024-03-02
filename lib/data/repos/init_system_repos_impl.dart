import 'package:weather1/core/either.dart';
import 'package:weather1/core/failure.dart';
import 'package:weather1/data/data_sources/unit_systeme_local_data_source.dart';
import 'package:weather1/data/models/unit_system_model.dart';
import 'package:weather1/domain/entities/unit_system.dart';
import 'package:weather1/domain/repos/unit_system_repo.dart';
import 'package:riverpod/riverpod.dart';

class UnitSystemRepoImpl implements UnitSystemRepo {
  UnitSystemRepoImpl(this._localDataSource);

  final UnitSystemLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, UnitSystem>> getUnitSystem() async =>
      (await _localDataSource.getUnitSystem())
          .map((model) => model?.unitSystem ?? UnitSystem.metric);

  @override
  Future<Either<Failure, void>> setUnitSystem(UnitSystem unitSystem) =>
      _localDataSource.setUnitSystem(UnitSystemModel(unitSystem));
}

final unitSystemRepoImplProvider = Provider(
      (ref) => UnitSystemRepoImpl(ref.watch(unitSystemLocalDataSourceProvider)),
);