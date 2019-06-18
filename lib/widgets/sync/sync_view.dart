import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/user_repository/user_repository.dart';

import 'sync.dart';

class SyncView extends StatefulWidget {
  final UserRepository userRepository;

  SyncView({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<SyncView> createState() => _SyncViewState();
}

class _SyncViewState extends State<SyncView> {
  SyncBloc _syncBloc;

  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    _syncBloc = SyncBloc(
      userRepository: _userRepository,
    );
    _syncBloc.dispatch(SyncStarted());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _syncBloc,
      listener: (context, state) {
        if (state is SyncSuccess) {
          Navigator.pop(context);
        }
      },
      child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(32),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  Text('Sync in progress...',)
                ],
              ),
            ),
          )
      ),
    );
  }

  @override
  void dispose() {
    _syncBloc.dispose();
    super.dispose();
  }
}
