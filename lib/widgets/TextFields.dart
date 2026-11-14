import 'package:material_ui/material_ui.dart';

class AfzSearchBar extends TextField {
  AfzSearchBar(String text, void Function(String) refreshTable)
    : super(
        onChanged: refreshTable,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          hintText: text,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      );
}

class TourEditTitle extends StatefulWidget {
  final void Function(String)? onChanged;
  final String initialName;

  const TourEditTitle(this.onChanged, this.initialName, {super.key});

  @override
  State<TourEditTitle> createState() => _TourEditTitleState();
}

class _TourEditTitleState extends State<TourEditTitle> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text("Titel"),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 5),
              child: TextField(
                autocorrect: true,
                onChanged: widget.onChanged,
                controller: _controller,
                style: TextStyle(color: Colors.black),
                strutStyle: StrutStyle(fontSize: 20),
                decoration: InputDecoration(fillColor: Colors.grey[600]),
                maxLength: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
