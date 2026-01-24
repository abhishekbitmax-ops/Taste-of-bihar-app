import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';

class LiveTrackingBottomSheet extends StatefulWidget {
  const LiveTrackingBottomSheet({super.key});

  @override
  State<LiveTrackingBottomSheet> createState() =>
      _LiveTrackingBottomSheetState();
}

class _LiveTrackingBottomSheetState extends State<LiveTrackingBottomSheet>
    with TickerProviderStateMixin {
  final CartController ctrl = Get.find<CartController>();

  GoogleMapController? mapCtrl;
  Worker? _locationWorker;
  late AnimationController _pulseController;

  bool _cameraFitted = false;

  static const LatLng _fallback = LatLng(28.6139, 77.2090); // Delhi

  /// 🔥 smooth marker animation
  LatLng? _animatedDeliveryPos;
  Timer? _animTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    /// camera fit only once
    _locationWorker = everAll(
      [ctrl.userLat, ctrl.userLng, ctrl.deliveryLat, ctrl.deliveryLng],
      (_) {
        if (mapCtrl != null &&
            !_cameraFitted &&
            ctrl.userLat.value != 0 &&
            ctrl.deliveryLat.value != 0) {
          _cameraFitted = true;
          Future.delayed(const Duration(milliseconds: 500), _fitCamera);
        }

        /// 🔥 smooth delivery marker update
        _animateDeliveryMarker();
      },
    );
  }

  @override
  void dispose() {
    _locationWorker?.dispose();
    _pulseController.dispose();
    _animTimer?.cancel();
    mapCtrl?.dispose();
    super.dispose();
  }

  // ================= DISTANCE =================
  double _calculateDistance() {
    if (ctrl.userLat.value == 0 || ctrl.deliveryLat.value == 0) return 0;

    if (ctrl.roadDistance.value > 0) {
      return ctrl.roadDistance.value;
    }

    return Geolocator.distanceBetween(
          ctrl.userLat.value,
          ctrl.userLng.value,
          ctrl.deliveryLat.value,
          ctrl.deliveryLng.value,
        ) /
        1000;
  }

  // ================= SMOOTH MARKER =================
  void _animateDeliveryMarker() {
    final newLat = ctrl.deliveryLat.value;
    final newLng = ctrl.deliveryLng.value;

    if (newLat == 0 || newLng == 0) return;

    final target = LatLng(newLat, newLng);

    if (_animatedDeliveryPos == null) {
      _animatedDeliveryPos = target;
      return;
    }

    _animTimer?.cancel();

    const steps = 20;
    int i = 0;

    final from = _animatedDeliveryPos!;

    _animTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      i++;
      final t = i / steps;

      _animatedDeliveryPos = LatLng(
        from.latitude + (target.latitude - from.latitude) * t,
        from.longitude + (target.longitude - from.longitude) * t,
      );

      if (i >= steps) {
        timer.cancel();
        _animatedDeliveryPos = target;
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            "Live Delivery Tracking",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          // ================= MAP =================
          Expanded(
            child: Obx(() {
              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _fallback,
                  zoom: 5,
                ),
                onMapCreated: (c) {
                  mapCtrl = c;
                },
                markers: _buildMarkers(),
                polylines: _buildPolyline(),
                zoomControlsEnabled: false,
                myLocationEnabled: false,
              );
            }),
          ),

          // ================= INFO =================
          Obx(() {
            final hasUser = ctrl.userLat.value != 0 && ctrl.userLng.value != 0;
            final hasDelivery =
                ctrl.deliveryLat.value != 0 && ctrl.deliveryLng.value != 0;

            if (!hasUser || !hasDelivery) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: ScaleTransition(
                  scale: Tween(begin: 0.8, end: 1.0).animate(_pulseController),
                  child: Text(
                    "Waiting for delivery partner location...",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }

            final distance = _calculateDistance();
            final eta = ((distance / 20) * 60).toInt();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "${distance.toStringAsFixed(2)} km • ~$eta mins",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "📍 Live tracking active",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================= MARKERS =================
  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (ctrl.userLat.value != 0 && ctrl.userLng.value != 0) {
      markers.add(
        Marker(
          markerId: const MarkerId("USER"),
          position: LatLng(ctrl.userLat.value, ctrl.userLng.value),
          infoWindow: const InfoWindow(title: "Delivery Address"),
        ),
      );
    }

    if (_animatedDeliveryPos != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("DELIVERY"),
          position: _animatedDeliveryPos!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: "Delivery Partner"),
        ),
      );
    }

    return markers;
  }

  // ================= POLYLINE =================
  Set<Polyline> _buildPolyline() {
    if (_animatedDeliveryPos == null || ctrl.userLat.value == 0) return {};

    return {
      Polyline(
        polylineId: const PolylineId("route"),
        points: [
          _animatedDeliveryPos!,
          LatLng(ctrl.userLat.value, ctrl.userLng.value),
        ],
        color: Colors.blueAccent,
        width: 5,
      ),
    };
  }

  // ================= CAMERA =================
  void _fitCamera() {
    if (!mounted || mapCtrl == null) return;

    final user = LatLng(ctrl.userLat.value, ctrl.userLng.value);
    final rider = LatLng(ctrl.deliveryLat.value, ctrl.deliveryLng.value);

    final bounds = LatLngBounds(
      southwest: LatLng(
        user.latitude < rider.latitude ? user.latitude : rider.latitude,
        user.longitude < rider.longitude ? user.longitude : rider.longitude,
      ),
      northeast: LatLng(
        user.latitude > rider.latitude ? user.latitude : rider.latitude,
        user.longitude > rider.longitude ? user.longitude : rider.longitude,
      ),
    );

    mapCtrl!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }
}
