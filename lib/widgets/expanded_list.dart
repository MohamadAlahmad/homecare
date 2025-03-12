import 'package:flutter/material.dart';

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final double height;
  final bool expand;
  final Duration forwardDuration;
  final Duration reverseDuration;

  const ExpandedSection({super.key,
    this.expand = false,
    required this.child,
    required this.height,
    required this.forwardDuration,
    required this.reverseDuration,
  });

  @override
  State<ExpandedSection> createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: Container(
        padding: const EdgeInsets.only(bottom: 5),
        /*constraints: BoxConstraints(
          minWidth: double.infinity,
          maxHeight: widget.height > 5 ? 195 : widget.height == 1 ? 55 : widget.height * 50.0,
        ),*/
        height: widget.height,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  /// Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    );
  }
  void _runExpandCheck() {
    if (widget.expand) {
      expandController.animateTo(1.0, duration: widget.forwardDuration);
    } else {
      expandController.animateTo(0.0, duration: widget.reverseDuration);
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

}
