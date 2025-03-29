import 'package:flutter/material.dart';

class TopSnackBar {
  static void show(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return TopSnackBarWidget(
          message: message,
          backgroundColor: backgroundColor,
          onDismissed: () {
            OverlayEntry.remove();
          },
        );
      },
    );
    Overlay.of(context).insert(overlayEntry);
  }
}

class TopSnackBarWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final VoidCallback onDismissed;

  const TopSnackBarWidget({
    Key? key,
    required this.message,
    required this.backgroundColor,
    required this.onDismissed,
  }) : super(key: key);

  @override
  _TopSnackBarWidgetState createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<TopSnackBarWidget> {
  double _topPosition = -100.0; // Bắt đầu ẩn trên top

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _topPosition = 50.0; // Hiển thị thông báo
      });
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _topPosition = -100.0; // Ẩn thông báo
        });
        Future.delayed(Duration(milliseconds: 300), () {
          widget.onDismissed();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _topPosition,
      left: 20.0,
      right: 20.0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            widget.message,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
