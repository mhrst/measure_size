import 'dart:math';

import 'package:measure_size/measure_size.dart';
import 'package:flutter/material.dart';

enum WidgetId {
  lorem,
  fox,
}

void main() {
  runApp(ExampleApp());
}

class MeasureSizePage extends StatefulWidget {
  final String title;

  MeasureSizePage({super.key, required this.title});

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
  Size? _size;
  String _text = 'Tap button to add words';
  String _text2 = 'The quick brown fox';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Text('Post-frame callback'),
            Expanded(
              child: Stack(
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
            ),
            Text('Builder with prototypes'),
            Expanded(
              child: MeasureSizeBuilder<WidgetId>(
                prototypeConstraints: (constraints) => BoxConstraints(
                  minWidth: 0,
                  maxWidth: constraints.maxWidth,
                  minHeight: 0,
                  maxHeight: double.infinity,
                ),
                prototypes: [
                  PrototypeId(
                    id: WidgetId.lorem,
                    child: Text(_text),
                  ),
                  PrototypeId(
                    id: WidgetId.fox,
                    child: Text(_text2),
                  ),
                ],
                builder: (context, sizes) {
                  final double loremHeight =
                      sizes[WidgetId.lorem]?.height ?? 0.0;
                  final double loremWidth = sizes[WidgetId.lorem]?.width ?? 0.0;
                  final double foxHeight = sizes[WidgetId.fox]?.height ?? 0.0;
                  final double foxWidth = sizes[WidgetId.fox]?.width ?? 0.0;
                  return Column(
                    children: [
                      Expanded(
                        child: Stack(
                          // mainAxisSize: MainAxisSize.min,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_text),
                            Container(
                              width: loremWidth,
                              height: loremHeight,
                              color: Colors.black.withOpacity(0.1),
                            ),
                            Container(
                              height: _size?.height ?? 0,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  '$loremWidth x $loremHeight',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(height: 10),
                            // const Text(fox, textAlign: TextAlign.justify),
                            // const SizedBox(height: 20),
                            // Text(
                            //     "lorem: $loremHeight x $loremWidth\nfox: $foxHeight x $foxWidth"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          // mainAxisSize: MainAxisSize.min,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_text2),
                            Container(
                              width: foxWidth,
                              height: foxHeight,
                              color: Colors.black.withOpacity(0.1),
                            ),
                            Container(
                              height: _size?.height ?? 0,
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  '$foxWidth x $foxHeight',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(height: 10),
                            // const Text(fox, textAlign: TextAlign.justify),
                            // const SizedBox(height: 20),
                            // Text(
                            //     "lorem: $loremHeight x $loremWidth\nfox: $foxHeight x $foxWidth"),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.text_snippet),
          onPressed: () => setState(() {
            final newWord = [
              'lorem',
              'ipsum',
              'dolor',
              'sit',
              'amet',
            ][Random().nextInt(4)];
            _text = '$_text $newWord';
            _text2 = '$_text2 $newWord';
          }),
        ),
      );
}
