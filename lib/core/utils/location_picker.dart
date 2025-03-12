import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homecare/core/theme/themes.dart';
import 'package:homecare/widgets/buttons.dart';

class LocationPicker extends StatefulWidget {
  final LatLng initialLocation;
  final bool useCurrentLocation;

  const LocationPicker({
    super.key,
    required this.initialLocation,
    required this.useCurrentLocation,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? _pickedLocation;
  GoogleMapController? _mapController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.useCurrentLocation) {
        _moveToCurrentLocation();
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _moveToCurrentLocation() async {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: widget.initialLocation, zoom: 15,
        ),
      ),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر موقعاً'),
        centerTitle: true,
        actions: [
          CustomBackButton(
            onBack: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: Platform.isIOS ? 20.0 : 0.0),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialLocation,
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                if (widget.useCurrentLocation) {
                  _moveToCurrentLocation();
                }
              },
              onTap: (location) {
                setState(() {
                  _pickedLocation = location;
                });
              },
              markers: {
                Marker(
                  markerId: const MarkerId('selected-location'),
                  position: _pickedLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    widget.useCurrentLocation ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed,
                  ),
                ),
              },
            ),
          ),
          if (!_isLoading)
            Positioned(
              bottom: 20,
              left: 75,
              right: 75,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeCareTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, _pickedLocation);
                },
                child: const Text('تأكيد الموقع الذي اخترته', style: TextStyle(fontSize: 16.0)),
              ),
            ),
        ],
      ),
    );
  }
}
