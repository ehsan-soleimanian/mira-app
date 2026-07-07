import 'package:mira_app/core/api/api_client.dart';
import 'package:mira_app/core/auth/auth_repository.dart';
import 'package:mira_app/core/auth/google_sign_in_service.dart';
import 'package:mira_app/core/auth/token_storage.dart';
import 'package:mira_app/core/notifications/notification_service.dart';
import 'package:mira_app/core/update/app_release_repository.dart';
import 'package:mira_app/features/auth/onboarding_repository.dart';
import 'package:mira_app/features/capture/capture_repository.dart';
import 'package:mira_app/features/daily_brief/daily_brief_repository.dart';
import 'package:mira_app/features/graph/graph_repository.dart';
import 'package:mira_app/features/settings/settings_repository.dart';
import 'package:mira_app/features/workspace/assistant_repository.dart';
import 'package:mira_app/features/workspace/canvas_repository.dart';
import 'package:mira_app/features/workspace/library_repository.dart';
import 'package:mira_app/features/workspace/plugin_repository.dart';
import 'package:mira_app/features/workspace/publish_repository.dart';
import 'package:mira_app/features/workspace/space_repository.dart';

/// App-wide dependency container: constructs the shared API client and every
/// repository behind a single `MiraServices.create()` and exposes them through
/// `AppScope` so screens can reach persistence without wiring it themselves.
class MiraServices {
  MiraServices._({
    required this.tokenStorage,
    required this.apiClient,
    required this.authRepository,
    required this.googleSignInService,
    required this.onboardingRepository,
    required this.captureRepository,
    required this.dailyBriefRepository,
    required this.graphRepository,
    required this.settingsRepository,
    required this.appReleaseRepository,
    required this.libraryRepository,
    required this.assistantRepository,
    required this.spaceRepository,
    required this.canvasRepository,
    required this.publishRepository,
    required this.pluginRepository,
    required this.notificationService,
  });

  factory MiraServices.create() {
    final tokenStorage = TokenStorage();
    late AuthRepository authRepository;
    final apiClient = ApiClient(
      tokenStorage: tokenStorage,
      onRefresh: () => authRepository.refreshAccessToken(),
    );
    final googleSignInService = GoogleSignInService();
    authRepository = AuthRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
      googleSignInService: googleSignInService,
    );
    final onboardingRepository = OnboardingRepository(apiClient: apiClient);
    final captureRepository = CaptureRepository(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );
    final dailyBriefRepository = DailyBriefRepository(apiClient: apiClient);
    final graphRepository = GraphRepository(apiClient: apiClient);
    final settingsRepository = SettingsRepository(apiClient: apiClient);
    final appReleaseRepository = AppReleaseRepository(apiClient: apiClient);
    final libraryRepository = LibraryRepository(apiClient: apiClient);
    final assistantRepository = AssistantRepository(apiClient: apiClient);
    final spaceRepository = SpaceRepository(apiClient: apiClient);
    final canvasRepository = CanvasRepository(apiClient: apiClient);
    final publishRepository = PublishRepository(apiClient: apiClient);
    final pluginRepository = PluginRepository(apiClient: apiClient);
    final notificationService = NotificationService();
    return MiraServices._(
      tokenStorage: tokenStorage,
      apiClient: apiClient,
      authRepository: authRepository,
      googleSignInService: googleSignInService,
      onboardingRepository: onboardingRepository,
      captureRepository: captureRepository,
      dailyBriefRepository: dailyBriefRepository,
      graphRepository: graphRepository,
      settingsRepository: settingsRepository,
      appReleaseRepository: appReleaseRepository,
      libraryRepository: libraryRepository,
      assistantRepository: assistantRepository,
      spaceRepository: spaceRepository,
      canvasRepository: canvasRepository,
      publishRepository: publishRepository,
      pluginRepository: pluginRepository,
      notificationService: notificationService,
    );
  }

  final TokenStorage tokenStorage;
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final GoogleSignInService googleSignInService;
  final OnboardingRepository onboardingRepository;
  final CaptureRepository captureRepository;
  final DailyBriefRepository dailyBriefRepository;
  final GraphRepository graphRepository;
  final SettingsRepository settingsRepository;
  final AppReleaseRepository appReleaseRepository;
  final LibraryRepository libraryRepository;
  final AssistantRepository assistantRepository;
  final SpaceRepository spaceRepository;
  final CanvasRepository canvasRepository;
  final PublishRepository publishRepository;
  final PluginRepository pluginRepository;
  final NotificationService notificationService;
}
