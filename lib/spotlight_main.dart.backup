import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'view_component/spotlight_task_creator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Window.initialize();
  await Window.setEffect(effect: WindowEffect.transparent);
  Window.makeWindowFullyTransparent();
  Window.enableFullSizeContentView();
  Window.exitFullscreen();

  await windowManager.ensureInitialized();
  
  // Spotlight 창 전용 설정
  const spotlightWindowOptions = WindowOptions(
    size: Size(600, 400),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    alwaysOnTop: true,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  
  await windowManager.waitUntilReadyToShow(spotlightWindowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setBackgroundColor(Colors.transparent);
  });

  runApp(const ProviderScope(child: SpotlightApp()));
}

class SpotlightApp extends StatelessWidget {
  const SpotlightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO Spotlight',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
      ),
      home: const SpotlightWindow(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SpotlightWindow extends ConsumerWidget {
  const SpotlightWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: SpotlightTaskCreator(
            onClose: () async {
              // 창을 닫고 앱 종료
              await windowManager.hide();
              await Future.delayed(const Duration(milliseconds: 200));
              await windowManager.close();
            },
          ),
        ),
      ),
    );
  }
}
