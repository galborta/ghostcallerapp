import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meditation_app/core/constants/spacing.dart';
import 'package:meditation_app/core/theme/typography.dart';
import 'package:meditation_app/core/utils/validators.dart';
import 'package:meditation_app/presentation/state/auth_provider.dart';
import 'package:meditation_app/presentation/widgets/buttons/primary_button.dart';
import 'package:meditation_app/presentation/widgets/inputs/text_input.dart';

class SignupScreen extends HookConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final referralCodeController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> handleSignup() async {
      if (!formKey.currentState!.validate()) return;

      try {
        isLoading.value = true;
        errorMessage.value = null;

        final authRepository = ref.read(authRepositoryProvider);
        
        // Create user account
        final user = await authRepository.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        // Process referral code if provided
        if (referralCodeController.text.isNotEmpty) {
          await authRepository.updateUserMetadata({
            'referral_code': referralCodeController.text.trim(),
          });
        }

        // Navigate to home on success
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        errorMessage.value = 'Failed to create account. Please try again.';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.large),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Spacing.xxLarge),
                Text(
                  'Create Account',
                  style: AppTypography.headline1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.medium),
                Text(
                  'Begin your mindfulness journey today',
                  style: AppTypography.body1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.xxLarge),
                TextInput(
                  controller: emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: Spacing.medium),
                TextInput(
                  controller: passwordController,
                  label: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Password must contain at least one uppercase letter';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Password must contain at least one number';
                    }
                    return null;
                  },
                  helperText: 'Must be at least 8 characters with 1 uppercase letter and 1 number',
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: Spacing.medium),
                TextInput(
                  controller: referralCodeController,
                  label: 'Referral Code (Optional)',
                  helperText: 'Enter a referral code if you have one',
                ),
                if (errorMessage.value != null) ...[
                  const SizedBox(height: Spacing.small),
                  Text(
                    errorMessage.value!,
                    style: AppTypography.body2.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: Spacing.large),
                PrimaryButton(
                  onPressed: isLoading.value ? null : handleSignup,
                  child: isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Create Account'),
                ),
                const SizedBox(height: Spacing.medium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.body2,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Sign In',
                        style: AppTypography.button,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 