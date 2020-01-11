import "dart:async";
import 'package:mockito/mockito.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql_exec/gql_exec.dart';
import "package:test/test.dart";
import 'package:normalize/normalize.dart';

import '../example/lib/graphql_api.dart';
import '../lib/src/client/client.dart';
import '../lib/src/client/query_request.dart';
import '../lib/src/cache/cache.dart';
import '../lib/src/helpers/deep_merge.dart';

class MockLink extends Mock implements Link {}

enum Source {
  Cache,
  Network,
}

void main() {
  group("Update Results", () {
    final mockLink = MockLink();

    final queryRequests = [
      QueryRequest(query: SongsQuery(variables: SongsArguments(first: 3))),
      QueryRequest(
        query: SongsQuery(variables: SongsArguments(first: 3, offset: 3)),
      ),
    ];

    final networkRequests = queryRequests
        .map((request) => Request(
            operation: Operation(
              document: request.query.document,
              operationName: request.query.operationName,
            ),
            variables: request.query.getVariablesMap()))
        .toList();

    Map<String, List<Map<String, dynamic>>> getResponse(
        SongsQuery query, Source source) {
      final List<Map<String, dynamic>> songs = [];
      for (var i = 0; i < query.variables.first; i++) {
        final id = (i + (query.variables.offset ?? 0)).toString();
        songs.add(
            {"id": id, "name": "Song $id from $source", "__typename": "Song"});
      }
      return {"Song": songs};
    }

    final networkResponses = queryRequests
        .map((request) => getResponse(request.query, Source.Network))
        .toList();

    final cacheResponses = queryRequests
        .map((request) => getResponse(request.query, Source.Cache))
        .toList();

    for (var i = 0; i < networkRequests.length; i++) {
      when(mockLink.request(networkRequests[i], any)).thenAnswer(
          (_) => Stream.fromIterable([Response(data: networkResponses[i])]));
    }

    Map<String, Map<String, dynamic>> cacheSnapshot(Source source) =>
        queryRequests.fold<Map<String, Map<String, dynamic>>>({},
            (cachedData, request) {
          final data = getResponse(request.query, source);
          final queryResult = normalize(
              query: request.query.document,
              operationName: request.query.operationName,
              variables: request.query.getVariablesMap(),
              data: data);
          return Map.from(deepMerge(cachedData, queryResult));
        });

    test('Returns the correct result', () async {
      final cache = GQLCache(seedData: cacheSnapshot(Source.Cache));

      final client = GQLClient(
          link: mockLink,
          cache: cache,
          defaultFetchPolicy: FetchPolicy.NetworkOnly);

      final query1 = QueryRequest<Songs, SongsArguments>(
          query: SongsQuery(variables: SongsArguments(first: 3)));
      final query2 = QueryRequest<Songs, SongsArguments>(
          query: SongsQuery(variables: SongsArguments(first: 3, offset: 3)),
          options: QueryOptions<Songs, SongsArguments>(
              updateResult: (previous, result) {
            result.Song = [...previous.Song, ...result.Song];
            return result;
          }));

      final responseStream = client.responseStream(query1);

      // expect(responseStream.map((response) => response.data.toJson()),
      //     emitsInOrder(networkResponses));

      responseStream.listen((response) {
        print(response.data.Song);
      });

      client.queryController.add(query1);
      await Future.delayed(Duration.zero);

      client.queryController.add(query2);
      await Future.delayed(Duration.zero);

      expect(cache.data, equals(cacheSnapshot(Source.Network)));
    });
  });
}
