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
  bool _cameraFitted = false; // 🔥 Track if camera already fitted

  static const LatLng _fallback = LatLng(28.6139, 77.2090); // Delhi

  @override
  void initState() {
    super.initState();

    /// 🔥 Animation for waiting state
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    /// 🔥 Only fit camera ONCE when both locations are first available
    _locationWorker = everAll(
      [ctrl.userLat, ctrl.userLng, ctrl.deliveryLat, ctrl.deliveryLng],
      (_) {
        // Only fit camera once when both locations are available
        if (mapCtrl != null &&
            !_cameraFitted &&
            ctrl.userLat.value != 0 &&
            ctrl.deliveryLat.value != 0) {
          _cameraFitted = true;
          Future.delayed(const Duration(milliseconds: 500), _fitCamera);
        }
      },
    );
  }

  @override
  void dispose() {
    _locationWorker?.dispose();
    mapCtrl?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double _calculateDistance() {
    if (ctrl.userLat.value == 0 || ctrl.deliveryLat.value == 0) return 0;

    // 🔥 Use road distance if available, otherwise calculate straight line
    if (ctrl.roadDistance.value > 0) {
      return ctrl.roadDistance.value;
    }

    // Fallback to straight-line distance
    return Geolocator.distanceBetween(
          ctrl.userLat.value,
          ctrl.userLng.value,
          ctrl.deliveryLat.value,
          ctrl.deliveryLng.value,
        ) /
        1000;
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
                /// 🔥 FORCE MAP REDRAW
                key: ValueKey(
                  "${ctrl.userLat.value}-${ctrl.deliveryLat.value}",
                ),

                initialCameraPosition: const CameraPosition(
                  target: _fallback,
                  zoom: 5,
                ),

                onMapCreated: (c) {
                  mapCtrl = c;
                  Future.delayed(const Duration(milliseconds: 300), _fitCamera);
                },

                markers: _buildMarkers(),
                polylines: _buildPolyline(),
                zoomControlsEnabled: false,
                myLocationEnabled: false,
              );
            }),
          ),

          // ================= DISTANCE & TRACKING INFO =================
          Obx(() {
            final userLat = ctrl.userLat.value;
            final userLng = ctrl.userLng.value;
            final deliveryLat = ctrl.deliveryLat.value;
            final deliveryLng = ctrl.deliveryLng.value;

            final hasUserLoc = userLat != 0 && userLng != 0;
            final hasDeliveryLoc = deliveryLat != 0 && deliveryLng != 0;

            // 🔥 DEBUG: Always show current values
            debugPrint(
              "📍 MAP UI DEBUG: User($userLat, $userLng) | Delivery($deliveryLat, $deliveryLng) | Has Both: ${hasUserLoc && hasDeliveryLoc}",
            );

            // ⏳ WAITING STATE - One or both locations missing
            if (!hasDeliveryLoc || !hasUserLoc) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: Tween(
                          begin: 0.8,
                          end: 1.0,
                        ).animate(_pulseController),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange, width: 2),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                "🔄 Tracking Started",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Waiting for delivery partner location...",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Show User Location if available
                              if (hasUserLoc)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Your Location",
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${userLat.toStringAsFixed(5)}, ${userLng.toStringAsFixed(5)}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Show Delivery Partner Location if available
                              if (hasDeliveryLoc)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delivery_dining,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Partner Location",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${deliveryLat.toStringAsFixed(5)}, ${deliveryLng.toStringAsFixed(5)}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ✅ BOTH LOCATIONS AVAILABLE - Show distance and details
            final distance = _calculateDistance();
            final estimatedMinutes = ((distance / 20) * 60).toInt(); // ~20km/hr
            final isRoadDistance = ctrl.roadDistance.value > 0;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🟢 DISTANCE CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${distance.toStringAsFixed(2)} km",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Tooltip(
                                message: isRoadDistance
                                    ? "Road distance"
                                    : "Straight line",
                                child: Icon(
                                  isRoadDistance
                                      ? Icons.directions_car
                                      : Icons.straight,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Show actual direction instruction if available
                          Obx(
                            () => Text(
                              ctrl.roadDirection.value.isNotEmpty
                                  ? ctrl.roadDirection.value
                                  : (isRoadDistance
                                        ? "by road"
                                        : "straight line"),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "~${estimatedMinutes} min estimated arrival",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 📍 LOCATION DETAILS
                    Row(
                      children: [
                        // Your Location
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Your Location",
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  userLat.toStringAsFixed(5),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userLng.toStringAsFixed(5),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Partner Location
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.green.shade200,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.delivery_dining,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Partner",
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  deliveryLat.toStringAsFixed(5),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  deliveryLng.toStringAsFixed(5),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 🔄 LIVE STATUS
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: ScaleTransition(
                              scale: Tween(
                                begin: 0.7,
                                end: 1.0,
                              ).animate(_pulseController),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "📍 Live tracking active",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

    if (ctrl.deliveryLat.value != 0 && ctrl.deliveryLng.value != 0) {
      markers.add(
        Marker(
          markerId: const MarkerId("DELIVERY"),
          position: LatLng(ctrl.deliveryLat.value, ctrl.deliveryLng.value),
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
    if (ctrl.userLat.value == 0 || ctrl.deliveryLat.value == 0) return {};

    return {
      Polyline(
        polylineId: const PolylineId("route"),
        points: [
          LatLng(ctrl.deliveryLat.value, ctrl.deliveryLng.value),
          LatLng(ctrl.userLat.value, ctrl.userLng.value),
        ],
        color: Colors.blueAccent,
        width: 5,
      ),
    };
  }

  // ================= CAMERA FIT =================
  void _fitCamera() {
    if (!mounted || mapCtrl == null) return;
    if (ctrl.userLat.value == 0 || ctrl.deliveryLat.value == 0) return;

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
