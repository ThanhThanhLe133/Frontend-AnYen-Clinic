import 'package:flutter/material.dart';

class FilterItemWidget extends StatefulWidget {
  final String title1;
  final bool? isTitle1;
  final String? title2;
  final ValueChanged<String?> onSelected;
  const FilterItemWidget({
    super.key,
    required this.title1,
    this.title2,
    required this.isTitle1,
    required this.onSelected,
  });

  @override
  _FilterItemWidgetState createState() => _FilterItemWidgetState();
}

class _FilterItemWidgetState extends State<FilterItemWidget> {
  bool? isComplete;

  @override
  void initState() {
    super.initState();
    isComplete = widget.isTitle1;
  }

  void _onSelected(String value) {
    setState(() {
      if (value == widget.title1) {
        if (isComplete == true) {
          isComplete = null;
          widget.onSelected(null);
        } else {
          isComplete = true;
          widget.onSelected(widget.title1);
        }
      } else if (value == widget.title2) {
        if (isComplete == false) {
          isComplete = null;
          widget.onSelected(null);
        } else {
          isComplete = false;
          widget.onSelected(widget.title2!);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _onSelected(widget.title1),
            child: Row(
              children: [
                Checkbox(
                  value: isComplete == true,
                  onChanged: (bool? checked) {
                    _onSelected(widget.title1);
                  },
                  activeColor: Colors.blue,
                ),
                Text(
                  widget.title1,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isComplete == true
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.title2 != null)
          Expanded(
            child: InkWell(
              onTap: () => _onSelected(widget.title2!),
              child: Row(
                children: [
                  Checkbox(
                    value: isComplete == false,
                    onChanged: (bool? checked) {
                      _onSelected(widget.title2!);
                    },
                    activeColor: Colors.blue,
                  ),
                  Text(
                    widget.title2!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isComplete == false
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
