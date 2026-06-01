#!/usr/bin/env bash
#
# create_feature.sh — scaffold a new clean-architecture feature.
#
# Usage:
#   ./create_feature.sh [--with-test] <feature_name>   # e.g. ... auth
#
# Generates lib/features/<feature_name>/ with the full data / domain /
# presentation layering used by the live_stream feature, then formats it.
# With --with-test (-t) it also scaffolds test/features/<feature_name>/ with a
# cubit test (bloc_test) and a repository test (mocktail).
# It does NOT touch DI or the router — it prints the snippets to paste.

set -euo pipefail

# ---- Colours -------------------------------------------------------------
if [ -t 1 ]; then
  BOLD=$(printf '\033[1m'); GREEN=$(printf '\033[32m')
  CYAN=$(printf '\033[36m'); RED=$(printf '\033[31m')
  DIM=$(printf '\033[2m'); RESET=$(printf '\033[0m')
else
  BOLD=""; GREEN=""; CYAN=""; RED=""; DIM=""; RESET=""
fi

die() { printf '%s%sError:%s %s\n' "$BOLD" "$RED" "$RESET" "$1" >&2; exit 1; }

# ---- Parse args ----------------------------------------------------------
with_test=0
feature=""
for arg in "$@"; do
  case "$arg" in
    --with-test|-t) with_test=1 ;;
    -*) die "unknown option: $arg\n  Usage: ./create_feature.sh [--with-test] <feature_name>" ;;
    *)
      [ -z "$feature" ] || die "unexpected extra argument: '$arg'"
      feature="$arg" ;;
  esac
done

# ---- Validate input & environment ---------------------------------------
[ -n "$feature" ] || die "missing <feature_name>.\n  Usage: ./create_feature.sh [--with-test] <feature_name>"
[ -f pubspec.yaml ] || die "run this from the project root (no pubspec.yaml here)."

case "$feature" in
  [a-z]*[a-z0-9]|[a-z]) : ;;
  *) die "feature name must be snake_case (lowercase, start with a letter): got '$feature'." ;;
esac
printf '%s' "$feature" | grep -Eq '^[a-z][a-z0-9_]*$' \
  || die "feature name must be snake_case (a-z, 0-9, _): got '$feature'."

# Package name from pubspec, e.g. flutter_stream_hive_app.
pkg=$(awk '/^name:/{print $2; exit}' pubspec.yaml)
[ -n "$pkg" ] || die "could not read package name from pubspec.yaml."

