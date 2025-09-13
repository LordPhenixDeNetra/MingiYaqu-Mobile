import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Models
import 'models/product.dart';
import 'models/category.dart';
import 'models/notification_settings.dart';

// Providers
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/notification_provider.dart';

// Services
import 'services/notification_service.dart';

// Utils
import 'utils/page_transitions.dart';

// Screens
import 'screens/dashboard_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/edit_product_screen.dart';
import 'screens/settings_screen.dart';

// Constants
import 'constants/app_theme.dart';
import 'constants/app_colors.dart';
import 'constants/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await _initializeHive();
  
  // Initialize notification service
  await NotificationService().init();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.primary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MingiYaquApp());
}

Future<void> _initializeHive() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(NotificationSettingsAdapter());
  
  // Open boxes
  await Hive.openBox<Product>('products');
  await Hive.openBox('settings');
}

class MingiYaquApp extends StatelessWidget {
  const MingiYaquApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ProductProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()..initialize()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: 'MingiYaqu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('fr', 'FR'),
              Locale('en', 'US'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const MainNavigationScreen(),
            routes: {
              '/dashboard': (context) => const DashboardScreen(),
              '/products': (context) => const ProductListScreen(),
              '/add-product': (context) => const AddProductScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/edit-product') {
                final product = settings.arguments as Product;
                return MaterialPageRoute(
                  builder: (context) => EditProductScreen(product: product),
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  late PageController _pageController;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductListScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Show FAB initially if on dashboard or products
    if (_currentIndex == 0 || _currentIndex == 1) {
      _fabAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    // Animate page transition
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    // Animate FAB
    if (index == 0 || index == 1) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          if (index == 0 || index == 1) {
            _fabAnimationController.forward();
          } else {
            _fabAnimationController.reverse();
          }
        },
        children: _screens.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget screen = entry.value;
          
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - idx;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }
              
              return Transform.scale(
                scale: Curves.easeOut.transform(value),
                child: Opacity(
                  opacity: value,
                  child: screen,
                ),
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppStyles.radiusL),
          topRight: Radius.circular(AppStyles.radiusL),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppStyles.radiusL),
          topRight: Radius.circular(AppStyles.radiusL),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          selectedLabelStyle: AppStyles.labelMedium(context).copyWith(
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          unselectedLabelStyle: AppStyles.labelMedium(context).copyWith(
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
          items: [
            _buildBottomNavItem(
              Icons.dashboard_outlined,
              Icons.dashboard,
              'Tableau de bord',
              0,
            ),
            _buildBottomNavItem(
              Icons.inventory_2_outlined,
              Icons.inventory_2,
              'Produits',
              1,
            ),
            _buildBottomNavItem(
              Icons.settings_outlined,
              Icons.settings,
              'Paramètres',
              2,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? AppStyles.paddingS : AppStyles.paddingXS),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
        ),
        child: Icon(
          icon,
          size: AppStyles.iconM,
        ),
      ),
      activeIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppStyles.paddingS),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppStyles.radiusM),
        ),
        child: Icon(
          activeIcon,
          size: AppStyles.iconM,
        ),
      ),
      label: label,
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentIndex != 0 && _currentIndex != 1) return null;
    
    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppStyles.paddingL),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppStyles.radiusL),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushModal(
              const AddProductScreen(),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: AppStyles.iconM),
          label: Text(
            'Ajouter',
            style: AppStyles.labelLarge(context).copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Global error handler
class GlobalErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    debugPrint('Global Error: $error');
    debugPrint('Stack Trace: $stackTrace');
    
    // Here you could add crash reporting service like Firebase Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}

// App lifecycle handler
class AppLifecycleHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        debugPrint('App resumed');
        break;
      case AppLifecycleState.paused:
        // App is in background
        debugPrint('App paused');
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        debugPrint('App detached');
        _cleanup();
        break;
      default:
        break;
    }
  }
  
  void _cleanup() {
    // Close Hive boxes
    Hive.close();
  }
}
