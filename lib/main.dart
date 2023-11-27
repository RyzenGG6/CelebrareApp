import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class TextEditorModel extends ChangeNotifier {
  String text = 'Hello, World!';
  Color textColor = Colors.black;
  double fontSize = 20.0;
  // Add more properties as needed

  void changeText(String newText) {
    text = newText;
    notifyListeners();
  }

  void changeTextColor(Color newColor) {
    textColor = newColor;
    notifyListeners();
  }

  void changeFontSize(double newSize) {
    fontSize = newSize;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TextEditorModel(),
      child: MaterialApp(
        title: 'Text Editor App',
        home: TextEditorScreen(),
      ),
    );
  }
}

class TextEditorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Editor'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextEditorControls(),
          SizedBox(height: 20.0),
        Expanded(
          child: Center(
            child: TextEditorCanvas(),
          ),
        ),
          ],
        ),
      ),
    );
  }
}


class TextEditorCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TextEditorModel>(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          model.text,
          style: TextStyle(
            color: model.textColor,
            fontSize: model.fontSize,
          ),
        ),
      ),
    );
  }
}

class TextEditorControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TextEditorModel>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(FontAwesomeIcons.textHeight),
          onPressed: () => _showFontSizeDialog(context, model),
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.palette),
          onPressed: () => _showColorPicker(context, model),
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.edit),
          onPressed: () => _showTextEditorDialog(context, model),
        ),
      ],
    );
  }

  // Add functions for handling actions (e.g., changing font size, color, etc.)
// Add functions for handling actions (e.g., changing font size, color, etc.)

  void _showFontSizeDialog(BuildContext context, TextEditorModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SliderDialog(
          initialValue: model.fontSize,
          onChanged: (value) {
            model.changeFontSize(value);
          },
        );
      },
    );
  }




  void _showColorPicker(BuildContext context, TextEditorModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: model.textColor,
              onColorChanged: (color) {
                model.changeTextColor(color);
              },
              enableAlpha: false,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showTextEditorDialog(BuildContext context, TextEditorModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController textEditingController =
        TextEditingController(text: model.text);

        return AlertDialog(
          title: Text('Edit Text'),
          content: TextField(
            controller: textEditingController,
            onChanged: (value) {
              // Update the text
              model.changeText(value);
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

}

class SliderDialog extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;

  SliderDialog({required this.initialValue, required this.onChanged});

  @override
  _SliderDialogState createState() => _SliderDialogState();
}

class _SliderDialogState extends State<SliderDialog> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Font Size'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _sliderValue,
            min: 10.0,
            max: 50.0,
            onChanged: (value) {
              setState(() {
                _sliderValue = value;
              });
            },
          ),
          Text('Font Size: ${_sliderValue.toStringAsFixed(1)}'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onChanged(_sliderValue);
            Navigator.of(context).pop();
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}
