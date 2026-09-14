---
name: data-retrofit-clients
description: Standards and patterns for Retrofit REST API clients in lib/data/<feature>/client/ (or datasources/). Covers @RestApi interface definitions, [Feature]Endpoints static constants, HTTP annotations (@GET, @POST, @Path, @Queries, @Body), CancelToken request lifecycle, and DI registration.
---

# Retrofit REST API Clients & Endpoints

## 1. Overview & When to Apply

Use this skill whenever:
- Defining Retrofit HTTP service clients (`lib/data/<feature>/client/` or `datasources/`).
- Organizing API route constants in `lib/data/<feature>/endpoints/`.
- Configuring HTTP annotations (`@GET`, `@POST`, `@PUT`, `@DELETE`, `@PATCH`, `@Path`, `@Queries`, `@Body`, `@Header`).
- Supporting request cancellation via `@CancelRequest() CancelToken? cancelToken`.
- Registering Retrofit clients in GetIt using `@lazySingleton` and `@factoryMethod`.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [data-hub](../data-hub/SKILL.md) | Data layer architecture and client rules. |
| **Dio Network** | [infrastructure-network-dio](../../infrastructure/infrastructure-network-dio/SKILL.md) | Primary `Dio` instance injected into Retrofit clients. |
| **DTOs & Mappers** | [data-dto-mappers](../data-dto-mappers/SKILL.md) | DTO models returned by client methods. |
| **Build Runner** | [flutter-build-runner](../../flutter-build-runner/SKILL.md) | Generating `*.g.dart` Retrofit client code. |

---

## 3. Endpoints Class Standard (`lib/data/<feature>/endpoints/`)

Never hardcode path strings directly across multiple client methods. Centralize them in dedicated endpoint classes:

```dart
abstract final class ItemEndpoints {
  static const String items = '/items';
  static const String itemDetails = '/items/{id}';
  static const String searchItems = '/items/search';
  static const String updateItem = '/items/{id}';
}
```

---

## 4. Standard Retrofit Client Interface Pattern

```dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import 'package:flutter_template/data/items/dto/item_dto.dart';
import 'package:flutter_template/data/items/dto/item_response_dto.dart';
import 'package:flutter_template/data/items/dto/update_item_request_dto.dart';
import 'package:flutter_template/data/items/endpoints/item_endpoints.dart';

part 'item_api_client.g.dart';

@lazySingleton
@RestApi()
abstract class ItemApiClient {
  @factoryMethod
  factory ItemApiClient(Dio dio) = _ItemApiClient;

  @GET(ItemEndpoints.items)
  Future<ItemResponseDto> getItems({
    @Query('page') int page = 1,
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET(ItemEndpoints.itemDetails)
  Future<ItemDto> getItemDetails(
    @Path('id') String id, {
    @CancelRequest() CancelToken? cancelToken,
  });

  @GET(ItemEndpoints.searchItems)
  Future<ItemResponseDto> searchItems(
    @Query('query') String query, {
    @Query('page') int page = 1,
    @CancelRequest() CancelToken? cancelToken,
  });

  @PUT(ItemEndpoints.updateItem)
  Future<void> updateItem(
    @Path('id') String id,
    @Body() UpdateItemRequestDto request, {
    @CancelRequest() CancelToken? cancelToken,
  });
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Hardcoding URL paths directly in `@GET('/items')` | **HIGH** | Reference `ItemEndpoints.items` constant. |
| Returning Domain Entities directly from Retrofit interfaces | **HIGH** | Retrofit interfaces must return DTOs; mapping happens in Repository. |
| Omitting `@factoryMethod` causing Injectable generation failure | **HIGH** | Include `factory Client(Dio dio) = _Client;` with `@factoryMethod`. |
| Missing `part '<name>.g.dart';` directive | **CRITICAL** | Add `part '<name>.g.dart';` and run `build_runner`. |

---

## 6. Verification Checklist

- [ ] Route paths are centralized in `[Feature]Endpoints`.
- [ ] Client interface is annotated with `@lazySingleton` and `@RestApi()`.
- [ ] Factory constructor includes `@factoryMethod`.
- [ ] Code generation generates `*.g.dart` cleanly.
- [ ] Search/paginated endpoints support optional `@CancelRequest() CancelToken? cancelToken`.
