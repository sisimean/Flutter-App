import 'dart:async';
import 'package:flutter/material.dart';

class TerminalLoader extends StatefulWidget {
  const TerminalLoader({super.key});

  @override
  State<TerminalLoader> createState() => _TerminalLoaderState();
}

class _TerminalLoaderState extends State<TerminalLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  String _displayText = "";
  String _fullText = "Loading...";
  int _index = 0;
  bool _typing = true;
  bool _cursorVisible = true;

  @override
  void initState() {
    super.initState();

    // Animation controller for blinking cursor
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // Typing effect loop
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        if (_typing) {
          if (_index < _fullText.length) {
            _displayText += _fullText[_index];
            _index++;
          } else {
            _typing = false;
          }
        } else {
          if (_displayText.isNotEmpty) {
            _displayText = _displayText.substring(0, _displayText.length - 1);
          } else {
            _typing = true;
            _index = 0;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        height: 220,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1c1c1c),
          border: Border.all(color: Colors.white38),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 15)],
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF343434),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildControlCircle(Colors.red),
                        const SizedBox(width: 7),
                        _buildControlCircle(Colors.yellow),
                        const SizedBox(width: 7),
                        _buildControlCircle(Colors.green),
                      ],
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Customer System',
                      style: TextStyle(
                        color: Color(0xEEEEEEEEC1),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    _displayText,
                    style: const TextStyle(
                      color: Color(0xFF00C400),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      return Opacity(
                        opacity: _controller.value > 0.5 ? 1 : 0,
                        child: const Text(
                          '|',
                          style: TextStyle(
                            color: Color(0xFF00C400),
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCircle(Color color) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
