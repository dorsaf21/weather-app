import 'package:weather1/core/either.dart';
import 'package:weather1/core/failure.dart';
import 'package:weather1/data/data_sources/full_weather_memoized_data_source.dart';
import 'package:weather1/data/data_sources/full_weather_remote_data_source.dart';
import 'package:weather1/data/provider.dart';
import 'package:weather1/domain/entities/city.dart';
import 'package:weather1/domain/entities/full_weather.dart';
import 'package:weather1/domain/repos/full_weather_repo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod/riverpod.dart';

class _FullWeatherRepoImpl implements FullWeatherRepo {
  _FullWeatherRepoImpl(
      this._remoteDataSource,
      this._memoizedDataSource,
      this._connectivity,
      );

  final FullWeatherRemoteDataSource _remoteDataSource;

  final FullWeatherMemoizedDataSource _memoizedDataSource;

  final Connectivity _connectivity;

  @override
  Future<Either<Failure, FullWeather>> getFullWeather(City city) async {
    if (await _connectivity.checkConnectivity() == ConnectivityResult.none) {
      return const Left(NoConnection());
    } else {
      final memoizedWeather =
      await _memoizedDataSource.getMemoizedFullWeather();

      if (memoizedWeather is Left ||
          memoizedWeather.all(
                (weather) => weather != null && weather.city.name == city.name,
          )) {
        return memoizedWeather.map((weather) => weather!);
      }

      final weather = (await _remoteDataSource.getFullWeather(city))
          .map((model) => model.fullWeather);

      await weather
          .map<Future<void>>(_memoizedDataSource.setFullWeather)
          .getOrElse(() async {});

      return weather;
    }
  }
}

final fullWeatherRepoImplProvider = Provider<FullWeatherRepo>(
      (ref) => _FullWeatherRepoImpl(
    ref.watch(fullWeatherRemoteDataSourceProvider),
    ref.watch(fullWeatherMemoizedDataSourceProvider),
    ref.watch(connectivityProvider),
  ),
);