import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/xp_transaction.dart';

class XPTransactionsScreen extends StatelessWidget {
  const XPTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('XP Transactions'),
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
        child: ValueListenableBuilder(
          valueListenable:
              Hive.box<XPTransaction>('xp_transactions').listenable(),
          builder: (context, Box<XPTransaction> box, _) {
            final transactions = box.values.toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions yet',
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start studying to see your XP history!',
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _TransactionCard(transaction: transaction);
              },
            );
          },
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final XPTransaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.amount > 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = _getTransactionIcon(transaction.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          transaction.reason,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getTransactionTypeLabel(transaction.type),
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateTime(transaction.timestamp),
              style: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            transaction.formattedAmount,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'study':
        return Icons.school;
      case 'achievement':
        return Icons.emoji_events;
      case 'streak_bonus':
        return Icons.local_fire_department;
      case 'streak_penalty':
        return Icons.warning;
      case 'goal_completion':
        return Icons.flag;
      default:
        return Icons.star;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    String dateStr;
    if (difference.inDays == 0) {
      dateStr = 'Today';
    } else if (difference.inDays == 1) {
      dateStr = 'Yesterday';
    } else if (difference.inDays < 7) {
      dateStr = '${difference.inDays} days ago';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeStr = '$displayHour:$minute $period';

    return '$dateStr at $timeStr';
  }

  String _getTransactionTypeLabel(String type) {
    switch (type) {
      case 'study':
        return 'Study Session';
      case 'achievement':
        return 'Achievement';
      case 'streak_bonus':
        return 'Streak Bonus';
      case 'streak_penalty':
        return 'Streak Penalty';
      case 'goal_completion':
        return 'Goal Completion';
      default:
        return 'Unknown';
    }
  }
}
