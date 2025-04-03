import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterItemWidget extends StatefulWidget {
  final String title1;
  final bool? isTitle1;
  final String? title2;
  final ValueChanged<String> onSelected;
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
  late bool? isComplete;
  @override
  void initState() {
    super.initState();
    isComplete = widget.isTitle1;
  }

  void _onSelected(String value) {
    setState(() {
      isComplete = value == widget.title1;
    });
    widget.onSelected(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: Text(
              widget.title1,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    isComplete == true ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            leading: Radio<String>(
              value: widget.title1,
              groupValue: isComplete == null
                  ? null
                  : (isComplete == true ? widget.title1 : widget.title2),
              activeColor: Colors.blue,
              onChanged: (String? value) {
                if (value != null) _onSelected(value);
              },
            ),
            onTap: () => _onSelected(widget.title1),
          ),
        ),
        if (widget.title2 != null)
          Expanded(
            child: ListTile(
              title: Text(
                widget.title2!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isComplete == false ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              leading: Radio<String>(
                value: widget.title2!,
                activeColor: Colors.blue,
                groupValue: isComplete == null
                    ? null
                    : (isComplete == true ? widget.title1 : widget.title2),
                onChanged: (String? value) {
                  if (value != null) _onSelected(value);
                },
              ),
              onTap: () => _onSelected(widget.title2!),
            ),
          ),
      ],
    );
  }
}
