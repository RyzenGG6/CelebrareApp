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
  double positionX = 0.0;
  double positionY = 0.0;

  // Maintain a stack for undo and redo
  List<TextEditorModel> history = [];
  int historyIndex = -1;

  void changeText(String newText) {
    saveState();
    text = newText;
    notifyListeners();
  }

  void changeTextColor(Color newColor) {
    saveState();
    textColor = newColor;
    notifyListeners();
  }

  void changeFontSize(double newSize) {
    saveState();
    fontSize = newSize;
    notifyListeners();
  }

  void updatePosition(double x, double y) {
    saveState();
    positionX = x;
    positionY = y;
    notifyListeners();
  }

  void saveState() {
    // Save the current state for undo
    if (historyIndex < history.length - 1) {
      // Clear future history when new state is added after undo
      history.removeRange(historyIndex + 1, history.length);
    }
    history.add(TextEditorModel()
      ..text = text
      ..textColor = textColor
      ..fontSize = fontSize
      ..positionX = positionX
      ..positionY = positionY);
    historyIndex = history.length - 1;
  }

  bool canUndo() {
    return historyIndex > 0;
  }

  bool canRedo() {
    return historyIndex < history.length - 1;
  }

  void undo() {
    if (canUndo()) {
      historyIndex--;
      restoreState();
    }
  }

  void redo() {
    if (canRedo()) {
      historyIndex++;
      restoreState();
    }
  }

  void restoreState() {
    TextEditorModel prevState = history[historyIndex];
    text = prevState.text;
    textColor = prevState.textColor;
    fontSize = prevState.fontSize;
    positionX = prevState.positionX;
    positionY = prevState.positionY;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TextEditorModel(),
      child: MaterialApp(
        title: 'Celebrare App',
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
        title: Text('Celebrare '),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextEditorControls(),
            SizedBox(height: 20.0),
            Expanded(
              child: DraggableTextEditor(),
            ),
          ],
        ),
      ),
    );
  }
}

class DraggableTextEditor extends StatefulWidget {
  @override
  _DraggableTextEditorState createState() => _DraggableTextEditorState();
}

class _DraggableTextEditorState extends State<DraggableTextEditor> {


  @override
  Widget build(BuildContext context) {
    final model = Provider.of<TextEditorModel>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Offset position = Offset(model.positionX, model.positionY);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        feedback: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Add padding here
            child: Container(
              child: Text(
                model.text,
                style: TextStyle(
                  color: model.textColor,
                  fontSize: model.fontSize,
                ),
              ),
            ),
          ),
        ),
        child: Container(
          height: screenHeight - 220,
          width: screenWidth - 10,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Add padding here
            child: Container(
              child: Text(
                model.text,
                style: TextStyle(
                  color: model.textColor,
                  fontSize: model.fontSize,
                ),
              ),
            ),
          ),
        ),
        onDraggableCanceled: (velocity, offset) {
          // Update the position when dragged
          setState(() {
            position = Offset(
              position.dx + offset.dx,
              position.dy + offset.dy,
            );
          });
        },
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
        IconButton(
          icon: Icon(Icons.undo),
          onPressed: model.canUndo() ? () => model.undo() : null,
        ),
        IconButton(
          icon: Icon(Icons.redo),
          onPressed: model.canRedo() ? () => model.redo() : null,
        ),
      ],
    );
  }

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
              child: Text('Apply'),
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
          child: Text('Apply'),
        ),

      ],
    );
  }
}
