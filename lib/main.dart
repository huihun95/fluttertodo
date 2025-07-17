import 'package:flutter/material.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'views/FloatingTaskView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Window.initialize(); // flutter_acrylic 초기화
  await Window.setEffect(effect: WindowEffect.transparent);
  Window.makeWindowFullyTransparent();
  Window.enableFullSizeContentView();
  Window.exitFullscreen();
  // Window.hideWindowControls();


  // 윈도우 설정 초기화
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(320, 260),
    center: false,
    backgroundColor: Colors.transparent, // 완전 투명
    skipTaskbar: false,
    alwaysOnTop: true,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false, // 윈도우 버튼 숨김
  );
  
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setPosition(const Offset(100, 100));
    // 윈도우를 투명하게 설정
    await windowManager.setBackgroundColor(Colors.transparent);
  });

  runApp(const ProviderScope(child: FloatingTodoApp()));
}

class FloatingTodoApp extends StatelessWidget {
  const FloatingTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floating Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent, // Scaffold 배경 투명
        canvasColor: Colors.transparent, // Canvas 배경 투명
      ),
      home: const FloatingTaskView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
