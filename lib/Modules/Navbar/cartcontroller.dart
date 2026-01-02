import 'package:get/get.dart';

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;

  var address = "".obs;
  var selectedAddress = "No address selected".obs;

  void saveAddress(String addr) {
    address.value = addr;
  }

  var selectedLat = "".obs;
  var savedAddresses = <Map<String, String>>[].obs;

  int get subtotal => cartItems.fold(0, (sum, item) {
    String price = item["price"].toString().replaceAll("₹", "").trim();
    int p = int.tryParse(price) ?? 0;
    return sum + (p * (item["qty"] as int));
  });

  void increaseQty(int i) {
    cartItems[i]["qty"]++;
    cartItems.refresh();
  }

  void decreaseQty(int i) {
    if (cartItems[i]["qty"] > 1) {
      cartItems[i]["qty"]--;
      cartItems.refresh();
    }
  }

  void removeItem(int i) {
    cartItems.removeAt(i);
    cartItems.refresh();
  }

  void addToCart(Map<String, String> product, int qty) {
    cartItems.add({
      "name": product["name"],
      "image": product["image"],
      "price": product["price"],
      "qty": qty,
    });
  }

  int get totalCount =>
      cartItems.fold(0, (sum, item) => sum + (item["qty"] as int));
}
