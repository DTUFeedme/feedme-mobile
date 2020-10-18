import 'package:climify/services/updateLocation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

AppBar scanAppBar(void Function() getAndSetRoom, String title) {
  return AppBar(
    title: InkWell(
      onTap: () => getAndSetRoom(),
      child: Consumer<UpdateLocation>(
        builder: (context, updateLocation, child) => Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                  ),
                  Text(
                    updateLocation.message,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            updateLocation.scanning
                ? CircularProgressIndicator(
                    value: null,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Container(),
            // _gettingRoom
            //     ? CircularProgressIndicator(
            //         value: null,
            //         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            //       )
            //     : Container(),
          ],
        ),
      ),
    ),
  );
}