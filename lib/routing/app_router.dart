import 'package:go_router/go_router.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/home/employee_home_screen.dart';
import '../ui/screens/home/admin_home_screen.dart';
import '../ui/screens/home/admin_offices_screen.dart';

class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/employee',
          name: 'employeeHome',
          builder: (context, state) => const EmployeeHomeScreen(),
        ),
        GoRoute(
          path: '/admin',
          name: 'adminHome',
          builder: (context, state) => const AdminHomeScreen(),
        ),
        GoRoute(
          path: '/admin/offices',
          name: 'adminOffices',
          builder: (context, state) => const AdminOfficesScreen(),
        ),
      ],
    );
  }
}


