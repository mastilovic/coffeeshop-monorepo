import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_notifier.dart';

class ReservationListScreen extends ConsumerWidget {
  const ReservationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isOwner = authState.user?.userType == 'shop_owner' || authState.user?.userType == 'admin';

    return DefaultTabController(
      length: isOwner ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reservations'),
          bottom: TabBar(
            tabs: isOwner
                ? const [
                    Tab(text: 'Pending'),
                    Tab(text: 'Approved'),
                    Tab(text: 'Denied'),
                  ]
                : const [
                    Tab(text: 'My Requests'),
                    Tab(text: 'My Reservations'),
                  ],
          ),
        ),
        body: TabBarView(
          children: isOwner
              ? [
                  const _ReservationTab(status: 'pending'),
                  const _ReservationTab(status: 'approved'),
                  const _ReservationTab(status: 'denied'),
                ]
              : [
                  const _UserReservationRequestsTab(),
                  const _UserReservationsTab(),
                ],
        ),
      ),
    );
  }
}

class _ReservationTab extends ConsumerWidget {
  const _ReservationTab({required this.status});

  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_seat, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Reservations - coming soon', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _UserReservationRequestsTab extends ConsumerWidget {
  const _UserReservationRequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.send, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('My Requests - coming soon', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _UserReservationsTab extends ConsumerWidget {
  const _UserReservationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('My Reservations - coming soon', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
