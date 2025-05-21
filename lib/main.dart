import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torch_controller/torch_controller.dart';

void main() {
  TorchController().initialize();
  runApp(MorseApp());
}

class MorseApp extends StatefulWidget {
  const MorseApp({super.key});

  @override
  _MorseAppState createState() => _MorseAppState();
}

class _MorseAppState extends State<MorseApp> {
  bool isFlashOn = false;
  final controller = TorchController();
  Timer? _flashTimer;
  bool _isFlashing = false;
  bool _actualTorchState = false;

  @override
  void dispose() {
    _stopFlashing();
    super.dispose();
  }

  Future<void> _startFlashing() async {
    if (_isFlashing) return;

    // 确保初始状态为关闭
    final isActive = await controller.isTorchActive;
    if (isActive == true) {
      await controller.toggle(intensity: 1);
    }

    setState(() => _isFlashing = true);

    _flashTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) async {
        await controller.toggle(intensity: 1);
        // 同步真实硬件状态
        _actualTorchState = !_actualTorchState;
      },
    );
  }

  Future<void> _stopFlashing() async {
    if (!_isFlashing) return;

    _flashTimer?.cancel();
    _flashTimer = null;

    // 双重保障关闭闪光灯
    try {
      final isActive = await controller.isTorchActive;
      if (isActive == true) {
        await controller.toggle(intensity: 1);
      }
    } catch (e) {
      debugPrint("关闭闪光灯失败: $e");
    }

    setState(() {
      _isFlashing = false;
      _actualTorchState = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blueGrey, Colors.black87],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                '闪死远光狗APP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  controller.toggle(intensity: 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('开启闪光灯⚡️', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.flash_auto_sharp, size: 32),
                    color: Colors.teal,
                    onPressed: _startFlashing,
                  ),
                  const Text('开闪', style: TextStyle(color: Colors.teal)),
                  IconButton(
                    icon: const Icon(Icons.format_list_bulleted, size: 32),
                    color: Colors.teal,
                    onPressed: _stopFlashing,
                  ),
                  const Text('饶它条狗命', style: TextStyle(color: Colors.teal)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
