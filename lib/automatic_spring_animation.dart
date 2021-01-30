library automatic_spring_animation;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

class AnimtedSpring extends StatefulWidget {
  AnimtedSpring({
    Key? key,
    required this.child,
    this.spring = const SpringDescription(mass: 10, stiffness: 1, damping: 1),
    this.shouldAnimate,
  }) : super(key: key);

  final Widget child;
  final SpringDescription spring;
  final AnimationAction Function(Offset oldAnchor, Offset newAnchor,
      Offset currentPosition, bool animating)? shouldAnimate;

  @override
  _AnimtedSpringState createState() => _AnimtedSpringState();
}

enum AnimationAction { snap, animate, freeze }

class _AnimtedSpringState extends State<AnimtedSpring>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  Offset? _position;
  Offset _positionState = Offset.zero;
  Animation<Offset>? _positionAnimation;
  late AnimationAction Function(Offset oldAnchor, Offset newAnchor,
      Offset currentPosition, bool animating) _shouldAnimate;

  void activateAnimationCallback(Offset newPosition) {
    bool initial = false;
    if (_position == null) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        setState(() {
          _positionState = newPosition;
        });
      });
      _position = newPosition;
      initial = true;
    }
    AnimationAction action = _shouldAnimate(
        _position!, newPosition, _positionState, _controller.isAnimating);
    if (action == AnimationAction.animate) {
      _positionAnimation =
          _controller.drive(Tween(begin: _positionState, end: newPosition));
      var simulation =
          SpringSimulation(widget.spring, 0, 1, _controller.velocity);
      _controller.stop();
      _controller.animateWith(simulation);
    } else if (action == AnimationAction.snap && !initial) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        setState(() {
          _positionState = newPosition;
        });
      });
    }
    _position = newPosition;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      setState(() {
        _positionState = _positionAnimation!.value;
      });
    });
    _shouldAnimate = widget.shouldAnimate ??
        (Offset oldAnchor, Offset newAnchor, Offset currentPosition,
            bool animating) {
          if (oldAnchor != newAnchor &&
              (currentPosition - newAnchor).distance > 10) {
            return AnimationAction.animate;
          } else {
            return AnimationAction.freeze;
          }
        };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpringTransform(
      position: _positionState,
      activateAnimationCallback: activateAnimationCallback,
      child: AnimatedSize(
        duration: Duration(milliseconds: 500),
        vsync: this,
        child: widget.child,
      ),
    );
  }
}

class SpringTransform extends SingleChildRenderObjectWidget {
  final void Function(Offset newPosition)? _activateAnimationCallback;
  final Offset? _position;

  SpringTransform(
      {Key? key,
      Widget? child,
      Offset? position,
      void Function(Offset newPosition)? activateAnimationCallback})
      : _position = position,
        _activateAnimationCallback = activateAnimationCallback,
        super(key: key, child: child);

  @override
  RenderSpringTransform createRenderObject(BuildContext context) {
    return RenderSpringTransform(
        activateAnimationCallback: _activateAnimationCallback,
        position: _position);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSpringTransform renderObject) {
    renderObject
      ..position = _position
      ..activateAnimationCallback = _activateAnimationCallback;
    super.updateRenderObject(context, renderObject);
  }
}

class RenderSpringTransform extends RenderProxyBox {
  RenderSpringTransform(
      {Offset? position,
      void Function(Offset newPosition)? activateAnimationCallback})
      : _position = position,
        _activateAnimationCallback = activateAnimationCallback,
        super();

  void Function(Offset newPosition)? _activateAnimationCallback;

  void Function(Offset newPosition)? get activateAnimationCallback =>
      _activateAnimationCallback;

  set activateAnimationCallback(
      void Function(Offset newPosition)? activateAnimationCallback) {
    if (_activateAnimationCallback == activateAnimationCallback) return;
    _activateAnimationCallback = activateAnimationCallback;
    markNeedsPaint();
  }

  Offset? _position;

  Offset? get position => _position;

  set position(Offset? position) {
    if (_position == position) return;
    _position = position;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return hitTestChildren(result, position: position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithRawTransform(
      transform: Matrix4.identity(),
      position: position - globalToLocal(this.position ?? Offset.zero),
      hitTest: (result, position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (activateAnimationCallback != null) {
      activateAnimationCallback!(offset);
    }
    super.paint(context, position ?? offset);
  }
}
