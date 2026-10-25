import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'home_screen.dart';

class home1 extends StatefulWidget {
  const home1({super.key});

  @override
  State<home1> createState() => _home1State();
}

class _home1State extends State<home1>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _cardController;
  late AnimationController _loadingController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late Animation<Offset> _titleOffset;
  late Animation<double> _titleOpacity;

  late Animation<Offset> _descOffset;
  late Animation<double> _descOpacity;

  late Animation<Offset> _cardOffset;
  late Animation<double> _cardOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoScale = Tween<double>(
      begin: .5,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_logoController);

    _titleOffset = Tween<Offset>(
      begin: const Offset(0, .8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _titleOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_textController);

    _descOffset = Tween<Offset>(
      begin: const Offset(0, .6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _descOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_textController);

    _cardOffset = Tween<Offset>(
      begin: const Offset(0, .8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeOutBack,
      ),
    );

    _cardOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_cardController);

    _startAnimation();
  }

  Future<void> _startAnimation() async {

    _logoController.forward();

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    _textController.forward();

    await Future.delayed(
      const Duration(milliseconds: 900),
    );

    _cardController.forward();

    _loadingController.repeat();

    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, animation, __) =>
            FadeTransition(
              opacity: animation,
              
              child: const HomeScreen(),
            ),
      ),
    );
  }

  @override
  void dispose() {

    _logoController.dispose();
    _textController.dispose();
    _cardController.dispose();
    _loadingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: [

              Color(0xffF8FBF6),

              Color(0xffEEF8F1),

              Color(0xffE6F5EA),

            ],

          ),

        ),

        child: Stack(

          children: [

            const Positioned(
              top: -80,
              right: -80,
              child: _Circle(
                size: 220,
                color: Color(0x1500AA55),
              ),
            ),

            const Positioned(
              bottom: -100,
              left: -100,
              child: _Circle(
                size: 260,
                color: Color(0x1200AA55),
              ),
            ),

            const Positioned(
              top: 140,
              left: -60,
              child: _Circle(
                size: 120,
                color: Color(0x1000AA55),
              ),
            ),

            SafeArea(

              child: Center(

                child: SingleChildScrollView(

                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                  ),

                  child: Column(

                    children: [                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (_, __) {
                          return FadeTransition(
                            opacity: _logoOpacity,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(35),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xff2E7D32)
                                          .withOpacity(.18),
                                      blurRadius: 35,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Hero(
                                    tag: "app_logo",
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(25),
                                      child: Image.asset(
                                        "assets/images/icon.jpeg",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      SlideTransition(
                        position: _titleOffset,
                        child: FadeTransition(
                          opacity: _titleOpacity,
                          child: const Text(
                            "مشروع خيركم",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2E7D32),
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      SlideTransition(
                        position: _descOffset,
                        child: FadeTransition(
                          opacity: _descOpacity,
                          child: const Text(
                            "رفيقك اليومي للمحافظة على العبادات\nوالأعمال الصالحة",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xff546E7A),
                              height: 1.8,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      FadeTransition(
                        opacity: _descOpacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.65),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            "﴿ فَاسْتَبِقُوا الْخَيْرَاتِ ﴾",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xffB8860B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 55),                      SlideTransition(
                        position: _cardOffset,
                        child: FadeTransition(
                          opacity: _cardOpacity,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 22,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.75),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: const Color(0xffA5D6A7),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Column(
                              children: [

                                Icon(
                                  Icons.favorite,
                                  color: Color(0xff2E7D32),
                                  size: 34,
                                ),

                                SizedBox(height: 15),

                                Text(
                                  "إعداد وتطوير",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),

                                SizedBox(height: 8),

                                Text(
                                  "مجاهد مهند مقدادي",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (_, __) {
                          return Transform.rotate(
                            angle: _loadingController.value * pi * 2,
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xff2E7D32),
                                  width: 3,
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Color(0xff2E7D32),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "جاري تجهيز التطبيق...",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        "الإصدار 1.0.0",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "اللهم أعنّا على ذكرك وشكرك وحسن عبادتك",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                                          ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final Color color;

  const _Circle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
