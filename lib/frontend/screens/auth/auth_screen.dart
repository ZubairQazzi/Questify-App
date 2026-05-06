import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/models/user_settings.dart';
import '../../controllers/questify_controller.dart';
import '../../theme/questify_theme.dart';
import '../../widgets/questify_backdrop.dart';
import '../../widgets/questify_feedback.dart';
import '../../widgets/questify_top_dialog.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<QuestifyController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final canSubmit =
        controller.firebaseConfigured && !controller.isAuthenticating;

    return Scaffold(
      body: QuestifyBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 470),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest.withValues(
                            alpha: 0.94,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: scheme.outline),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  width: 62,
                                  height: 62,
                                  decoration: BoxDecoration(
                                    color: QuestifyTheme.violet.withValues(
                                      alpha: 0.16,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: QuestifyTheme.violetGlow
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.flash_on_rounded,
                                    color: QuestifyTheme.violetGlow,
                                    size: 30,
                                  ),
                                ),
                                const Spacer(),
                                _ThemeToggle(
                                  preference:
                                      controller.settings.themePreference,
                                  onChanged: controller.setThemePreference,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'WELCOME BACK',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text.rich(
                              TextSpan(
                                text: 'Hero',
                                children: <InlineSpan>[
                                  TextSpan(
                                    text: '.',
                                    style: theme.textTheme.displaySmall
                                        ?.copyWith(
                                          color: QuestifyTheme.violetGlow,
                                        ),
                                  ),
                                ],
                              ),
                              style: theme.textTheme.displaySmall,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Sign in fast and get straight to your quests, boss battles, focus timer, and rewards.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: const <Widget>[
                                _AuthChip(
                                  icon: Icons.cloud_done_rounded,
                                  label: 'Cloud sync',
                                ),
                                _AuthChip(
                                  icon: Icons.timer_outlined,
                                  label: 'Focus mode',
                                ),
                                _AuthChip(
                                  icon: Icons.workspace_premium_rounded,
                                  label: 'Rewards',
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer.withValues(
                                  alpha: 0.72,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: scheme.outline),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    controller.firebaseConfigured
                                        ? Icons.verified_rounded
                                        : Icons.cloud_off_rounded,
                                    color: controller.firebaseConfigured
                                        ? QuestifyTheme.violetGlow
                                        : scheme.error,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      controller.firebaseConfigured
                                          ? 'Firebase is ready. Use your email and password to log in or register.'
                                          : 'Firebase setup is still missing on this platform.',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            TabBar(
                              controller: _tabController,
                              tabs: const <Tab>[
                                Tab(text: 'Login'),
                                Tab(text: 'Register'),
                              ],
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 350,
                              child: TabBarView(
                                controller: _tabController,
                                children: <Widget>[
                                  _AuthFormPanel(
                                    formKey: _loginFormKey,
                                    fields: <Widget>[
                                      TextFormField(
                                        controller: _loginEmailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofillHints: const <String>[
                                          AutofillHints.email,
                                        ],
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          prefixIcon: Icon(
                                            Icons.mail_outline_rounded,
                                          ),
                                        ),
                                        validator: _validateEmail,
                                      ),
                                      const SizedBox(height: 14),
                                      TextFormField(
                                        controller: _loginPasswordController,
                                        obscureText: _obscureLoginPassword,
                                        autofillHints: const <String>[
                                          AutofillHints.password,
                                        ],
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: const Icon(
                                            Icons.lock_outline_rounded,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscureLoginPassword =
                                                    !_obscureLoginPassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscureLoginPassword
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                            ),
                                            tooltip: _obscureLoginPassword
                                                ? 'Show password'
                                                : 'Hide password',
                                          ),
                                        ),
                                        validator: _validatePassword,
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: controller
                                                      .firebaseConfigured &&
                                                  !controller.isAuthenticating
                                              ? _showForgotPasswordDialog
                                              : null,
                                          child: const Text(
                                            'Forgot password?',
                                          ),
                                        ),
                                      ),
                                    ],
                                    caption:
                                        'Use the same Firebase account you enabled in Authentication.',
                                    buttonLabel: 'LOGIN',
                                    enabled: canSubmit,
                                    onSubmit: () async {
                                      if (!_loginFormKey.currentState!
                                          .validate()) {
                                        return;
                                      }
                                      final message = await controller.signIn(
                                        email: _loginEmailController.text
                                            .trim(),
                                        password: _loginPasswordController.text
                                            .trim(),
                                      );
                                      if (!mounted || message == null) {
                                        return;
                                      }
                                      _showMessage(message);
                                    },
                                  ),
                                  _AuthFormPanel(
                                    formKey: _registerFormKey,
                                    fields: <Widget>[
                                      TextFormField(
                                        controller: _registerNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Name',
                                          prefixIcon: Icon(
                                            Icons.person_outline_rounded,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Please enter your name.';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),
                                      TextFormField(
                                        controller: _registerEmailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofillHints: const <String>[
                                          AutofillHints.email,
                                        ],
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          prefixIcon: Icon(
                                            Icons.mail_outline_rounded,
                                          ),
                                        ),
                                        validator: _validateEmail,
                                      ),
                                      const SizedBox(height: 14),
                                      TextFormField(
                                        controller: _registerPasswordController,
                                        obscureText: _obscureRegisterPassword,
                                        autofillHints: const <String>[
                                          AutofillHints.newPassword,
                                        ],
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: const Icon(
                                            Icons.lock_outline_rounded,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscureRegisterPassword =
                                                    !_obscureRegisterPassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscureRegisterPassword
                                                  ? Icons.visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                            ),
                                            tooltip: _obscureRegisterPassword
                                                ? 'Show password'
                                                : 'Hide password',
                                          ),
                                        ),
                                        validator: _validatePassword,
                                      ),
                                    ],
                                    caption:
                                        'Create one account and keep your quests and rewards synced.',
                                    buttonLabel: 'CREATE ACCOUNT',
                                    enabled: canSubmit,
                                    onSubmit: () async {
                                      if (!_registerFormKey.currentState!
                                          .validate()) {
                                        return;
                                      }
                                      final message = await controller.register(
                                        name: _registerNameController.text
                                            .trim(),
                                        email: _registerEmailController.text
                                            .trim(),
                                        password: _registerPasswordController
                                            .text
                                            .trim(),
                                      );
                                      if (!mounted || message == null) {
                                        return;
                                      }
                                      _showMessage(message);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (controller.isAuthenticating) ...<Widget>[
                              const SizedBox(height: 12),
                              const LinearProgressIndicator(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email.';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }
    if (value.length < 6) {
      return 'Use at least 6 characters.';
    }
    return null;
  }

  void _showMessage(String message) {
    _showFeedback(message);
  }

  void _showFeedback(
    String message, {
    QuestifyFeedbackTone tone = QuestifyFeedbackTone.error,
  }) {
    showQuestifyFeedback(
      context,
      message,
      tone: tone,
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController = TextEditingController(
      text: _loginEmailController.text.trim(),
    );
    final formKey = GlobalKey<FormState>();

    await showQuestifyTopDialog<void>(
      context: context,
      child: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final controller = dialogContext.watch<QuestifyController>();
          return Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Reset password',
                          style: Theme.of(
                            dialogContext,
                          ).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  Text(
                    'Enter your email and Questify will send a secure password reset email. Open the email and follow the instructions to choose a new password.',
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator: _validateEmail,
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.isAuthenticating
                              ? null
                              : () => Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: controller.isAuthenticating
                              ? null
                              : () async {
                                  final navigator = Navigator.of(dialogContext);
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  final message = await context
                                      .read<QuestifyController>()
                                      .sendPasswordResetEmail(
                                        resetEmailController.text.trim(),
                                      );
                                  if (!mounted) {
                                    return;
                                  }
                                  if (message != null) {
                                    _showFeedback(message);
                                    return;
                                  }
                                  if (mounted) {
                                    navigator.pop();
                                    _showFeedback(
                                      'Password reset email sent. Check your inbox and spam folder, then open the reset link to change your password.',
                                      tone: QuestifyFeedbackTone.success,
                                    );
                                  }
                                },
                          child: Text(
                            controller.isAuthenticating
                                ? 'Sending...'
                                : 'Send reset email',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    resetEmailController.dispose();
  }
}

class _AuthFormPanel extends StatelessWidget {
  const _AuthFormPanel({
    required this.formKey,
    required this.fields,
    required this.caption,
    required this.buttonLabel,
    required this.enabled,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final String caption;
  final String buttonLabel;
  final bool enabled;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...fields,
          const SizedBox(height: 16),
          Text(caption, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: enabled ? onSubmit : null,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthChip extends StatelessWidget {
  const _AuthChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: QuestifyTheme.violetGlow),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle({required this.preference, required this.onChanged});

  final ThemePreference preference;
  final ValueChanged<ThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = preference == ThemePreference.dark;
    return IconButton.filledTonal(
      onPressed: () {
        onChanged(isDark ? ThemePreference.light : ThemePreference.dark);
      },
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}
