import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _supabase = Supabase.instance.client;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      var query = _supabase.from('transactions').select();

      if (_startDate != null) {
        final start =
            DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        query = query.gte('datetime', start.toIso8601String());
      }
      if (_endDate != null) {
        final end = DateTime(
            _endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        query = query.lte('datetime', end.toIso8601String());
      }

      final data = await query.order('datetime', ascending: false);

      setState(() {
        _transactions =
            (data as List).map((e) => Transaction.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _startDate = picked);
    await _fetchTransactions();
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _endDate = picked);
    await _fetchTransactions();
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _fetchTransactions();
  }

  Future<void> _deleteTransaction(String id) async {
    try {
      await _supabase.from('transactions').delete().eq('id', id);
      await _fetchTransactions();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'debit':
        return Colors.red.shade100;
      case 'credit':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTransactions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 12),
                            Text('Error: $_error',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _fetchTransactions,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _transactions.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada transaksi.\nTekan + untuk menambahkan.',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchTransactions,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) {
                                final tx = _transactions[index];
                                return Card(
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          _categoryColor(tx.category),
                                      child: Text(
                                        tx.category.isNotEmpty
                                            ? tx.category[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      tx.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 2),
                                        Text(
                                          tx.category,
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12),
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy, HH:mm')
                                              .format(tx.datetime.toLocal()),
                                          style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${tx.category.toLowerCase() == 'credit' ? '+' : '-'}Rp ${NumberFormat('#,###').format(tx.amount)}',
                                          style: TextStyle(
                                            color:
                                                tx.category.toLowerCase() ==
                                                        'credit'
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20),
                                          onPressed: () =>
                                              _confirmDelete(context, tx),
                                          tooltip: 'Hapus',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          if (added == true) await _fetchTransactions();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildFilterBar() {
    final fmt = DateFormat('dd MMM yyyy');
    final hasFilter = _startDate != null || _endDate != null;
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_outlined, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: InkWell(
              onTap: _pickStartDate,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: Text(
                  _startDate != null
                      ? fmt.format(_startDate!)
                      : 'Dari tanggal',
                  style: TextStyle(
                    fontSize: 12,
                    color: _startDate != null
                        ? Colors.black87
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text('–', style: TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: InkWell(
              onTap: _pickEndDate,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                child: Text(
                  _endDate != null
                      ? fmt.format(_endDate!)
                      : 'Sampai tanggal',
                  style: TextStyle(
                    fontSize: 12,
                    color: _endDate != null
                        ? Colors.black87
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),
          if (hasFilter) ...[
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.red),
              onPressed: _clearFilter,
              tooltip: 'Reset filter',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Transaction tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text('Yakin ingin menghapus "${tx.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTransaction(tx.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
