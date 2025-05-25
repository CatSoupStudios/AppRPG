import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PalomitaCheck extends StatefulWidget {
  final VoidCallback? onComplete;
  final bool show;

  const PalomitaCheck({
    Key? key,
    this.onComplete,
    this.show = false,
  }) : super(key: key);

  @override
  State<PalomitaCheck> createState() => _PalomitaCheckState();
}

class _PalomitaCheckState extends State<PalomitaCheck> {
  bool _visible = false;

  @override
  void didUpdateWidget(PalomitaCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !_visible) {
      setState(() {
        _visible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show && !_visible) return const SizedBox.shrink();

    return Center(
      child: Lottie.asset(
        'assets/animations/palimita.json',
        width: 200,
        height: 200,
        repeat: false,
        onLoaded: (composition) {
          Future.delayed(composition.duration, () {
            if (widget.onComplete != null) widget.onComplete!();
            if (mounted) {
              setState(() {
                _visible = false;
              });
            }
          });
        },
      ),
    );
  }
}
