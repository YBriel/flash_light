import 'dart:async';

import 'package:flutter/material.dart';
import 'package:torch_controller/torch_controller.dart';

void main(){
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

  late Timer? _flashTimer;

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  void initState() {
    super.initState();
  }


  Future<void> _toggleFlash() async {
    if (isFlashOn) {
      print("点击按钮{$isFlashOn}");
      try {
        _flashTimer = Timer.periodic(const Duration(milliseconds: 100), // 调整为 200ms 降低频率
                (timer)  {
               controller.toggle(intensity: 1);
          }
        );
      } catch (e) {
        print("闪光灯控制失败: $e");
      }
    }else{
      print('关闭闪光灯了{$isFlashOn}');
      _flashTimer?.cancel();
      await controller.toggle(intensity: 1);
    }
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
                onPressed: () => {controller.toggle(intensity: 1)},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                ),
                child: const Text(
                    '开启闪光灯⚡️', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.flash_auto_sharp, size: 32),
                    color: Colors.teal,
                    onPressed: () {
                      print('按钮');
                      setState(() => isFlashOn = true);
                      _toggleFlash();

                    },                  ),
                  const Text('开闪', style: TextStyle(color: Colors.teal)),
                  IconButton(
                    icon: const Icon(Icons.format_list_bulleted, size: 32),
                    color: Colors.teal,
                    onPressed: (){
                      print('关闭闪光灯');
                      setState((){
                        isFlashOn = false;
                        _flashTimer?.cancel();
                        controller.isTorchActive.then((value) {
                          if (value == true) {
                            controller.toggle(intensity: 1);
                          }
                        });
                      }

                      );
                      _flashTimer?.cancel();
                    },
                  ),
                  const Text(
                      '饶它条狗命', style: TextStyle(color: Colors.teal)),

                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}