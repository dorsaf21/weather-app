import 'dart:math';

import 'package:weather1/core/either.dart';
import 'package:weather1/core/failure.dart';
import 'package:weather1/domain/entities/full_weather.dart';
import 'package:riverpod/riverpod.dart';

class FullWeatherMemoizedDataSource {
  FullWeather? _fullWeather;

  DateTime? _fetchingTime;

  static const _invalidationDuration = Duration(minutes: 10);

  Future<Either<Failure, FullWeather?>> getMemoizedFullWeather() async {
    if (_fullWeather == null) return const Right(null);

    if (DateTime.now().difference(_fetchingTime!) >= _invalidationDuration) {
      _fullWeather = null;
      _fetchingTime = null;
      return const Right(null);
    }

    // Minor delay so that users won't think the fetching is broken or
    // something.
    await Future<void>.delayed(
      Duration(
        milliseconds: 200 + Random().nextInt(800 - 200),
      ),
    );

    return Right(_fullWeather);
  }

  Future<Either<Failure, void>> setFullWeather(FullWeather fullWeather) async {
    _fetchingTime = DateTime.now();
    _fullWeather = fullWeather;
    return const Right(null);
  }
}

final fullWeatherMemoizedDataSourceProvider =
Provider((ref) => FullWeatherMemoizedDataSource());