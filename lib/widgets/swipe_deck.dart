import 'package:flutter/material.dart';

enum SwipeResult { like, dislike }

class SwipeDeckController<T extends Object> {
  _SwipeDeckState<T>? _state;
  void _attach(_SwipeDeckState<T> s) => _state = s;
  void _detach(_SwipeDeckState<T> s) {
    if (_state == s) _state = null;
  }

  void swipeLeft() => _state?._programmaticSwipe(SwipeResult.dislike);
  void swipeRight() => _state?._programmaticSwipe(SwipeResult.like);
  T? get current => _state?._currentTop();
}

class SwipeDeck<T extends Object> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final void Function(T item, SwipeResult result) onSwipe;
  final VoidCallback? onEmpty;
  final SwipeDeckController<T>? controller;

  const SwipeDeck({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onSwipe,
    this.onEmpty,
    this.controller,
  });

  @override
  State<SwipeDeck<T>> createState() => _SwipeDeckState<T>();
}

class _SwipeDeckState<T extends Object> extends State<SwipeDeck<T>> with SingleTickerProviderStateMixin {
  late List<T> _items;
  Offset _drag = Offset.zero;
  final double _threshold = 120;
  late AnimationController _anim;
  late Animation<Offset> _slideBack;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.items);
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
    _slideBack = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_anim)
      ..addListener(() => setState(() => _drag = _slideBack.value));
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant SwipeDeck<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (!identical(oldWidget.items, widget.items)) {
      _items = List.of(widget.items);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _anim.dispose();
    super.dispose();
  }

  void _programmaticSwipe(SwipeResult res) {
    if (_items.isEmpty) return;
    final item = _items.removeAt(0);
    setState(() {});
    widget.onSwipe(item, res);
    if (_items.isEmpty) widget.onEmpty?.call();
  }

  void _onDragEnd(DraggableDetails d) {
    if (_drag.dx > _threshold) {
      _commit(SwipeResult.like);
    } else if (_drag.dx < -_threshold) {
      _commit(SwipeResult.dislike);
    } else {
      _slideBack = Tween<Offset>(begin: _drag, end: Offset.zero).animate(_anim);
      _anim.forward(from: 0);
    }
  }

  void _commit(SwipeResult res) {
    if (_items.isEmpty) return;
    final item = _items.removeAt(0);
    _drag = Offset.zero;
    setState(() {});
    widget.onSwipe(item, res);
    if (_items.isEmpty) widget.onEmpty?.call();
  }

  T? _currentTop() => _items.isNotEmpty ? _items.first : null;

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const Center(child: Text('No more items'));
    }

    final top = _items.first;
    final next = _items.length > 1 ? _items[1] : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (next != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Transform.scale(
              scale: 0.96,
              child: widget.itemBuilder(next, 1),
            ),
          ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, _) {
                final angle = (_drag.dx / 300) * 0.08;
                return Draggable<Object>(
                  data: top as Object,
                  feedback: const SizedBox.shrink(),
                  childWhenDragging: const SizedBox.shrink(),
                  onDragUpdate: (d) => setState(() => _drag = d.delta + _drag),
                  onDragEnd: _onDragEnd,
                  child: Transform.translate(
                    offset: _drag,
                    child: Transform.rotate(
                      angle: angle,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          widget.itemBuilder(top, 0),
                          _buildTag(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag() {
    final likeOpacity = (_drag.dx / _threshold).clamp(0.0, 1.0);
    final dislikeOpacity = (-_drag.dx / _threshold).clamp(0.0, 1.0);
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 24,
            left: 24,
            child: Opacity(
              opacity: likeOpacity,
              child: _tag('AGREE', Colors.green),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: Opacity(
              opacity: dislikeOpacity,
              child: _tag('PASS', Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.black26,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
