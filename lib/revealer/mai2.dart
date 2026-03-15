import 'package:flutter/material.dart';
import 'dart:math' as math;

class Mai2Controller extends ChangeNotifier {
  List<bool> a = List.filled(8, false);
  List<bool> b = List.filled(8, false);
  List<bool> c = List.filled(2, false);
  List<bool> d = List.filled(8, false);
  List<bool> e = List.filled(8, false);

  void updateData(List<bool> na, List<bool> nb, List<bool> nc,
      List<bool> nd, List<bool> ne) {
    a = na; b = nb; c = nc; d = nd; e = ne;
    notifyListeners();
  }
}

class Mai2Page extends StatefulWidget {
  const Mai2Page({super.key});
  @override
  State<Mai2Page> createState() => _Mai2PageState();
}

class _Mai2PageState extends State<Mai2Page> {
  final Mai2Controller controller = Mai2Controller();

  @override
  void initState() {
    super.initState();
    controller.updateData(
      List.filled(8, false),
      List.filled(8, false),
      List.filled(2, false),
      List.filled(8, false),
      List.filled(8, false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) => CustomPaint(
                  painter: Mai2Painter(controller: controller),
                  child: Container(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Mai2Painter extends CustomPainter {
  final Mai2Controller controller;
  const Mai2Painter({required this.controller});

  static const Color _gray = Color(0xCCDDE3EE);
  static const Color _blue = Color(0xFF1A3FFF);

  static const double kRC   = 0.175;
  static const double kRSUN = 0.320;
  static const double kRB   = 0.555;
  static const double kRBG  = 0.648;
  static const double kROUT = 0.950;
  static const double kRE = (kRB + kRBG) / 2.0;
  static const double kEH = (kRBG - kRB) * 1.80;
  static const double kDH = math.pi / 24.0;
  static const double kAH = math.pi / 12.0;
  static const double kSW = 0.018;

  @override
  void paint(Canvas canvas, Size size) {
    final double R      = math.min(size.width, size.height) / 2.0;
    final Offset centre = Offset(size.width / 2.0, size.height / 2.0);
    final double sw     = math.max(1.5, R * kSW);
    final double fnt    = R * 0.058;
    final Rect   bounds = Offset.zero & size;

    final double rC   = R * kRC;
    final double rSUN = R * kRSUN;
    final double rB   = R * kRB;
    final double rBG  = R * kRBG;
    final double rOut = R * kROUT;
    final double rE   = R * kRE;
    final double eH   = R * kEH;
    final Offset o    = centre;

    final Path cOct  = _oct(o, rC,  -math.pi / 2 + math.pi / 8);
    final Path bOct  = _oct(o, rB,  -math.pi / 2);
    final Path bgOct = _oct(o, rBG, -math.pi / 2);
    final Path outerCirc = Path()
      ..addOval(Rect.fromCircle(center: o, radius: rOut));
    final Path adRegion =
    Path.combine(PathOperation.difference, outerCirc, bgOct);
    final Path bRegion =
    Path.combine(PathOperation.difference, bOct, cOct);

    final Path sunShape = Path.combine(
      PathOperation.union,
      _square(o, rSUN, -math.pi / 2),
      _square(o, rSUN, -math.pi / 2 + math.pi / 4),
    );

    final Paint grayP  = Paint()..style = PaintingStyle.fill..color = _gray;
    final Paint blueP  = Paint()..style = PaintingStyle.fill..color = _blue;
    final Paint clearF = Paint()
      ..style     = PaintingStyle.fill
      ..blendMode = BlendMode.clear;
    final Paint clearS = Paint()
      ..style       = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeJoin  = StrokeJoin.round
      ..strokeCap   = StrokeCap.round
      ..blendMode   = BlendMode.clear;

    void fillBlock(Path p, bool active) =>
        canvas.drawPath(p, active ? blueP : grayP);

    final List<Path> adPaths = [];
    final List<bool> adActv  = [];
    final List<Path> bPaths  = [];
    final List<bool> bActv   = [];
    final List<Path> cPaths  = [];
    final List<bool> cActv   = [];
    final List<Path> ePaths  = [];
    final List<bool> eActv   = [];

    final List<Offset>  lblPos  = [];
    final List<String>  lblText = [];
    final List<double>  lblSize = [];

    final double rLbl = (rBG + rOut) * 0.5;

    for (int i = 0; i < 8; i++) {
      final double ai = -math.pi / 2 + i * math.pi / 4;
      final double bi = ai + math.pi / 8;

      adPaths.add(Path.combine(PathOperation.intersect,
          _sector(o, rOut * 1.01, ai - kDH, kDH * 2.0), adRegion));
      adActv.add(controller.d[i]);
      lblPos.add(Offset(o.dx + rLbl * math.cos(ai), o.dy + rLbl * math.sin(ai)));
      lblText.add('D${i + 1}');
      lblSize.add(fnt * 0.46);

      adPaths.add(Path.combine(PathOperation.intersect,
          _sector(o, rOut * 1.01, bi - kAH, kAH * 2.0), adRegion));
      adActv.add(controller.a[i]);
      lblPos.add(Offset(o.dx + rLbl * math.cos(bi), o.dy + rLbl * math.sin(bi)));
      lblText.add('A${i + 1}');
      lblSize.add(fnt * 0.62);

      bPaths.add(Path.combine(PathOperation.intersect,
          _sector(o, rB * 1.01, ai, math.pi / 4), bRegion));
      bActv.add(controller.b[i]);
      lblPos.add(Offset(o.dx + rB * 0.72 * math.cos(bi),
          o.dy + rB * 0.72 * math.sin(bi)));
      lblText.add('B${i + 1}');
      lblSize.add(fnt * 0.50);

      final Offset ec = Offset(o.dx + rE * math.cos(ai), o.dy + rE * math.sin(ai));
      final Path ep = Path();
      for (int j = 0; j < 4; j++) {
        final double ca = ai + j * math.pi / 2;
        final Offset pt = Offset(ec.dx + eH * math.cos(ca), ec.dy + eH * math.sin(ca));
        j == 0 ? ep.moveTo(pt.dx, pt.dy) : ep.lineTo(pt.dx, pt.dy);
      }
      ep.close();
      ePaths.add(ep);
      eActv.add(controller.e[i]);
      lblPos.add(ec);
      lblText.add('E${i + 1}');
      lblSize.add(fnt * 0.36);
    }

    final double pad = rC * 4.0;
    cPaths.add(Path.combine(PathOperation.intersect, cOct,
        Path()..addRect(Rect.fromLTRB(o.dx,       o.dy - pad, o.dx + pad, o.dy + pad))));
    cActv.add(controller.c[0]);
    lblPos.add(Offset(o.dx + rC * 0.42, o.dy)); lblText.add('C1'); lblSize.add(fnt * 0.60);

    cPaths.add(Path.combine(PathOperation.intersect, cOct,
        Path()..addRect(Rect.fromLTRB(o.dx - pad, o.dy - pad, o.dx,       o.dy + pad))));
    cActv.add(controller.c[1]);
    lblPos.add(Offset(o.dx - rC * 0.42, o.dy)); lblText.add('C2'); lblSize.add(fnt * 0.60);

    canvas.saveLayer(bounds, Paint());

    for (int i = 0; i < adPaths.length; i++) fillBlock(adPaths[i], adActv[i]);
    for (int i = 0; i < bPaths.length; i++) fillBlock(bPaths[i], bActv[i]);
    canvas.drawPath(sunShape, clearF);
    for (int i = 0; i < cPaths.length; i++) fillBlock(cPaths[i], cActv[i]);
    for (final p in adPaths) canvas.drawPath(p, clearS);
    for (final p in bPaths)  canvas.drawPath(p, clearS);
    for (final p in cPaths)  canvas.drawPath(p, clearS);
    for (final p in ePaths) canvas.drawPath(p, clearF);
    for (int i = 0; i < ePaths.length; i++) fillBlock(ePaths[i], eActv[i]);
    for (final p in ePaths) canvas.drawPath(p, clearS);

    canvas.restore();

    for (int i = 0; i < lblPos.length; i++) {
      _label(canvas, lblPos[i], lblText[i], lblSize[i]);
    }
  }
  Path _oct(Offset c, double r, double a0) {
    final Path p = Path();
    for (int k = 0; k < 8; k++) {
      final double a = a0 + k * math.pi / 4;
      final Offset v = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      k == 0 ? p.moveTo(v.dx, v.dy) : p.lineTo(v.dx, v.dy);
    }
    return p..close();
  }

  Path _square(Offset c, double r, double a0) {
    final Path p = Path();
    for (int k = 0; k < 4; k++) {
      final double a = a0 + k * math.pi / 2;
      final Offset v = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      k == 0 ? p.moveTo(v.dx, v.dy) : p.lineTo(v.dx, v.dy);
    }
    return p..close();
  }

  Path _sector(Offset c, double r, double start, double sweep) {
    final Path p = Path()..moveTo(c.dx, c.dy);
    p.arcTo(Rect.fromCircle(center: c, radius: r), start, sweep, false);
    return p..close();
  }

  void _label(Canvas canvas, Offset pos, String text, double size) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: size.clamp(5.0, 40.0),
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2.0, tp.height / 2.0));
  }

  @override
  bool shouldRepaint(covariant Mai2Painter old) => true;
}