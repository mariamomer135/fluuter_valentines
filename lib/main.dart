import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(ValentinesApp());
}

class ValentinesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ValentinesScreen(),
    );
  }
}

class ValentinesScreen extends StatefulWidget {
  @override
  _ValentinesScreenState createState() => _ValentinesScreenState();
}

class _ValentinesScreenState extends State<ValentinesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;
  int _countdown = 10;
  bool _countdownStarted = false;
  List<ConfettiParticle> _confettiParticles = [];
  
  List<String> _messages = [
    "You are my heart's delight! ❤️",
    "Happy Valentine's Day, love! 💖",
    "Every beat of my heart is for you! 💓",
    "Love is in the air! 💕",
    "You make my heart skip a beat! 💘"
  ];
  
  String? _selectedMessage;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
  }

  void _startCountdown() {
    if (_selectedMessage == null) return;

    setState(() {
      _countdownStarted = true;
      _countdown = 10;
      _opacity = 0.0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _stopAnimation();
          _showMessage();
          _startConfetti();
          timer.cancel();
        }
      });
    });
  }

  void _stopAnimation() {
    _controller.stop();
  }

  void _showMessage() {
    setState(() {
      _opacity = 1.0; // Fade in selected message
    });
  }

  void _startConfetti() {
    setState(() {
      _confettiParticles = List.generate(20, (index) {
        return ConfettiParticle(
          offset: Offset(Random().nextDouble() * 300, -100),
          angle: (index % 2 == 0) ? 1 : -1,
          speed: 2 + Random().nextInt(4),
        );
      });
    });

    Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        for (var particle in _confettiParticles) {
          particle.offset += Offset(0, particle.speed.toDouble());
        }
      });

      if (_confettiParticles.isNotEmpty &&
          _confettiParticles.every((p) => p.offset.dy > 600)) {
        timer.cancel();
        setState(() {
          _confettiParticles.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: Image.asset(
                        "assets/hearts.png",
                        width: 120,
                        height: 120,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.favorite, size: 120, color: Colors.red);
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                if (!_countdownStarted) ...[
                  DropdownButton<String>(
                    hint: Text("Select a Valentine's message"),
                    value: _selectedMessage,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMessage = newValue;
                      });
                    },
                    items: _messages.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selectedMessage == null ? null : _startCountdown,
                    child: Text("Start Countdown"),
                  ),
                ] else ...[
                  Text(
                    "Countdown: $_countdown",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  AnimatedOpacity(
                    opacity: _opacity,
                    duration: Duration(milliseconds: 500),
                    child: Text(
                      _selectedMessage ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ..._confettiParticles.map((particle) => Positioned(
                left: particle.offset.dx,
                top: particle.offset.dy,
                child: Icon(Icons.favorite, color: Colors.red, size: 16),
              )),
        ],
      ),
    );
  }
}

class ConfettiParticle {
  Offset offset;
  final int speed;
  final int angle;

  ConfettiParticle({
    required this.offset,
    required this.speed,
    required this.angle,
  });
}
