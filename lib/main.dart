import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:restro_app/Modules/Auth/controller/AuthController.dart';
import 'package:restro_app/Modules/Dashboard/view/Socket_service.dart';
import 'package:restro_app/Modules/Navbar/Splashscreen.dart';
import 'package:restro_app/Modules/Navbar/cartcontroller.dart';
import 'package:restro_app/widgets/Globalnotifation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:restro_app/utils/Sharedpre.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();

  /// 🔥 Controllers (SINGLETON)
  final cartCtrl = Get.put(CartController(), permanent: true);
  Get.put(Authcontroller(), permanent: true);

  /// 🔥 CONNECT SOCKET ONLY IF TOKEN EXISTS
  final token = await SharedPre.getAccessToken();

  if (token.isNotEmpty) {
    Future.delayed(const Duration(milliseconds: 800), () {
      OrderSocketService.connect(
        onStatusUpdate: cartCtrl.handleSocketStatusUpdate,
        onTrackingInfo: cartCtrl.handleSocketTrackingInfo,
        
        onDeliveryAssigned: (data) {
          GlobalNotificationService.show(
            title: "Delivery Assigned",
            message: "Your order has been assigned to a rider 🚴",
          );
        },
      );
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          title: 'Restaurant App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.poppinsTextTheme(),
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
