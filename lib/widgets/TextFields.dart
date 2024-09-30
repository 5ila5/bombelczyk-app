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

class TourEditTitle extends Container {
  TourEditTitle(void Function(String)? onChanged, String initialName)
      : super(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text("Titel"),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.only(left: 20, right: 5),
                      child: TextField(
                        autocorrect: true,
                        onChanged: onChanged,
                        controller: TextEditingController(text: initialName),
                        style: TextStyle(
                          color: Colors.black,
                          //backgroundColor: ,
                        ),
                        strutStyle: StrutStyle(
                          fontSize: 20,
                        ),
                        decoration: InputDecoration(
                          fillColor: Colors.grey[600],
                        ),
                        maxLength: 100,
                      )))
            ],
          ),
        );
}
