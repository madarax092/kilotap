import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/auth_state.dart';
import '../../widgets/personal_info_form.dart';

class CollectorPersonalInfoPage extends StatelessWidget {
  const CollectorPersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersonalInfoForm(
      accent: AppColors.buyerBlue,
      address: () => AuthState.instance.collectorAddress,
      onSaveAddress: AuthService.instance.updateCollectorAddress,
    );
  }
}
