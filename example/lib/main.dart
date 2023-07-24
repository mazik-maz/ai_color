import 'package:flutter/material.dart';
import 'package:ai_color/ai_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AI Color App'),
        ),
        body: const Center(
          child: ColorTextWidget(),
        ),
      ),
    );
  }
}

class ColorTextWidget extends StatefulWidget {
  const ColorTextWidget({super.key});

  @override
  _ColorTextWidgetState createState() => _ColorTextWidgetState();
}

class _ColorTextWidgetState extends State<ColorTextWidget> {
  String text = '';
  Color colorResult = Colors.white;
  bool colorDefined = false;
  AIColor aiColor = AIColor("apiKey"); //put here your API key

  void determineColor() async {
    Color? result = await aiColor.getColor(text);
    setState(() {
      colorDefined = true;
      colorResult = result!;
    });
  }

  void updateColor() async {
    Color? result = await aiColor.updateColor(text);
    setState(() {
      colorDefined = true;
      colorResult = result!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter a word:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                setState(() {
                  colorDefined = false;
                  text = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter a word...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    determineColor();
                  },
                  child: const Text('Determine Color'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(onPressed: () {
                  updateColor();
                }, child: const Text('Update color'))
              ],
            ),
            const SizedBox(height: 20),
            colorDefined ? newWidget(text) : Container(),
          ],
        ));
  }

  Widget newWidget(String text){
    return FutureBuilder(
      future: aiColor.getColor(text),
      builder: (BuildContext context, AsyncSnapshot<Color?> snapshot) {
        if(snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator(),);
        }
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasError){
            return const Center(child: Text("ERROR"));
          }
          else {
            return Center(
              child: Container(
                width: 100,
                height: 100,
                color: snapshot.data,
              ),
            );
          }
        }
        return const Center(child: Text("wait"),);
      },

    );
  }
}
