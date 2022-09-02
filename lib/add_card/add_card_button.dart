import 'package:flutter/material.dart';

class AddCardButton extends StatelessWidget {
  final VoidCallback _onPressed;

  AddCardButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onPressed: _onPressed,
      child: Text('Add Card'),
    );
  }
}
