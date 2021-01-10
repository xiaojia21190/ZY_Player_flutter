import 'dart:math';

import 'package:flutter/material.dart';

class CircleProgress extends StatefulWidget {
  final Progress progress;

  CircleProgress({Key key, this.progress}) : super(key: key);

  @override
  _CircleProgressState createState() => _CircleProgressState();
}

///信息描述类 [value]为进度，在0~1之间,进度条颜色[color]，
///未完成的颜色[backgroundColor],圆的半径[radius],线宽[strokeWidth]
///小点的个数[dotCount] 样式[style] 完成后的显示文字[completeText]
class Progress {
  double value;
  Color color;
  Color backgroundColor;
  double radius;
  double strokeWidth;
  int dotCount;
  TextStyle style;
  String completeText;

  Progress(
      {this.value,
      this.color,
      this.backgroundColor,
      this.radius,
      this.strokeWidth,
      this.completeText = "OK",
      this.style,
      this.dotCount = 40});
}

class _CircleProgressState extends State<CircleProgress> {
  @override
  Widget build(BuildContext context) {
    var progress = Container(
      width: widget.progress.radius * 2,
      height: widget.progress.radius * 2,
      child: CustomPaint(
        painter: ProgressPainter(widget.progress),
      ),
    );
    String txt = "${(100 * widget.progress.value).toStringAsFixed(1)} %";
    var text = Text(
      widget.progress.value == 1.0 ? widget.progress.completeText : txt,
      style: widget.progress.style ?? TextStyle(fontSize: widget.progress.radius / 6),
    );
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[progress, text],
    );
  }
}

class ProgressPainter extends CustomPainter {
  Progress _progress;
  Paint _paint;
  Paint _arrowPaint;
  Path _arrowPath;
  double _radius;

  ProgressPainter(
    this._progress,
  ) {
    _arrowPath = Path();
    _arrowPaint = Paint();
    _paint = Paint();
    _radius = _progress.radius - _progress.strokeWidth / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;
    canvas.clipRect(rect); //裁剪区域
    canvas.translate(_progress.strokeWidth / 2, _progress.strokeWidth / 2);

    drawProgress(canvas);
    drawArrow(canvas);
    drawDot(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  drawProgress(Canvas canvas) {
    canvas.save();
    _paint //背景
      ..style = PaintingStyle.stroke
      ..color = _progress.backgroundColor
      ..strokeWidth = _progress.strokeWidth;
    canvas.drawCircle(Offset(_radius, _radius), _radius, _paint);

    _paint //进度
      ..color = _progress.color
      ..strokeWidth = _progress.strokeWidth * 1.2
      ..strokeCap = StrokeCap.round;
    double sweepAngle = _progress.value * 360; //完成角度
    print(sweepAngle);
    canvas.drawArc(Rect.fromLTRB(0, 0, _radius * 2, _radius * 2), -90 / 180 * pi, sweepAngle / 180 * pi, false, _paint);
    canvas.restore();
  }

  drawArrow(Canvas canvas) {
    canvas.save();
    canvas.translate(_radius, _radius); // 将画板移到中心
    canvas.rotate((180 + _progress.value * 360) / 180 * pi); //旋转相应角度
    var half = _radius / 2; //基点
    var eg = _radius / 50; //单位长
    _arrowPath.moveTo(0, -half - eg * 2);
    _arrowPath.relativeLineTo(eg * 2, eg * 6);
    _arrowPath.lineTo(0, -half + eg * 2);
    _arrowPath.lineTo(0, -half - eg * 2);
    _arrowPath.relativeLineTo(-eg * 2, eg * 6);
    _arrowPath.lineTo(0, -half + eg * 2);
    _arrowPath.lineTo(0, -half - eg * 2);
    canvas.drawPath(_arrowPath, _arrowPaint);
    canvas.restore();
  }

  void drawDot(Canvas canvas) {
    canvas.save();
    int num = _progress.dotCount;
    canvas.translate(_radius, _radius);
    for (double i = 0; i < num; i++) {
      canvas.save();
      double deg = 360 / num * i;
      canvas.rotate(deg / 180 * pi);
      _paint
        ..strokeWidth = _progress.strokeWidth / 2
        ..color = _progress.backgroundColor
        ..strokeCap = StrokeCap.round;
      if (i * (360 / num) <= _progress.value * 360) {
        _paint..color = _progress.color;
      }
      canvas.drawLine(Offset(0, _radius * 3 / 4), Offset(0, _radius * 4 / 5), _paint);
      canvas.restore();
    }
    canvas.restore();
  }
}
