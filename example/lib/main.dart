import 'dart:math';

import 'package:measure_size/measure_size.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ExampleApp());
}

class MeasureSizePage extends StatefulWidget {
  final String title;

  MeasureSizePage({Key key, this.title}) : super(key: key);

  @override
  State createState() => _MeasureSizePageState();
}

class ExampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeasureSize Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MeasureSizePage(title: 'MeasureSize Demo Home Page'),
    );
  }
}

class _MeasureSizePageState extends State<MeasureSizePage> {
  Size _size;
  String _text = 'Tap button to add words';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            MeasureSize(
              onChange: (newSize) => setState(() => _size = newSize),
              child: Text(_text),
            ),
            Container(
              width: _size?.width ?? 0,
              height: _size?.height ?? 0,
              color: Colors.black.withOpacity(0.1),
            ),
            Container(
              height: _size?.height ?? 0,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '${_size?.width} x ${_size?.height}',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.text_snippet),
          onPressed: () => setState(() => _text = _text +
              ' ' +
              ['lorem', 'ipsum', 'dolor', 'sit', 'amet'][Random().nextInt(4)]),
        ),
      );
}
