import 'package:flutter/material.dart';

class AfzSearchBar extends TextField {
  AfzSearchBar(String text, void Function(String) refreshTable)
      : super(
          onChanged: refreshTable,
          style: TextStyle(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
            hintText: text,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
        );
}
