import '../../utils/manager/Import_Manager.dart';

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({super.key, required this.label, required this.items});
  final String label;
  final List<String> items;
  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String selected = '';

  @override
  void initState() {
    // TODO: implement initState
    selected = widget.items.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selected,
        onChanged: (val) => setState(() => selected = val!),
        items: widget.items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
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
        dropdownColor: Colors.black87,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
