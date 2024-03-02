import 'dart:convert';

import 'package:weather1/core/either.dart';
import 'package:weather1/core/failure.dart';
import 'package:weather1/core/functions.dart';
import 'package:weather1/data/models/geographic_coordinates_model.dart';
import 'package:weather1/data/repos/api_key_repos.dart';
import 'package:weather1/domain/entities/city.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';

class GeocodingRemoteDataSource {
  GeocodingRemoteDataSource(this._apiKeyRepo);

  final ApiKeyRepo _apiKeyRepo;

  Future<Either<Failure, GeographicCoordinatesModel>> getCoordinates(
      City city,
      ) async {
    final apiKeyModel = (await _apiKeyRepo.getApiKey()).fold((_) => null, id)!;

    final response = await http.get(
      Uri(
        scheme: 'https',
        host: 'api.openweathermap.org',
        path: '/geo/1.0/direct',
        queryParameters: {
          'q': city.name,
          'appid': apiKeyModel.apiKey,
          'limit': '1',
        },
      ),
    );

    switch (response.statusCode) {
      case 503:
        return const Left(ServerDown());

      case 429:
        return const Left(CallLimitExceeded());
    }

    dynamic body;

    try {
      body = jsonDecode(response.body);
    } on FormatException {
      return const Left(FailedToParseResponse());
    }

    if (body is List) {
      if (body.isEmpty) {
        return Left(InvalidCityName(city.name));
      }

      return Right(GeographicCoordinatesModel.fromRemoteJson(body));
    } else {
      // TODO: I don't think this failure is fit for this situation.
      return const Left(FailedToParseResponse());
    }
  }
}

final geocodingRemoteDataSourceProvider =
Provider((ref) => GeocodingRemoteDataSource(ref.watch(apiKeyRepoProvider)));