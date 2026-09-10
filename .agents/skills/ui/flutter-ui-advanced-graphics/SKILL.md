---
name: flutter-ui-advanced-graphics
description: Advanced graphics, CustomPainter, Canvas drawing, ShaderMasks, physics-based motion (SpringSimulation), and Rive/Lottie runtime integration skill. Use when creating custom charts, procedural graphics, canvas particle effects, shader animations, or complex physics-driven gestures.
---

# Flutter Advanced Graphics, CustomPainter & Physics Motion Guide (Tiers 3 & 4)

## 1. Overview & When to Apply

Use this skill whenever:
- Implementing custom charts, procedural backgrounds, wave shapes, or circular gauges via `CustomPainter`.
- Drawing directly to the 2D Skia/Impeller pipeline using `Canvas`, `Path`, and `Paint`.
- Applying custom GPU fragment shaders or `ShaderMask` gradient effects.
- Implementing gesture-driven physical springs (`SpringSimulation`, `FrictionSimulation`).
- Integrating dynamic vector runtime assets via Rive (`rive`) or Lottie animations.

---

## 2. Prerequisites & Related Skills

| Relation | Skill | Purpose |
| :--- | :--- | :--- |
| **Parent Hub** | [flutter-ui-hub](../flutter-ui-hub/SKILL.md) | Presentation laws and UI routing. |
| **Basic Animations** | [flutter-ui-animations](../flutter-ui-animations/SKILL.md) | Standard animation controllers & curves. |
| **Performance** | [flutter-ui-performance](../flutter-ui-performance/SKILL.md) | Layer isolation using `RepaintBoundary`. |

---

## 3. High-Performance CustomPainter Architecture

### Critical Performance Rules for Canvas Drawing:
1. **Always wrap in `RepaintBoundary`:** Prevents custom canvas draws from invalidating adjacent widget render layers.
2. **Implement `shouldRepaint` accurately:** Never return `true` blindly. Compare input fields to avoid repainting unchanged frames.
3. **Avoid object allocations inside `paint()`:** Allocate `Paint`, `Path`, and `TextStyle` objects outside or reuse fields.

### 3.1 Custom Circular Progress Gauge Example

```dart
class CircularGaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const CircularGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    this.strokeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw active progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// Widget integration with RepaintBoundary:
class CircularProgressGauge extends StatelessWidget {
  final double progress;

  const CircularProgressGauge({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(120, 120),
        painter: CircularGaugePainter(
          progress: progress,
          trackColor: colorScheme.surfaceContainerHighest,
          progressColor: colorScheme.primary,
        ),
      ),
    );
  }
}
```

---

## 4. Physics-Based Motion (SpringSimulation)

For natural gesture interactions, use physics simulations instead of fixed-duration duration curves:

```dart
class PhysicsSpringDraggable extends StatefulWidget {
  final Widget child;

  const PhysicsSpringDraggable({super.key, required this.child});

  @override
  State<PhysicsSpringDraggable> createState() => _PhysicsSpringDraggableState();
}

class _PhysicsSpringDraggableState extends State<PhysicsSpringDraggable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Alignment _dragAlignment = Alignment.center;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSpringAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      AlignmentTween(begin: _dragAlignment, end: Alignment.center),
    );

    // Calculate spring physics parameters
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onPanDown: (details) => _controller.stop(),
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            details.delta.dx / (size.width / 2),
            details.delta.dy / (size.height / 2),
          );
        });
      },
      onPanEnd: (details) {
        _runSpringAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Align(
        alignment: _dragAlignment,
        child: widget.child,
      ),
    );
  }
}
```

---

## 5. Anti-Patterns (Strictly Prohibited)

| Anti-Pattern | Severity | Corrective Action |
| :--- | :--- | :--- |
| Returning `true` unconditionally inside `shouldRepaint` | **CRITICAL** | Compare all drawing parameters (`oldDelegate.prop != prop`). |
| Allocating heavy resources (images, shaders, paths) inside `paint()` loop | **HIGH** | Precompute or allocate paths outside the paint callback. |
| Missing `RepaintBoundary` on animated or complex `CustomPainter` widgets | **HIGH** | Wrap the `CustomPaint` in `RepaintBoundary`. |
| Hardcoding canvas colors rather than receiving them from Theme tokens | **MEDIUM** | Pass `Theme.of(context).colorScheme` colors to the painter constructor. |

---

## 6. Verification Checklist

- [ ] CustomPainter class implements an accurate `shouldRepaint` condition.
- [ ] No allocations of heavy objects occur inside `paint(Canvas canvas, Size size)`.
- [ ] Complex or animated custom paintings are enclosed in `RepaintBoundary`.
- [ ] Physics simulations (`SpringSimulation`) correctly dispose of controller tickers.
- [ ] Canvas colors are derived dynamically from Material 3 `ColorScheme` tokens.