# snake_case -> PascalCase (BSD/macOS-safe; no \U, no bash 4).
pascal=$(printf '%s' "$feature" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' OFS='')

root="lib/features/$feature"
[ -e "$root" ] && die "feature already exists at $root"

printf '%s%s▸ Creating feature '%s'%s  %s(%s)%s\n' "$BOLD" "$CYAN" "$feature" "$RESET" "$DIM" "$pascal" "$RESET"

mkdir -p \
  "$root/data/datasources" "$root/data/models" "$root/data/repositories" \
  "$root/domain/entities" "$root/domain/repositories" "$root/domain/usecases" \
  "$root/presentation/cubit" "$root/presentation/view" "$root/presentation/widgets"

# ---- domain/entities/<feature>.dart -------------------------------------
cat > "$root/domain/entities/$feature.dart" <<EOF
import 'package:equatable/equatable.dart';

/// ${pascal} domain entity. Pure Dart — no JSON, no Flutter.
class ${pascal} extends Equatable {
  const ${pascal}({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
EOF

# ---- domain/repositories/<feature>_repository.dart ----------------------
cat > "$root/domain/repositories/${feature}_repository.dart" <<EOF
import 'package:$pkg/core/error/failures.dart';
import 'package:$pkg/features/$feature/domain/entities/$feature.dart';
import 'package:fpdart/fpdart.dart';

/// Contract the domain needs; implemented in the data layer.
// ignore: one_member_abstracts
abstract class ${pascal}Repository {
  Future<Either<Failure, List<${pascal}>>> getAll();
}
EOF

# ---- domain/usecases/get_<feature>_list.dart ----------------------------
cat > "$root/domain/usecases/get_${feature}_list.dart" <<EOF
import 'package:$pkg/core/error/failures.dart';
import 'package:$pkg/core/usecase/usecase.dart';
import 'package:$pkg/features/$feature/domain/entities/$feature.dart';
import 'package:$pkg/features/$feature/domain/repositories/${feature}_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Fetches all ${pascal} items.
class Get${pascal}List extends UseCase<List<${pascal}>, NoParams> {
  const Get${pascal}List(this._repository);

  final ${pascal}Repository _repository;

  @override
  Future<Either<Failure, List<${pascal}>>> call(NoParams params) {
    return _repository.getAll();
  }
}
EOF

# ---- data/models/<feature>_dto.dart -------------------------------------
cat > "$root/data/models/${feature}_dto.dart" <<EOF
import 'package:$pkg/features/$feature/domain/entities/$feature.dart';

/// Wire format for the ${pascal} entity (knows JSON; maps via toEntity()).
class ${pascal}Dto {
  const ${pascal}Dto({required this.id, required this.name});

  factory ${pascal}Dto.fromJson(Map<String, dynamic> json) {
    return ${pascal}Dto(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
    );
  }

  final String id;
  final String name;

  ${pascal} toEntity() => ${pascal}(id: id, name: name);
}
EOF

# ---- data/datasources/<feature>_remote_data_source.dart -----------------
cat > "$root/data/datasources/${feature}_remote_data_source.dart" <<EOF
import 'package:dio/dio.dart';
import 'package:$pkg/core/error/exceptions.dart';
import 'package:$pkg/features/$feature/data/models/${feature}_dto.dart';

/// Raw remote (HTTP) access for ${pascal}. Throws on failure.
// ignore: one_member_abstracts
abstract class ${pascal}RemoteDataSource {
  Future<List<${pascal}Dto>> getAll();
}

class ${pascal}RemoteDataSourceImpl implements ${pascal}RemoteDataSource {
  const ${pascal}RemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<${pascal}Dto>> getAll() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/$feature');
      final data = response.data?['data'] as List<dynamic>? ?? <dynamic>[];
      return data
          .map((e) => ${pascal}Dto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Request failed',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
EOF

# ---- data/repositories/<feature>_repository_impl.dart -------------------
cat > "$root/data/repositories/${feature}_repository_impl.dart" <<EOF
import 'package:$pkg/core/error/exceptions.dart';
import 'package:$pkg/core/error/failures.dart';
import 'package:$pkg/features/$feature/data/datasources/${feature}_remote_data_source.dart';
import 'package:$pkg/features/$feature/domain/entities/$feature.dart';
import 'package:$pkg/features/$feature/domain/repositories/${feature}_repository.dart';
import 'package:fpdart/fpdart.dart';

class ${pascal}RepositoryImpl implements ${pascal}Repository {
  const ${pascal}RepositoryImpl({required ${pascal}RemoteDataSource remote})
    : _remote = remote;

  final ${pascal}RemoteDataSource _remote;

  @override
  Future<Either<Failure, List<${pascal}>>> getAll() async {
    try {
      final dtos = await _remote.getAll();
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception {
      return const Left(UnknownFailure());
    }
  }
}
EOF

# ---- presentation/cubit/<feature>_state.dart ----------------------------
cat > "$root/presentation/cubit/${feature}_state.dart" <<EOF
part of '${feature}_cubit.dart';

enum ${pascal}Status { initial, loading, success, failure }

class ${pascal}State extends Equatable {
  const ${pascal}State({
    this.status = ${pascal}Status.initial,
    this.items = const [],
    this.errorMessage,
  });

  final ${pascal}Status status;
  final List<${pascal}> items;
  final String? errorMessage;

  ${pascal}State copyWith({
    ${pascal}Status? status,
    List<${pascal}>? items,
    String? errorMessage,
  }) {
    return ${pascal}State(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
EOF

# ---- presentation/cubit/<feature>_cubit.dart ----------------------------
cat > "$root/presentation/cubit/${feature}_cubit.dart" <<EOF
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:$pkg/core/usecase/usecase.dart';
import 'package:$pkg/features/$feature/domain/entities/$feature.dart';
import 'package:$pkg/features/$feature/domain/usecases/get_${feature}_list.dart';

part '${feature}_state.dart';

class ${pascal}Cubit extends Cubit<${pascal}State> {
  ${pascal}Cubit({required Get${pascal}List get${pascal}List})
    : _get${pascal}List = get${pascal}List,
      super(const ${pascal}State());

  final Get${pascal}List _get${pascal}List;

  Future<void> load() async {
    emit(state.copyWith(status: ${pascal}Status.loading));
    final result = await _get${pascal}List(const NoParams());
    result.fold(
      (failure) => emit(
        ${pascal}State(
          status: ${pascal}Status.failure,
          errorMessage: failure.message,
        ),
      ),
      (items) => emit(
        ${pascal}State(status: ${pascal}Status.success, items: items),
      ),
    );
  }
}
EOF

# ---- presentation/view/<feature>_page.dart ------------------------------
cat > "$root/presentation/view/${feature}_page.dart" <<EOF
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:$pkg/core/di/injection.dart';
import 'package:$pkg/features/$feature/presentation/cubit/${feature}_cubit.dart';

class ${pascal}Page extends StatelessWidget {
  const ${pascal}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<${pascal}Cubit>();
        unawaited(cubit.load());
        return cubit;
      },
      child: const ${pascal}View(),
    );
  }
}

class ${pascal}View extends StatelessWidget {
  const ${pascal}View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${pascal}')),
      body: BlocBuilder<${pascal}Cubit, ${pascal}State>(
        builder: (context, state) {
          switch (state.status) {
            case ${pascal}Status.initial:
            case ${pascal}Status.loading:
              return const Center(child: CircularProgressIndicator());
            case ${pascal}Status.failure:
              return Center(
                child: Text(state.errorMessage ?? 'Something went wrong.'),
              );
            case ${pascal}Status.success:
              if (state.items.isEmpty) {
                return const Center(child: Text('Nothing here yet.'));
              }
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ListTile(title: Text(item.name));
                },
              );
          }
        },
      ),
    );
  }
}
EOF

# ---- <feature>.dart (barrel) --------------------------------------------
cat > "$root/$feature.dart" <<EOF
/// Public surface of the $feature feature.
library;

export 'domain/entities/$feature.dart';
export 'presentation/cubit/${feature}_cubit.dart';
export 'presentation/view/${feature}_page.dart';
EOF

# ---- Tests (optional, --with-test) --------------------------------------
troot="test/features/$feature"
if [ "$with_test" -eq 1 ]; then
  mkdir -p "$troot/presentation/cubit" "$troot/data/repositories"

  # cubit test — mocks the use case, verifies state transitions via bloc_test.
  cat > "$troot/presentation/cubit/${feature}_cubit_test.dart" <<EOF
import 'package:bloc_test/bloc_test.dart';
import 'package:$pkg/core/error/failures.dart';
import 'package:$pkg/core/usecase/usecase.dart';
import 'package:$pkg/features/$feature/domain/entities/$feature.dart';
import 'package:$pkg/features/$feature/domain/usecases/get_${feature}_list.dart';
import 'package:$pkg/features/$feature/presentation/cubit/${feature}_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockGet${pascal}List extends Mock implements Get${pascal}List {}

void main() {
  late _MockGet${pascal}List get${pascal}List;

  const items = [${pascal}(id: '1', name: 'Sample')];

  setUpAll(() => registerFallbackValue(const NoParams()));
  setUp(() => get${pascal}List = _MockGet${pascal}List());

  group('${pascal}Cubit', () {
    blocTest<${pascal}Cubit, ${pascal}State>(
      'emits [loading, success] when the use case returns items',
      build: () {
        when(() => get${pascal}List(any()))
            .thenAnswer((_) async => const Right(items));
        return ${pascal}Cubit(get${pascal}List: get${pascal}List);
      },
      act: (cubit) => cubit.load(),
      expect: () => const [
        ${pascal}State(status: ${pascal}Status.loading),
        ${pascal}State(status: ${pascal}Status.success, items: items),
      ],
    );

    blocTest<${pascal}Cubit, ${pascal}State>(
      'emits [loading, failure] when the use case returns a Failure',
      build: () {
        when(() => get${pascal}List(any()))
            .thenAnswer((_) async => const Left(ServerFailure('boom')));
        return ${pascal}Cubit(get${pascal}List: get${pascal}List);
      },
      act: (cubit) => cubit.load(),
      expect: () => const [
        ${pascal}State(status: ${pascal}Status.loading),
        ${pascal}State(status: ${pascal}Status.failure, errorMessage: 'boom'),
      ],
    );
  });
}
EOF

  # repository test — mocks the data source, verifies DTO->entity + error map.
  cat > "$troot/data/repositories/${feature}_repository_impl_test.dart" <<EOF
import 'package:$pkg/core/error/exceptions.dart';
import 'package:$pkg/core/error/failures.dart';
import 'package:$pkg/features/$feature/data/datasources/${feature}_remote_data_source.dart';
import 'package:$pkg/features/$feature/data/models/${feature}_dto.dart';
import 'package:$pkg/features/$feature/data/repositories/${feature}_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements ${pascal}RemoteDataSource {}

void main() {
  late _MockRemote remote;
  late ${pascal}RepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = ${pascal}RepositoryImpl(remote: remote);
  });

  group('${pascal}RepositoryImpl.getAll', () {
    test('maps DTOs to entities on success', () async {
      when(() => remote.getAll()).thenAnswer(
        (_) async => const [${pascal}Dto(id: '1', name: 'Sample')],
      );

      final result = await repository.getAll();

      expect(result.isRight(), isTrue);
      final items = result.getRight().toNullable()!;
      expect(items.single.id, '1');
      expect(items.single.name, 'Sample');
    });

    test('returns ServerFailure when the data source throws', () async {
      when(() => remote.getAll()).thenThrow(const ServerException(message: 'x'));

      final result = await repository.getAll();

      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), const ServerFailure('x'));
    });
  });
}
EOF

  if command -v dart >/dev/null 2>&1; then
    dart format "$troot" >/dev/null 2>&1 || true
  fi
