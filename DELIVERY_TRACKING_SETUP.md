# Live Delivery Tracking Setup - Complete Flow

## 📊 Data Flow from Socket to UI

### 1️⃣ Socket Event: `DELIVERY_LOCATION_UPDATED`

**Incoming Data Structure:**
```json
{
  "role": "DELIVERY_PARTNER",
  "source": "flutter_app",
  "location": {
    "lat": 28.5128883,
    "lng": 77.4118512
  },
  "assignedOrder": {
    "deliveryAddress": {
      "lat": 28.558165,
      "lng": 77.338549
    }
  }
}
```

---

### 2️⃣ Socket Service: `Socket_service.dart`

**Event Listener:**
```dart
ordersocket!.on("DELIVERY_LOCATION_UPDATED", (data) {
  print("📍 DELIVERY_LOCATION_UPDATED => $data");
  if (onDeliveryLocationUpdated != null) {
    onDeliveryLocationUpdated(data);  // ✅ Passes full data to callback
  }
});
```

---

### 3️⃣ Cart Controller: `cartcontroller.dart`

**Callback Handler:**
```dart
void handleDeliveryLocation(dynamic data) {
  if (data == null) return;

  try {
    /// 🚴 DELIVERY PARTNER LOCATION (from location.lat & location.lng)
    final loc = data["location"];
    if (loc != null && loc["lat"] != null && loc["lng"] != null) {
      deliveryLat.value = (loc["lat"] as num).toDouble();      // 28.5128883
      deliveryLng.value = (loc["lng"] as num).toDouble();      // 77.4118512
      hasLiveLocation.value = true;
      debugPrint("✅ Delivery Location Set: $deliveryLat, $deliveryLng");
    }

    /// 👤 USER LOCATION (from assignedOrder.deliveryAddress.lat & lng)
    if (!hasUserLocation.value) {
      final address = data["assignedOrder"]?["deliveryAddress"];
      if (address != null && address["lat"] != null && address["lng"] != null) {
        userLat.value = (address["lat"] as num).toDouble();    // 28.558165
        userLng.value = (address["lng"] as num).toDouble();    // 77.338549
        hasUserLocation.value = true;
        debugPrint("✅ User Location Set: $userLat, $userLng");
      }
    }
  } catch (e, s) {
    debugPrint("❌ Error in handleDeliveryLocation: $e");
  }
}
```

---

### 4️⃣ Google Map Bottom Sheet: `Googlemapbottomsheet.dart`

**Display Logic:**

#### When waiting (one or both locations missing):
```
⏳ Waiting for delivery partner...
📍 Your Location: 28.5582, 77.3385
🚴 Partner Location: 28.5129, 77.4119
```

#### When both locations received:
```
┌─────────────────────────────────┐
│   0.53 km away                  │
├─────────────────────────────────┤
│ 📍 Your Location:               │
│ 28.5582, 77.3385               │
│                                 │
│ 🚴 Partner Location:           │
│ 28.5129, 77.4119               │
└─────────────────────────────────┘
```

---

## 🔄 Complete Flow Summary

| Step | Component | Data | Action |
|------|-----------|------|--------|
| 1 | Socket Server | Sends `DELIVERY_LOCATION_UPDATED` | Event triggered |
| 2 | `Socket_service.dart` | Receives event | Forwards to callback |
| 3 | `CartController.handleDeliveryLocation()` | Extracts both lat/lng pairs | Updates `.obs` variables |
| 4 | `GoogleMapBottomSheet` (Obx) | Observes changes | Rebuilds UI |
| 5 | Google Map | Receives markers & polyline | Displays both points |
| 6 | Distance Display | Calculates using Geolocator | Shows km between points |

---

## ✅ Verification Checklist

### Expected Console Logs:
```
📍 DELIVERY_LOCATION_UPDATED => {...}
✅ Delivery Location Set: 28.5128883, 77.4118512
✅ User Location Set: 28.558165, 77.338549
📍 MAP UI DEBUG: User(28.558165, 77.338549) | Delivery(28.5128883, 77.4118512) | Has Both: true
```

### Expected Map Display:
- 🔴 Red marker at user location (28.558165, 77.338549)
- 🟢 Green marker at partner location (28.5128883, 77.4118512)
- 🔵 Blue polyline connecting both
- Distance: ~3.5 km

---

## 🔧 If Data Not Showing

1. **Check Console:** Verify `DELIVERY_LOCATION_UPDATED` event is logged
2. **Check Variables:** Verify `✅ Delivery Location Set` message appears
3. **Check UI:** Look for "⏳ Waiting..." state (means socket connected but waiting for delivery)
4. **Check Socket:** Ensure `initOrderSocket()` is called in `CartController.onInit()`

---

## 📍 Key Extraction Paths

| Variable | Socket Path | Example Value |
|----------|-------------|----------------|
| `deliveryLat` | `data["location"]["lat"]` | 28.5128883 |
| `deliveryLng` | `data["location"]["lng"]` | 77.4118512 |
| `userLat` | `data["assignedOrder"]["deliveryAddress"]["lat"]` | 28.558165 |
| `userLng` | `data["assignedOrder"]["deliveryAddress"]["lng"]` | 77.338549 |

