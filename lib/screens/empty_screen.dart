import 'package:flutter/material.dart';

class EmptyScreen extends StatefulWidget {
  const EmptyScreen({
    required this.text,
    required this.icon,
    required this.subTitle,
    required this.navigatorFunc,
  });
  final String text;
  final Icon icon;
  final String subTitle;
  final VoidCallback navigatorFunc;
  @override
  _EmptyScreenState createState() => _EmptyScreenState();
}

class _EmptyScreenState extends State<EmptyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(scale: _animation, child: widget.icon),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.text,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: widget.navigatorFunc,
              label: Text(
                widget.subTitle,
                style: const TextStyle(color: Colors.grey),
              ),
              icon: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 75, 136, 77),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
