import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdoptionFormField extends StatefulWidget {
  final FocusNode _focusNode;
  final TextEditingController _petNameTextEditingController;
  final TextInputType _keyboardType;
  final String _hintText;
  final Color _color;
  final int _maxLines;
  final bool _isSeparatorNeeded;
  final bool _isTextCentered;
  final bool _interactionEnabled;
  final int? _maxCharacters;

  const AdoptionFormField({
    Key? key,
    required FocusNode focusNode,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String hintText,
    required Color color,
    int maxLines = 1,
    bool isSeparatorNeeded = false,
    bool isTextCentered = false,
    bool interactionEnabled = true,
    int? maxCharacters,
  })  : _focusNode = focusNode,
        _petNameTextEditingController = controller,
        _keyboardType = keyboardType,
        _hintText = hintText,
        _color = color,
        _maxLines = maxLines,
        _isSeparatorNeeded = isSeparatorNeeded,
        _isTextCentered = isTextCentered,
        _interactionEnabled = interactionEnabled,
        _maxCharacters = maxCharacters,
        super(key: key);

  @override
  State<AdoptionFormField> createState() => _AdoptionFormFieldState();
}

class _AdoptionFormFieldState extends State<AdoptionFormField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: widget._focusNode.hasFocus
              ? [
                  BoxShadow(
                    color: widget._color,
                    blurRadius: 4,
                    spreadRadius: 4,
                  )
                ]
              : null),
      child: TextFormField(
        textAlign: widget._isTextCentered ? TextAlign.center : TextAlign.start,
        enableInteractiveSelection: widget._interactionEnabled,
        inputFormatters: widget._isSeparatorNeeded
            ? [
                ThousandsSeparatorInputFormatter(),
                FilteringTextInputFormatter.deny(RegExp(r'^0+')),
                LengthLimitingTextInputFormatter(widget._maxCharacters)
                // FilteringTextInputFormatter.digitsOnly
              ]
            : null,
        keyboardType: widget._keyboardType,
        focusNode: widget._focusNode,
        controller: widget._petNameTextEditingController,
        // style: const TextStyle(letterSpacing: AppSize.s5),
        maxLines: widget._maxLines,
        decoration: InputDecoration(
          hintText: widget._hintText,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: widget._color,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: widget._color,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ','; // Change this to '.' for other locales

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Short-circuit if the new value is empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Handle "deletion" of separator character
    String oldValueText = oldValue.text.replaceAll(separator, '');
    String newValueText = newValue.text.replaceAll(separator, '');

    if (oldValue.text.endsWith(separator) &&
        oldValue.text.length == newValue.text.length + 1) {
      newValueText = newValueText.substring(0, newValueText.length - 1);
    }

    // Only process if the old value and new value are different
    if (oldValueText != newValueText) {
      int selectionIndex =
          newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.split('');

      String newString = '';
      for (int i = chars.length - 1; i >= 0; i--) {
        if ((chars.length - 1 - i) % 3 == 0 && i != chars.length - 1) {
          newString = separator + newString;
        }
        newString = chars[i] + newString;
      }

      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndex,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return newValue;
  }
}
