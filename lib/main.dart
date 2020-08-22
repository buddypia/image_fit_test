import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Img;
import 'package:image_fit_test/adjustable_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String rootImagePath = 'assets/images/';
  List<String> _imagePaths;
  List<AdjustableImage> _imageList;
  double _bodyHeight = 1.0;

  @override
  void initState() {
    super.initState();

    _imagePaths = List<String>();
    _imagePaths.add("${rootImagePath}687px-Fire.jpeg");
    _imagePaths.add("${rootImagePath}lena.jpg");
    _imagePaths.add("${rootImagePath}Cat03.jpg");
    _imagePaths.add("${rootImagePath}cnbc-small.jpg");
    _imagePaths.add("${rootImagePath}jpg-to-pdf.png");
    _imagePaths.add("${rootImagePath}logo2.png");
    _imagePaths.add("${rootImagePath}top-main-200801-sp.jpg");
    _imagePaths.add("${rootImagePath}tux-7.jpg");
    _imagePaths.add("${rootImagePath}Twitter_logo.jpg");
    _imagePaths.add("${rootImagePath}unnamed.png");
    _imagePaths.add("${rootImagePath}kadomatsu_frame_2482.png");

    _imageList = List<AdjustableImage>();
//    changeRandomImages();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
          color: Colors.green,
          height: _bodyHeight,
//          height: 60.0,
//          child: Row(children: [
//            Expanded(
//                child: Container(
//              width: 30.0,
//              height: 30.0,
//              color: Colors.red,
//            )),
//            Expanded(
//                child: Container(
//              width: 20.0,
//              height: 30.0,
//              color: Colors.blue,
//            )),
//          ])

          child: Row(
            children: _imageList,
          )

//          child: LayoutBuilder(
//              builder: (BuildContext context, BoxConstraints constraints) {
//            debugPrint('Root constraints: $constraints');
//            return Row(children: [
//              Image.asset(
//                "${rootImagePath}687px-Fire.jpeg",
//                fit: BoxFit.cover,
//              ),
//              Image.asset(
//                "${rootImagePath}lena.jpg",
//                fit: BoxFit.cover,
//              ),
//            ]);
//          })
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: changeRandomImages,
        child: Icon(Icons.image),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  int randomIndex(int maxCount) {
    Random random = new Random();
    return random.nextInt(maxCount);
  }

  int changeRandomImages() {
    int maxCount = 2;
    List<int> usedIndex = List<int>();
    _imageList.clear();
    _bodyHeight = 1.0;

    for (int i = 0; i < maxCount; i++) {
      int useIndex = randomIndex(_imagePaths.length);
      if (usedIndex.contains(useIndex)) {
        i--;
        continue;
      }

      _imageList.add(createImage(_imagePaths[useIndex]));
      usedIndex.add(useIndex);
    }

    setState(() {
//      _imageList = _tmpImageList;
    });
  }

  void rebuild() {
    for (int i = 0; i < _imageList.length; i++) {
      final allImageLoaded = _imageList[i].imageLoadComplete;

      if (allImageLoaded == false) {
        return;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      adjustImages();
    });
  }

  Future adjustImages() async {
    double sumWidth = 0;
    _imageList.forEach((value) {
      sumWidth += value.adjustSize.width;
    });
    final deviceWidth = MediaQuery.of(context).size.width;
    _bodyHeight = deviceWidth / sumWidth;

    for (int i = 0; i < _imageList.length; i++) {
      if (_imageList[i].rawImageSize.width < _bodyHeight) {
        final adjustImageWidget = _imageList[i];
        ByteData byteData = await rootBundle.load(adjustImageWidget.imagePath);

        final adjustImage = Img.decodeImage(byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

        final adjustWidth = _bodyHeight * adjustImageWidget.aspectRatio;
        final forceSize = Size(adjustWidth, _bodyHeight);

        adjustImageWidget.forceSize = forceSize;

        final resizeImage = Img.copyResize(adjustImage,
            width: forceSize.width.toInt(), height: forceSize.height.toInt());

        adjustImageWidget.resizeImage = Image.memory(
            Img.encodeNamedImage(resizeImage, adjustImageWidget.imagePath));
      }
    }

    setState(() {
      final _tmpImageList = [..._imageList];
      _imageList.clear();

      for (int i = 0; i < _tmpImageList.length; i++) {
        final image = _tmpImageList[i];
        _imageList.add(createImage(image.imagePath,
            imageLoadComplete: true,
            resizeWidget: image.resizeImage,
            adjustSize: image.adjustSize,
            rawImageSize: image.rawImageSize,
            aspectRatio: image.aspectRatio));
      }
    });
  }

  Widget createImage(String imagePath,
      {bool imageLoadComplete = false,
      Widget resizeWidget,
      Size adjustSize,
      Size rawImageSize,
      double aspectRatio}) {
    return AdjustableImage(
      imagePath: imagePath,
      parentHeight: _bodyHeight,
      tryRebuildCallback: rebuild,
      resizeImage: resizeWidget,
      imageLoadComplete: imageLoadComplete,
      adjustSize: adjustSize,
      rawImageSize: rawImageSize,
      aspectRatio: aspectRatio,
    );
  }
}
