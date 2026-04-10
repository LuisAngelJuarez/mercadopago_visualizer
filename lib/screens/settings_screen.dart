import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storageService;
  
  const SettingsScreen({super.key, required this.storageService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _tokenController = TextEditingController();
  final _maxAmountController = TextEditingController();
  bool _hasToken = false;
  double? _initialMaxAmount;

  static const String _maskedToken = '********************************';

  @override
  void initState() {
    super.initState();
    _loadExistingSettings();
  }

  Future<void> _loadExistingSettings() async {
    final hasTokenResult = await widget.storageService.hasToken();
    final existingMaxAmount = await widget.storageService.getMaxAmount();
    if (!mounted) return;
    setState(() {
      _hasToken = hasTokenResult;
      // We don't load the real token into the controller to prevent visualization
      if (_hasToken) {
        _tokenController.text = _maskedToken; // Fake masked token
      }

      _initialMaxAmount = existingMaxAmount;
      if (existingMaxAmount != null) {
        _maxAmountController.text = existingMaxAmount.toString();
      }
    });
  }

  bool _isMaskedTokenInput(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed == _maskedToken) return true;
    return RegExp(r'^\*+$').hasMatch(trimmed);
  }

  bool _doubleEquals(double? a, double? b) {
    if (a == null || b == null) return a == b;
    return (a - b).abs() < 1e-9;
  }

  Future<void> _saveSettings() async {
    // Parse Max Amount
    final maxAmountText = _maxAmountController.text.trim();
    double? maxAmount;
    if (maxAmountText.isNotEmpty) {
      maxAmount = double.tryParse(maxAmountText);
      if (maxAmount == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor ingresa un monto válido')),
        );
        return;
      }
    }

    final maxAmountChanged = !_doubleEquals(_initialMaxAmount, maxAmount);

    // Save Token if changed
    final inputText = _tokenController.text;
    final isMaskedToken = _isMaskedTokenInput(inputText);

    // Requirement: if max amount was modified, user must enter the full token
    if (maxAmountChanged && (inputText.trim().isEmpty || isMaskedToken)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Para modificar el monto máximo visible, ingresa el token completo y guarda nuevamente.',
          ),
        ),
      );
      return;
    }

    if (inputText.isNotEmpty && !isMaskedToken) {
      // Sanitize token: remove quotes, Bearer prefix, and trim.
      final sanitizedToken = inputText
          .replaceAll('"', '')
          .replaceAll("'", "")
          .replaceAll(RegExp(r'^Bearer\s+', caseSensitive: false), '')
          .trim();
          
      if (sanitizedToken.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor ingresa un token válido')),
        );
        return;
      }

      await widget.storageService.saveToken(sanitizedToken);

      // Save Max Amount (only after token validation when required)
      await widget.storageService.saveMaxAmount(maxAmount);
      _initialMaxAmount = maxAmount;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración guardada correctamente')),
      );
      setState(() {
        _hasToken = true;
        _tokenController.text = _maskedToken;
      });
    } else if (isMaskedToken) {
      // Token wasn't edited, only other settings were saved (allowed only if max amount didn't change)
      await widget.storageService.saveMaxAmount(maxAmount);
      _initialMaxAmount = maxAmount;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración actualizada')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un token válido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFF009EE3), // Mercado Pago Blue
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Token de Acceso (Access Token)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa tu mp_access_token de Mercado Pago. Una vez guardado, por seguridad no podrás visualizarlo, solo actualizarlo.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'APP_USR-...',
              ),
              obscureText: false, // We manually mask it over the text controller so we don't need real obscureText
            ),
            const SizedBox(height: 24),
            const Text(
              'Monto Máximo Visible (\$)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Oculta por seguridad transacciones o abonos que superen este monto (opcional).',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nota: si modificas este monto, deberás volver a ingresar el token completo para guardar.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _maxAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej. 5000',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009EE3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16)
              ),
              child: Text(_hasToken ? 'Actualizar Configuración' : 'Guardar Configuración'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }
}
