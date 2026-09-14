// ============================================================================
// 1. DOMAIN LAYER (Pure Dart, Zero Flutter SDK imports)
// ============================================================================

// --- lib/domain/example/entities/example_item.dart ---
/*
import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_item.freezed.dart';

@freezed
class ExampleItem with _$ExampleItem {
  final String id;
  final String title;
  final String description;
  final bool isActive;

  const ExampleItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
  });
}
*/

// --- lib/domain/example/failures/example_failure.dart ---
/*
sealed class ExampleFailure {
  final String message;

  const ExampleFailure([this.message = 'An unexpected error occurred.']);
}

final class NetworkExampleFailure extends ExampleFailure {
  const NetworkExampleFailure([
    super.message = 'No internet connection or network request timed out.',
  ]);
}

final class ServerExampleFailure extends ExampleFailure {
  final int? statusCode;

  const ServerExampleFailure({
    String message = 'A server error occurred while processing the request.',
    this.statusCode,
  }) : super(message);
}

final class UnknownExampleFailure extends ExampleFailure {
  final Object? error;
  final StackTrace? stackTrace;

  const UnknownExampleFailure({
    String message = 'An unexpected error occurred.',
    this.error,
    this.stackTrace,
  }) : super(message);
}
*/

// --- lib/domain/example/repositories/i_example_repository.dart ---
/*
import 'package:flutter_template/domain/example/entities/example_item.dart';

abstract interface class IExampleRepository {
  Future<List<ExampleItem>> getExampleItems();
}
*/

// --- lib/domain/example/usecases/get_example_items_usecase.dart ---
/*
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/example/entities/example_item.dart';
import 'package:flutter_template/domain/example/repositories/i_example_repository.dart';

@injectable
class GetExampleItemsUseCase {
  final IExampleRepository _repository;

  const GetExampleItemsUseCase(this._repository);

  Future<List<ExampleItem>> call() {
    return _repository.getExampleItems();
  }
}
*/

// ============================================================================
// 2. DATA LAYER (DTOs, Retrofit Client, Repository Implementation)
// ============================================================================

// --- lib/data/example/endpoints/example_endpoints.dart ---
/*
abstract final class ExampleEndpoints {
  static const String items = '/v1/example-items';
}
*/

// --- lib/data/example/dto/example_item_dto.dart ---
/*
import 'package:json_annotation/json_annotation.dart';

import 'package:flutter_template/domain/example/entities/example_item.dart';

part 'example_item_dto.g.dart';

@JsonSerializable()
class ExampleItemDto {
  final String id;
  final String title;
  final String description;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;

  const ExampleItemDto({
    required this.id,
    required this.title,
    required this.description,
    required this.isActive,
  });

  factory ExampleItemDto.fromJson(Map<String, dynamic> json) =>
      _$ExampleItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExampleItemDtoToJson(this);

  /// Maps DTO directly to pure Domain Entity
  ExampleItem toDomain() => ExampleItem(
        id: id,
        title: title,
        description: description,
        isActive: isActive,
      );
}
*/

// --- lib/data/example/client/example_api_client.dart ---
/*
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import 'package:flutter_template/data/example/dto/example_item_dto.dart';
import 'package:flutter_template/data/example/endpoints/example_endpoints.dart';

part 'example_api_client.g.dart';

@RestApi()
abstract class ExampleApiClient {
  factory ExampleApiClient(Dio dio, {String baseUrl}) = _ExampleApiClient;

  @GET(ExampleEndpoints.items)
  Future<List<ExampleItemDto>> getExampleItems();
}
*/

// --- lib/data/example/repositories/example_repository_impl.dart ---
/*
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/data/example/client/example_api_client.dart';
import 'package:flutter_template/domain/example/entities/example_item.dart';
import 'package:flutter_template/domain/example/failures/example_failure.dart';
import 'package:flutter_template/domain/example/repositories/i_example_repository.dart';

@LazySingleton(as: IExampleRepository)
class ExampleRepositoryImpl implements IExampleRepository {
  final ExampleApiClient _apiClient;

  const ExampleRepositoryImpl(this._apiClient);

  @override
  Future<List<ExampleItem>> getExampleItems() async {
    try {
      final dtos = await _apiClient.getExampleItems();
      return dtos.map((dto) => dto.toDomain()).toList();
    } on DioException catch (dioError) {
      if (dioError.type == DioExceptionType.connectionTimeout ||
          dioError.type == DioExceptionType.receiveTimeout ||
          dioError.type == DioExceptionType.connectionError) {
        throw const NetworkExampleFailure();
      }
      final statusCode = dioError.response?.statusCode;
      throw ServerExampleFailure(
        message: dioError.message ?? 'Server error',
        statusCode: statusCode,
      );
    } catch (e, st) {
      throw UnknownExampleFailure(error: e, stackTrace: st);
    }
  }
}
*/

// ============================================================================
// 3. PRESENTATION LAYER (State Management & Pages)
// ============================================================================

// --- lib/presentation/state_management/example/example_state.dart ---
/*
import 'package:equatable/equatable.dart';

import 'package:flutter_template/domain/example/entities/example_item.dart';
import 'package:flutter_template/domain/example/failures/example_failure.dart';

sealed class ExampleState extends Equatable {
  const ExampleState();

  @override
  List<Object?> get props => [];
}

final class ExampleInitialState extends ExampleState {
  const ExampleInitialState();
}

final class ExampleInProgressState extends ExampleState {
  const ExampleInProgressState();
}

final class ExampleSuccessState extends ExampleState {
  final List<ExampleItem> items;

  const ExampleSuccessState(this.items);

  @override
  List<Object?> get props => [items];
}

final class ExampleFailureState extends ExampleState {
  final ExampleFailure failure;

  const ExampleFailureState(this.failure);

  @override
  List<Object?> get props => [failure];
}
*/

// --- lib/presentation/state_management/example/example_event.dart ---
/*
import 'package:equatable/equatable.dart';

sealed class ExampleEvent extends Equatable {
  const ExampleEvent();

  @override
  List<Object?> get props => [];
}

final class ExampleFetchRequested extends ExampleEvent {
  const ExampleFetchRequested();
}
*/

// --- lib/presentation/state_management/example/example_bloc.dart ---
/*
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_template/domain/example/failures/example_failure.dart';
import 'package:flutter_template/domain/example/usecases/get_example_items_usecase.dart';

part 'example_event.dart';
part 'example_state.dart';

@injectable
class ExampleBloc extends Bloc<ExampleEvent, ExampleState> {
  final GetExampleItemsUseCase _getExampleItemsUseCase;

  ExampleBloc(this._getExampleItemsUseCase)
      : super(const ExampleInitialState()) {
    on<ExampleFetchRequested>(
      _onFetchRequested,
      transformer: restartable(),
    );
  }

  Future<void> _onFetchRequested(
    ExampleFetchRequested event,
    Emitter<ExampleState> emit,
  ) async {
    emit(const ExampleInProgressState());
    try {
      final items = await _getExampleItemsUseCase();
      if (emit.isDone) return;
      emit(ExampleSuccessState(items));
    } on ExampleFailure catch (failure) {
      if (emit.isDone) return;
      addError(failure);
      emit(ExampleFailureState(failure));
    } catch (error, stackTrace) {
      if (emit.isDone) return;
      final failure = UnknownExampleFailure(error: error, stackTrace: stackTrace);
      addError(error, stackTrace);
      emit(ExampleFailureState(failure));
    }
  }
}
*/
