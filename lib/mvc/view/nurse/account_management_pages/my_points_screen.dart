import 'package:flutter/material.dart';
import 'package:homecare/widgets/header_widget.dart';

class PointsScreen extends StatefulWidget {
  //final int points;
  final int stars;

  const PointsScreen({super.key, /*required this.points,*/ required this.stars});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  //late Animation<double> _pointsAnimation;
  late Animation<double> _starsAnimation;
  //late Animation<int> _pointsCountAnimation;
  late Animation<double> _cupAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Delay the animation by 1 second
    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.forward();
    });

    // Points animation (counting up effect)
    /*_pointsCountAnimation = IntTween(begin: 0, end: widget.points).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );*/

    // Stars animation (scaling and popping effect)
    _starsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Points text fade animation
    /*_pointsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );*/

    // Cup icon animation (scaling effect)
    _cupAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.75, curve: Curves.bounceOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            HeaderWidget(context, title: 'التقييم'),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated "My Points" text
                  /*FadeTransition(
                    opacity: _pointsAnimation,
                    child: const Text(
                      'نقاطي',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),*/
                  // Animated prize cup icon
                  AnimatedBuilder(
                    animation: _cupAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _cupAnimation.value,
                        child: Image.asset('assets/icons/trophy.gif', scale: 3.0),
                      );
                    },
                  ),
                  // Animated points value (counting up effect)
                  /*AnimatedBuilder(
                    animation: _pointsCountAnimation,
                    builder: (context, child) {
                      return Text(
                        '${_pointsCountAnimation.value}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),*/
                  // Animated stars (scaling and popping effect)
                  AnimatedBuilder(
                    animation: _starsAnimation,
                    builder: (context, child) {
                      // Hide stars until the points animation is complete
                      if (_starsAnimation.value == 0) {
                        return const SizedBox.shrink(); // Hide stars
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          // Calculate the scale for each star (pop-in effect)
                          double scale = index < widget.stars
                              ? _starsAnimation.value
                              : 0.5 + (_starsAnimation.value * 0.5);

                          return Transform.scale(
                            scale: scale,
                            child: Icon(
                              Icons.star,
                              size: 40,
                              color: index < widget.stars ? Colors.amber : Colors.grey,
                            ),
                          );
                        }),
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
}
