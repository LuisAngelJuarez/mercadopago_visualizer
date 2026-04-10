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

  @override
  void initState() {
    super.initState();
    _checkExistingToken();
  }

  Future<void> _checkExistingToken() async {
    final hasTokenResult = await widget.storageService.hasToken();
    setState(() {
      _hasToken = hasTokenResult;
      // We don't load the real token into the controller to prevent visualization
      if (_hasToken) {
        _tokenController.text = '********************************'; // Fake masked token
      }
    });
  }

  Future<void> _saveSettings() async {
    // Save Max Amount
    final maxAmountText = _maxAmountController.text.trim();
    double? maxAmount;
    if (maxAmountText.isNotEmpty) {
      maxAmount = double.tryParse(maxAmountText);
    }
    await widget.storageService.saveMaxAmount(maxAmount);

    // Save Token if changed
    final inputText = _tokenController.text;
    if (inputText.isNotEmpty && !inputText.contains('****************')) {
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración guardada correctamente')),
      );
      setState(() {
        _hasToken = true;
        _tokenController.text = '********************************';
      });
    } else if (inputText.contains('****************')) {
      // Token wasn't edited, only other settings were saved
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
