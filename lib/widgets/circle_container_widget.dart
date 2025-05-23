import 'package:flutter/material.dart';
import '../utils/colors_util.dart';

/// 円形のコンテナを表示するウィジェット
/// ディーラーボタンやブラインドの表示などに使用
class CircleContainer extends StatelessWidget {
  final Color color;
  final Widget child;
  final double size;

  const CircleContainer({
    required this.color,
    required this.child,
    this.size = 24.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 1.0),
      ),
      child: Center(child: child),
    );
  }
}

class CircleContainerWidget extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow>? boxShadow;

  const CircleContainerWidget({
    required this.child,
    this.maxWidth = 200.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(20.0)),
    this.boxShadow,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: 35.0, // 高さを35pxに設定
      ),
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? ColorsUtil.backgroundPurple,
        borderRadius: borderRadius,
        boxShadow: boxShadow ??
            [
              // デフォルトのシャドウを設定
              BoxShadow(
                color: ColorsUtil.shadowBlue, // カラーコードと透明度を指定
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
      ),
      child: Center(child: child),
    );
  }
}
