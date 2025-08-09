import 'package:go_router/go_router.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/reset_password_screen.dart';
import '../ui/screens/auth/signup_screen.dart';
import '../ui/screens/home/employee_home_screen.dart';
import '../ui/screens/home/admin_home_screen.dart';
import '../ui/screens/home/admin_employees_screen.dart';
import '../ui/screens/common/map_picker_screen.dart';
import '../ui/screens/home/admin_offices_screen.dart';
import '../ui/screens/home/admin_reports_screen.dart';

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
          path: '/reset',
          name: 'resetPassword',
          builder: (context, state) => const ResetPasswordScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
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
          path: '/admin/employees',
          name: 'adminEmployees',
          builder: (context, state) => const AdminEmployeesScreen(),
        ),
        GoRoute(
          path: '/mapPicker',
          name: 'mapPicker',
          builder: (context, state) => const MapPickerScreen(),
        ),
        GoRoute(
          path: '/admin/offices',
          name: 'adminOffices',
          builder: (context, state) => const AdminOfficesScreen(),
        ),
        GoRoute(
          path: '/admin/reports',
          name: 'adminReports',
          builder: (context, state) => const AdminReportsScreen(),
        ),
      ],
    );
  }
}
