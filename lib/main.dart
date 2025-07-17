import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'views/FloatingTaskView.dart';
import 'view_component/spotlight_task_creator.dart';
import 'view_component/accessibility_permission_dialog.dart';
import 'services/global_hotkey_service.dart';
import 'services/spotlight_window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Window.initialize();
  await Window.setEffect(effect: WindowEffect.transparent);
  Window.makeWindowFullyTransparent();
  Window.enableFullSizeContentView();
  Window.exitFullscreen();

  await windowManager.ensureInitialized();
  
  const windowOptions = WindowOptions(
    size: Size(320, 260),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    alwaysOnTop: true,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPosition(const Offset(100, 100));
    await windowManager.setBackgroundColor(Colors.transparent);
  });

  runApp(const ProviderScope(child: FloatingTodoApp()));
}

class FloatingTodoApp extends ConsumerStatefulWidget {
  const FloatingTodoApp({super.key});

  @override
  ConsumerState<FloatingTodoApp> createState() => _FloatingTodoAppState();
}

class _FloatingTodoAppState extends ConsumerState<FloatingTodoApp> {
  bool _showSpotlight = false;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    // 전역 단축키 서비스 초기화
    final hotkeyService = ref.read(hotkeyServiceProvider);
    
    try {
      await hotkeyService.initialize();
    } catch (e) {
      // 권한이 없을 경우 다이얼로그 표시
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => const AccessibilityPermissionDialog(),
          );
        });
      }
    }
    
    // Spotlight 표시 스트림 구독
    hotkeyService.showSpotlightStream.listen((show) {
      if (mounted) {
        setState(() {
          _showSpotlight = show;
        });
        
        final windowManager = ref.read(spotlightWindowManagerProvider);
        if (show) {
          windowManager.showSpotlightWindow();
        } else {
          windowManager.hideSpotlightWindow();
        }
      }
    });
  }
  
  void _closeSpotlight() {
    final hotkeyService = ref.read(hotkeyServiceProvider);
    hotkeyService.hideSpotlight();
  }

  @override
  void dispose() {
    final hotkeyService = ref.read(hotkeyServiceProvider);
    hotkeyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floating Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
      ),
      home: Stack(
        children: [
          // 메인 TODO 뷰 또는 Spotlight 창
          if (_showSpotlight)
            // Spotlight 모드
            Material(
              color: Colors.transparent,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: SpotlightTaskCreator(
                    onClose: _closeSpotlight,
                  ),
                ),
              ),
            )
          else
            // 일반 TODO 뷰
            const FloatingTaskView(),
        ],
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
