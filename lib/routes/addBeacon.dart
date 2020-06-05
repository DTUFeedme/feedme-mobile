// onChangeDropdownItem1(BuildingModel selectedBuilding) {
//     setState(() {
//       _selectedBuilding = selectedBuilding;
//     });
//   }

//   onChangeDropdownItem2(Tuple2<String, String> selectedBeacon) {
//     setState(() {
//       _selectedBeacon = selectedBeacon;
//     });
//   }

// void _createBecon() async {
//     if (_selectedBeacon == null || _selectedBuilding == null) return;
//     String _token = Provider.of<GlobalState>(context).globalState['token'];
//     APIResponse<bool> apiResponse = await _restService.addBeacon(
//         _token, _selectedBeacon, _selectedBuilding);
//     if (apiResponse.data == true) {
//       setState(() {
//         _selectedBuilding = null;
//         _selectedBeacon = null;
//         _changeWindow(0);
//       });
//     } else {
//       SnackBarError.showErrorSnackBar(apiResponse.errorMessage, _scaffoldKey);
//     }
//   }

// Visibility(
//               visible: _visibleIndex == 1,
//               child: Column(
//                 children: <Widget>[
//                   Text("Select building"),
//                   SizedBox(
//                     height: 20.0,
//                   ),
//                   DropdownButton(
//                     value: _selectedBuilding,
//                     items: buildDropdownMenuItems1(_buildings),
//                     onChanged: onChangeDropdownItem1,
//                   ),
//                   SizedBox(
//                     height: 20.0,
//                   ),
//                   Text("Selected: ${_selectedBuilding?.name}"),
//                   Text("Choose beacon device"),
//                   SizedBox(
//                     height: 20.0,
//                   ),
//                   DropdownButton(
//                     value: _selectedBeacon,
//                     items: buildDropdownMenuItems2(_beaconList),
//                     onChanged: onChangeDropdownItem2,
//                   ),
//                   SizedBox(
//                     height: 20.0,
//                   ),
//                   Text("Selected: ${_selectedBeacon?.item1}"),
//                   SizedBox(
//                     height: 20.0,
//                   ),
//                   RaisedButton(
//                     child: Text(
//                       "Create Beacon",
//                     ),
//                     onPressed: () => _createBecon(),
//                   ),
//                   RaisedButton(
//                     child: Text(
//                       "What building?",
//                     ),
//                     onPressed: () => _getBuildingScan(),
//                   ),
//                   Text(
//                     buildingId,
//                   ),
//                 ],
//               ),
//             ),
