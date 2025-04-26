import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meditation_app/core/constants/spacing.dart';
import 'package:meditation_app/core/theme/typography.dart';
import 'package:meditation_app/core/utils/validators.dart';
import 'package:meditation_app/presentation/state/auth_provider.dart';
import 'package:meditation_app/presentation/widgets/buttons/primary_button.dart';
import 'package:meditation_app/presentation/widgets/inputs/text_input.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    final errorMessage = useState<String?>(null);

    Future<void> handleLogin() async {
      if (!formKey.currentState!.validate()) return;

      try {
        isLoading.value = true;
        errorMessage.value = null;

        final authRepository = ref.read(authRepositoryProvider);
        await authRepository.signIn(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        // Navigate to home on success
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        errorMessage.value = 'Invalid email or password';
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
                  'Welcome Back',
                  style: AppTypography.headline1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.medium),
                Text(
                  'Sign in to continue your meditation journey',
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
                  validator: Validators.password,
                  autofillHints: const [AutofillHints.password],
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
                  onPressed: isLoading.value ? null : handleLogin,
                  child: isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Sign In'),
                ),
                const SizedBox(height: Spacing.medium),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: AppTypography.button,
                  ),
                ),
                const SizedBox(height: Spacing.small),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: AppTypography.body2,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Sign Up',
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