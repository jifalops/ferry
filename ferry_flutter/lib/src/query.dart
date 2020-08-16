import 'package:flutter/material.dart';
import 'package:ferry/ferry.dart';

typedef OperationResponseBuilder<TData, TVars> = Widget Function(
  BuildContext context,
  OperationResponse<TData, TVars> response,
);

class Query<TData, TVars> extends StatefulWidget {
  final OperationRequest<TData, TVars> operationRequest;
  final OperationResponseBuilder<TData, TVars> builder;
  final Client client;

  Query({
    @required this.operationRequest,
    @required this.builder,
    @required this.client,
  });

  @override
  _QueryState<TData, TVars> createState() => _QueryState(builder: builder);
}

class _QueryState<TData, TVars> extends State<Query> {
  final OperationResponseBuilder<TData, TVars> builder;

  Stream<OperationResponse<TData, TVars>> stream;

  _QueryState({this.builder});

  @override
  void initState() {
    super.initState();
    stream = widget.client.responseStream(widget.operationRequest);
  }

  @override
  void didUpdateWidget(Query oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operationRequest != widget.operationRequest) {
      setState(() {
        stream = widget.client.responseStream(widget.operationRequest);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<OperationResponse<TData, TVars>>(
      initialData: OperationResponse<TData, TVars>(
        operationRequest: widget.operationRequest,
        dataSource: DataSource.None,
      ),
      stream: stream,
      builder: (context, snapshot) => builder(
        context,
        snapshot.data,
      ),
    );
  }
}
