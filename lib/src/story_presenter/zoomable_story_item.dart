import 'package:flutter/material.dart';
import 'package:flutter_story_presenter/flutter_story_presenter.dart';

class ZoomableStoryItem extends StatefulWidget {
  final Widget child;
  final FlutterStoryController? storyController;

  const ZoomableStoryItem({
    required this.child,
    this.storyController,
    super.key,
  });

  @override
  State<ZoomableStoryItem> createState() => _ZoomableStoryItemState();
}

class _ZoomableStoryItemState extends State<ZoomableStoryItem>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();

  late AnimationController _animationController;
  Animation<Matrix4>? _resetAnimation;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        _transformationController.value =
            _resetAnimation?.value ?? Matrix4.identity();
      });

    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final zooming = scale > 1.0;
    if (zooming != _isZoomed) {
      setState(() => _isZoomed = zooming);
    }
  }

  /// Smoothly reset zoom & pan
  void _resetZoom() {
    _resetAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        // Pause when user touches screen
        widget.storyController?.pause();
      },
      onTapUp: (_) {
        // Resume story and reset zoom
        _resetZoom();
        widget.storyController?.play();
      },
      onTapCancel: () {
        _resetZoom();
        widget.storyController?.play();
      },
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        onInteractionStart: (_) {
          widget.storyController?.pause();
        },
        onInteractionEnd: (_) {
          _resetZoom();
          widget.storyController?.play();
        },
        child: widget.child,
      ),
    );
  }
}
