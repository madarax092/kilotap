import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_state.dart';
import '../../widgets/personal_info_form.dart';

class HouseholdPersonalInfoPage extends StatelessWidget {
  const HouseholdPersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The address page saves to ScrapSeller by default.
    return PersonalInfoForm(
      accent: AppColors.sellerGreen,
      address: () => AuthState.instance.address,
    );
  }
}
