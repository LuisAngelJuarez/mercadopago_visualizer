import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/mp_api_service.dart';
import '../services/storage_service.dart';
import 'settings_screen.dart';

class TransactionsScreen extends StatefulWidget {
  final StorageService storageService;
  final MpApiService apiService;

  const TransactionsScreen({
    super.key, 
    required this.storageService,
    required this.apiService
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await widget.storageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No hay token configurado. Ve a configuración.');
      }

      final results = await widget.apiService.getTransactions(token);
      
      final now = DateTime.now();
      final todayResults = results.where((tx) {
        final dateStr = tx['date_created'] as String?;
        if (dateStr == null) return false;
        try {
          final date = DateTime.parse(dateStr).toLocal();
          return date.year == now.year && date.month == now.month && date.day == now.day;
        } catch (_) {
          return false;
        }
      }).toList();

      setState(() {
        _transactions = todayResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(storageService: widget.storageService),
      ),
    );
    // Reload transactions when coming back
    _loadTransactions();
  }

  String _formatCurrency(dynamic amount) {
    var format = NumberFormat.currency(locale: 'es_AR', symbol: '\$');
    return format.format(amount ?? 0);
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final parsedDate = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones de Hoy'),
        backgroundColor: const Color(0xFFFFE600), // Mercado Pago Yellow
        foregroundColor: const Color(0xFF2D3277), // Text color for Yellow Background
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          )
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF009EE3)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009EE3), foregroundColor: Colors.white),
                onPressed: _navigateToSettings,
                child: const Text('Ir a Configuración'),
              )
            ],
          ),
        ),
      );
    }

    if (_transactions.isEmpty) {
      return const Center(
        child: Text('No se encontraron transacciones.'),
      );
    }

    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        final amount = tx['transaction_amount'];
        final status = tx['status'];
        final description = tx['description'] ?? 'Transacción sin descripción';
        final date = tx['date_created'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: status == 'approved' ? Colors.green.shade100 : Colors.orange.shade100,
              child: Icon(
                status == 'approved' ? Icons.check_circle : Icons.pending,
                color: status == 'approved' ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              description,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(_formatDate(date)),
            trailing: Text(
              _formatCurrency(amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
