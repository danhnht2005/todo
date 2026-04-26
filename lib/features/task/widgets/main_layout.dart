import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ứng dụng của tôi')),
      // Mọi nội dung của các route con sẽ được hiển thị ở phần body này
      body: child,

      // Ví dụ một BottomNavigationBar dùng chung cho toàn bộ layout
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/profile');
        },
      ),
    );
  }
}
