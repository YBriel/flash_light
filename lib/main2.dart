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
                colors: [Colors.blueGrey, Colors.black87]),
          ),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _TorchStatusIndicator(isActive: _actualTorchState),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startFlashing,
                child: const Text('开始频闪'),
              ),
              ElevatedButton(
                onPressed: _stopFlashing,
                child: const Text('停止频闪'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TorchStatusIndicator extends StatelessWidget {
  final bool isActive;

  const _TorchStatusIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.yellow : Colors.grey,
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: Colors.yellow.withOpacity(0.8),
              blurRadius: 20,
              spreadRadius: 10,
            ),
        ],
      ),
    );
  }
}