import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/assets/assets.gen.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/organization_letter_mark.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/splash_gate_provider.dart';

/// Splash page shown while the app is initializing.
///
/// Displayed during auth state initialization on app startup.
/// The router handles navigation based on auth state - this page
/// simply watches auth state and displays a warming-up loading UI.
/// Holds for at least [SplashGate.minDuration] after [SplashGate.ensureStarted].
///
/// When a current organization is already resolved (logged-in cold start),
/// shows that org's letter-mark and name with a "Powered by" footer.
class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start the minimum splash hold; router leaves when elapsed + init ready.
    ref.read(splashGateProvider.notifier).ensureStarted();
    ref.watch(splashGateProvider);

    // Watch auth state - router will redirect when auth completes
    ref.watch(authControllerProvider);
    final orgAsync = ref.watch(currentOrganizationControllerProvider);
    final org = orgAsync.asData?.value;
    final orgName = org?.name.trim();
    final showOrgBrand = orgName != null && orgName.isNotEmpty;

    final verbIndex = useState(0);
    final ellipsisStep = useState(0);

    // Warm logo cache during splash hold so branded mark / nav paint instantly.
    useEffect(() {
      final url = org?.logoUrl;
      if (url == null || url.isEmpty) return null;
      unawaited(precacheOrganizationLogo(context, url));
      return null;
    }, [org?.logoUrl]);

    useEffect(() {
      if (showOrgBrand) return null;
      final verbTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
        verbIndex.value = (verbIndex.value + 1) % splashLoadingVerbs.length;
      });
      final ellipsisTimer = Timer.periodic(
        const Duration(milliseconds: 400),
        (_) {
          ellipsisStep.value = (ellipsisStep.value + 1) % 3;
        },
      );
      return () {
        verbTimer.cancel();
        ellipsisTimer.cancel();
      };
    }, [showOrgBrand]);

    final dots = '.' * (ellipsisStep.value + 1);
    final verbText = '${splashLoadingVerbs[verbIndex.value]}$dots';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: showOrgBrand
            ? _OrgBrandedSplash(
                orgName: orgName,
                logoUrl: org?.logoUrl,
              )
            : _AppLogoSplash(verbText: verbText),
      ),
    );
  }
}

class _OrgBrandedSplash extends StatelessWidget {
  const _OrgBrandedSplash({
    required this.orgName,
    this.logoUrl,
  });

  final String orgName;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OrganizationLetterMark(
                    name: orgName,
                    logoUrl: logoUrl,
                    size: 150,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    orgName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.15,
                          height: 1.2,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Text(
            t.auth.poweredBy,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}

class _AppLogoSplash extends StatelessWidget {
  const _AppLogoSplash({required this.verbText});

  final String verbText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = colorScheme.brightness == Brightness.light;
    // Opaque mark reads better on light surfaces; transparent suits dark.
    final logo = isLight
        ? Assets.icons.appIcon
        : Assets.icons.appIconTransparent;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          logo.image(width: 150, height: 150),
          const SizedBox(height: 24),
          Text(
            t.auth.almostThereWarmingUp,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            verbText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.72),
                  letterSpacing: 0.02 * 14,
                ),
          ),
        ],
      ),
    );
  }
}

/// English loading verbs (same set as the web HTML splash).
const splashLoadingVerbs = [
  'Loading',
  'Initializing',
  'Bootstrapping',
  'Preparing',
  'Warming up',
  'Assembling',
  'Hydrating',
  'Compiling',
  'Unpacking',
  'Provisioning',
  'Orchestrating',
  'Calibrating',
  'Spinning up',
  'Syncing',
  'Connecting',
  'Fetching',
  'Resolving',
  'Configuring',
  'Priming',
  'Awakening',
  'Igniting',
  'Launching',
  'Mounting',
  'Wiring',
  'Linking',
  'Caching',
  'Buffering',
  'Streaming',
  'Decoding',
  'Rendering',
  'Composing',
  'Building',
  'Crafting',
  'Forging',
  'Brewing',
  'Conjuring',
  'Summoning',
  'Materializing',
  'Manifesting',
  'Engaging',
  'Activating',
  'Enabling',
  'Aligning',
  'Tuning',
  'Polishing',
  'Finishing',
  'Finalizing',
  'Settling in',
  'Getting ready',
  'Almost there',
];
