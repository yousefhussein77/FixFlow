import 'package:flutter/material.dart';

import '../../design_system/components/feedback/fixflow_state_view.dart';
import '../../design_system/layout/fixflow_page.dart';

class AccountStatusNotificationScreen extends StatelessWidget {
  const AccountStatusNotificationScreen({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final approved = status == 'approved';
    return FixFlowPage(
      title: const Text('حالة الحساب'),
      body: FixFlowStateView(
        kind: approved
            ? FixFlowStateKind.success
            : FixFlowStateKind.unauthorized,
        title: approved ? 'تم اعتماد الحساب' : 'تم رفض طلب الحساب',
        message: approved
            ? 'حسابك معتمد ويمكنك استخدام جميع الميزات المتاحة لدورك.'
            : 'تم رفض طلب إنشاء الحساب. تواصل مع الإدارة عند الحاجة.',
      ),
    );
  }
}
