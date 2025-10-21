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

class _ZoomableStoryItemState extends State<ZoomableStoryItem> {
  final TransformationController _transformationController =
      TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale > 1.0 && !_isZoomed) {
      setState(() {
        _isZoomed = true;
      });
      widget.storyController?.pause();
    } else if (scale <= 1.0 && _isZoomed) {
      setState(() {
        _isZoomed = false;
      });
      widget.storyController?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 1.0,
      maxScale: 4.0,
      onInteractionEnd: (details) {
        // Snap back to original position if not zoomed.
        if (_transformationController.value.getMaxScaleOnAxis() <= 1.0) {
          _transformationController.value = Matrix4.identity();
        }
      },
      child: widget.child,
    );
  }
}