fi

# ---- Format (best-effort) -----------------------------------------------
if command -v dart >/dev/null 2>&1; then
  dart format "$root" >/dev/null 2>&1 || true
fi

# ---- Report --------------------------------------------------------------
file_count=$(find "$root" -name '*.dart' | wc -l | tr -d ' ')
printf '%s%s✓ Created %s Dart files under %s%s\n' "$BOLD" "$GREEN" "$file_count" "$root" "$RESET"
if [ "$with_test" -eq 1 ]; then
  test_count=$(find "$troot" -name '*.dart' | wc -l | tr -d ' ')
  printf '%s%s✓ Created %s test files under %s%s\n' "$BOLD" "$GREEN" "$test_count" "$troot" "$RESET"
fi
printf '\n'

printf '%s%sNext steps%s\n' "$BOLD" "$CYAN" "$RESET"
printf '%s1.%s Register in %slib/core/di/injection.dart%s (inside the getIt cascade):\n' "$BOLD" "$RESET" "$DIM" "$RESET"
cat <<EOF
    ..registerLazySingleton<${pascal}RemoteDataSource>(
      () => ${pascal}RemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<${pascal}Repository>(
      () => ${pascal}RepositoryImpl(remote: getIt()),
    )
    ..registerFactory(() => Get${pascal}List(getIt()))
    ..registerFactory(() => ${pascal}Cubit(get${pascal}List: getIt()))
EOF
printf '\n%s2.%s Add a route in %slib/core/router/app_router.dart%s:\n' "$BOLD" "$RESET" "$DIM" "$RESET"
cat <<EOF
    GoRoute(
      path: '$feature',
      name: '$feature',
      builder: (context, state) => const ${pascal}Page(),
    ),
EOF
printf '\n%s3.%s Run %sflutter analyze%s to confirm everything wires up.\n' "$BOLD" "$RESET" "$DIM" "$RESET"
if [ "$with_test" -eq 1 ]; then
  printf '%s4.%s Run %sflutter test %s%s to run the generated tests.\n' "$BOLD" "$RESET" "$DIM" "$troot" "$RESET"
fi
