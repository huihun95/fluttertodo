import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 현재 활성 탭을 관리하는 Provider
final activeTabProvider = StateProvider<NavigationTab>((ref) => NavigationTab.tasks);

enum NavigationTab {
  tasks('태스크', Icons.task_alt),
  team('팀원', Icons.people);

  const NavigationTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

class TodoNavigationBar extends ConsumerWidget {
  const TodoNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(activeTabProvider);

    return Container(
      height: 45,
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: NavigationTab.values.map((tab) {
          final isActive = activeTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(activeTabProvider.notifier).state = tab,
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? Colors.blue.shade50 : Colors.transparent,
                  borderRadius: tab == NavigationTab.tasks 
                      ? const BorderRadius.only(topLeft: Radius.circular(11))
                      : const BorderRadius.only(topRight: Radius.circular(11)),
                  border: isActive ? Border(
                    bottom: BorderSide(color: Colors.blue.shade600, width: 2),
                  ) : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        size: 16,
                        color: isActive ? Colors.blue.shade600 : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive ? Colors.blue.shade600 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}