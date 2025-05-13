import '../../utils/manager/Import_Manager.dart';

class BasicTextField extends StatefulWidget {
  const BasicTextField({super.key, required this.label, this.isPassword = false, required this.onEnter, this.maxLength, this.initText = ''});
  final String label;
  final bool isPassword;
  final Function(String) onEnter;
  final int? maxLength;
  final String? initText;
  @override
  State<BasicTextField> createState() => _BasicTextFieldState();
}

class _BasicTextFieldState extends State<BasicTextField> {
  late TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController(text: widget.initText);
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: textEditingController,
        onChanged: widget.onEnter,
        obscureText: widget.isPassword,
        maxLength: widget.maxLength,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: Colors.cyanAccent.withValues(alpha: 0.7)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyanAccent),
          ),
        ),
      ),
    );
  }
}
