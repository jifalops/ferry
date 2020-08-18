import "dart:async";
import 'package:mockito/mockito.dart';
import 'package:gql_link/gql_link.dart';
import 'package:gql_exec/gql_exec.dart';
import "package:ferry/ferry.dart";
import 'package:test/test.dart';

import '../../test_graphql/lib/queries/variables/human_with_args.req.gql.dart';

class MockLink extends Mock implements Link {}

void main() {
  group("GraphQL Errors", () {
    test('Returns a response with GraphQL errors', () async {
      final mockLink = MockLink();

      final human = GHumanWithArgs((b) => b..vars.id = "123");

      final graphQLErrors = [
        GraphQLError(message: "Your GraphQL is not valid")
      ];

      when(mockLink.request(human.execRequest, any)).thenAnswer(
        (_) => Stream.value(Response(errors: graphQLErrors)),
      );

      final client = Client(
        link: mockLink,
        options: ClientOptions(addTypename: false),
      );

      final response = OperationResponse(
        operationRequest: human,
        graphqlErrors: graphQLErrors,
        dataSource: DataSource.Link,
      );

      expect(client.responseStream(human), emits(response));
    });
  });

  group("Network Errors", () {
    test('Returns a network error when Link throws', () async {
      final mockLink = MockLink();

      final human = GHumanWithArgs((b) => b..vars.id = "123");

      final exception = ServerException(parsedResponse: Response());

      when(mockLink.request(human.execRequest, any)).thenThrow(exception);

      final client = Client(
        link: mockLink,
        options: ClientOptions(addTypename: false),
      );

      final response = OperationResponse(
        operationRequest: human,
        linkException: exception,
        dataSource: DataSource.Link,
      );

      expect(client.responseStream(human), emits(response));
    });
  });
}
