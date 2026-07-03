import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/transactions_screen.dart';
import 'screens/settings_screen.dart';
import 'services/storage_service.dart';
import 'services/mp_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MercadoPagoApp());
}

class MercadoPagoApp extends StatefulWidget {
  const MercadoPagoApp({super.key});

  @override
  State<MercadoPagoApp> createState() => _MercadoPagoAppState();
}

class _MercadoPagoAppState extends State<MercadoPagoApp> {
  final StorageService _storageService = StorageService();
  final MpApiService _apiService = MpApiService();

  bool _isLoading = true;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _checkInitialToken();
  }

  Future<void> _checkInitialToken() async {
    final hasToken = await _storageService.hasToken();
    setState(() {
      _hasToken = hasToken;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        title: 'Mercado Pago Visualizer',
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Mercado Pago Visualizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF009EE3)),
        useMaterial3: true,
      ),
      home: _hasToken
          ? TransactionsScreen(
              storageService: _storageService,
              apiService: _apiService,
            )
          : SettingsScreen(
              storageService: _storageService,
            ),
    );
  }
}
