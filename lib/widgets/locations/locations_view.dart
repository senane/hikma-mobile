import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikma_health/colors.dart';
import 'package:hikma_health/model/location.dart';
import 'package:hikma_health/user_repository/user_repository.dart';

import 'locations.dart';

class LocationsView extends StatefulWidget {

  final UserRepository userRepository;

  LocationsView({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _LocationsViewState();
}

class _LocationsViewState extends State<LocationsView> {
  LocationsViewBloc _locationsBloc;

  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    super.initState();
    _locationsBloc = LocationsViewBloc(userRepository: _userRepository);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _locationsBloc,
      listener: (context, state) {
        if (state is LocationListLoading) {
          _locationsBloc.dispatch(LocationListOpened());
        } else if (state is LocationListClosed) {
          Navigator.pop(context);
        }
      },
      child: Column(
        children: <Widget>[
          AppBar(
            backgroundColor: hikmaPrimaryLight,
            title: Text('Change Location'),
          ),
          BlocBuilder<LocationListEvent, LocationListState>(
              bloc: _locationsBloc,
              builder: (context, state) {
                return Expanded(
                  child: _buildLocationList(state),
                );
              }
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _locationsBloc.dispose();
  }

  Widget _buildLocationList(LocationListState state) {
    if (state is LocationListSuccess) {
      List locations = state.locations;
      String currentLocationUuid = state.currentLocationUuid;
      return ListView.separated(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          Location location = locations[index];
          bool isSelected = location.uuid == currentLocationUuid;
          return ListTile(
            title: Text(
              location.name,
              style: isSelected
                  ? TextStyle(color: hikmaPrimaryLight)
                  : null,
            ),
            trailing: isSelected
                ? Icon(Icons.check, color: hikmaPrimaryLight)
                : null,
            onTap: () {
              _locationsBloc.dispatch(
                  LocationChanged(location: locations[index])
              );
            },
          );
        },
        separatorBuilder: (context, index) => Divider(),
      );
    } else if (state is LocationListFailure) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Could not load location list from server',
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          FlatButton(
            color: hikmaPrimaryLight,
            child: Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
            onPressed: () {
              _locationsBloc.dispatch(LocationListOpened());
            },
          )
        ],
      );
    }
    return Center(child: CircularProgressIndicator());
  }
}
