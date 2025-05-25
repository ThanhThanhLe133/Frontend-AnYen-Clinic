import 'package:flutter/material.dart';

class FilterItemList extends StatefulWidget {
  final String title1;
  final String chosenOption;
  final Function(String) onSelected;
  final List<Map<String, dynamic>> dropdownItems;

  const FilterItemList({
    required this.title1,
    required this.chosenOption,
    required this.onSelected,
    required this.dropdownItems,
    super.key,
  });

  @override
  State<FilterItemList> createState() => _FilterItemListState();
}

class _FilterItemListState extends State<FilterItemList> {
  late String selected;
  @override
  void initState() {
    super.initState();
    selected = widget.chosenOption;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            widget.title1,
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
          SizedBox(width: 40),
          DropdownButton<String>(
            dropdownColor: Colors.white,
            value: selected,
            underline: SizedBox(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selected = newValue;
                });
                widget.onSelected(newValue);
              }
            },
            items: widget.dropdownItems.map((item) {
              return DropdownMenuItem<String>(
                value: item['id'],
                child: Text(
                  item['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
