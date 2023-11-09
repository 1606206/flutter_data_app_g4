import 'package:audioplayers/audioplayers.dart';
import 'load_audio_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'LAB Group 4 Project',
      home: WaveformsDashboard(),
    );
  }
}

class WaveformsDashboard extends StatefulWidget {
  const WaveformsDashboard({Key? key}) : super(key: key);

  @override
  State<WaveformsDashboard> createState() => _WaveformsDashboardState();
}

class _WaveformsDashboardState extends State<WaveformsDashboard> {
  late Duration maxDuration;
  late Duration elapsedDuration;
  late AudioCache audioPlayer;
  late List<double> samples;
  double sliderValue = 0;
  // Change this value to number of audio samples you want.
  // Values between 256 and 1024 are good for showing [RectangleWaveform] and [SquigglyWaveform]
  // While the values above them are good for showing [PolygonWaveform]
  int totalSamples = 8900;
  WaveformType waveformType = WaveformType.polygon;
  late WaveformCustomizations waveformCustomizations;

  late List<String> audioData;

  List<List<String>> audioDataList = [
    [
      'assets/soy.json',
      'shape_of_you.mp3',
    ],
  ];

  Future<void> parseData() async {
    final json = await rootBundle.loadString(audioData[0]);
    Map<String, dynamic> audioDataMap = {
      "json": json,
      "totalSamples": totalSamples,
    };
    final samplesData = await compute(loadparseJson, audioDataMap);

    setState(() {
      samples = samplesData["samples"];
    });
  }

  Future<void> playAudio() async {
    await audioPlayer.load(audioData[1]);
    await audioPlayer.play(audioData[1]);
    // maxDuration in milliseconds
    await Future.delayed(const Duration(milliseconds: 200));

    int maxDurationInmilliseconds =
        await audioPlayer.fixedPlayer!.getDuration();

    maxDuration = Duration(milliseconds: maxDurationInmilliseconds);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    audioData = audioDataList[0];
    audioPlayer = AudioCache(
      fixedPlayer: AudioPlayer(),
    );

    parseData();

    samples = [];
    maxDuration = const Duration(milliseconds: 1000);
    elapsedDuration = const Duration();

    audioPlayer.fixedPlayer!.onPlayerCompletion.listen((_) {
      setState(() {
        elapsedDuration = maxDuration;
        sliderValue = 1;
      });
    });
    audioPlayer.fixedPlayer!.onAudioPositionChanged.listen((Duration p) {
      setState(() {
        elapsedDuration = p;
        sliderValue = p.inMilliseconds / maxDuration.inMilliseconds;
      });
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    waveformCustomizations = WaveformCustomizations(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width - 200,
    );
  }

  @override
  Widget build(BuildContext context) {
    var sizedBox = const SizedBox(
      height: 10,
      width: 10,
    );
    return Scaffold(
        backgroundColor: const Color(0xFF141414),
        appBar: AppBar(
          title: const Text('Group 4'),
        ),
        body: ListView(
          //    mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
              width: 740,
            ),
            Row(
              children: [
                const SizedBox(
                  height: 100,
                  width: 740,
                ),
                ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: waveformType != WaveformType.polygon
                        ? Colors.blue
                        : Color.fromARGB(255, 126, 33, 226),
                  ),
                  onPressed: () {
                    setState(() {
                      // totalSamples = 256;
                      waveformType = WaveformType.polygon;
                      parseData();
                    });
                  },
                  child: const Text("Polygon"),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: waveformType != WaveformType.rectangle
                        ? Colors.blue
                        : Color.fromARGB(255, 126, 33, 226),
                  ),
                  onPressed: () {
                    setState(() {
                      totalSamples = 256;
                      waveformCustomizations.borderWidth = 1;
                      waveformType = WaveformType.rectangle;
                      parseData();
                    });
                  },
                  child: const Text("Rectangle"),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: waveformType != WaveformType.squiggly
                        ? Colors.blue
                        : Color.fromARGB(255, 126, 33, 226),
                  ),
                  onPressed: () {
                    setState(() {
                      totalSamples = 256;
                      waveformType = WaveformType.squiggly;
                      parseData();
                    });
                  },
                  child: const Text("Squiggly"),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: waveformType != WaveformType.curvedPolygon
                        ? Colors.blue
                        : Color.fromARGB(255, 126, 33, 226),
                  ),
                  onPressed: () {
                    setState(() {
                      totalSamples = 256;
                      waveformType = WaveformType.curvedPolygon;
                      parseData();
                    });
                  },
                  child: const Text("Curved Polygon"),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            if (waveformType == WaveformType.polygon)
              Align(
                alignment: Alignment.center,
                child: PolygonWaveformExample(
                  maxDuration: maxDuration,
                  elapsedDuration: elapsedDuration,
                  samples: samples,
                  waveformCustomizations: waveformCustomizations,
                ),
              )
            else if (waveformType == WaveformType.rectangle)
              Align(
                alignment: Alignment.center,
                child: RectangleWaveformExample(
                  maxDuration: maxDuration,
                  elapsedDuration: elapsedDuration,
                  samples: samples,
                  waveformCustomizations: waveformCustomizations,
                ),
              )
            else if (waveformType == WaveformType.curvedPolygon)
              Align(
                alignment: Alignment.center,
                child: CurvedPolgonWaveformExample(
                  maxDuration: maxDuration,
                  elapsedDuration: elapsedDuration,
                  samples: samples,
                  waveformCustomizations: waveformCustomizations,
                ),
              )
            else
              Align(
                alignment: Alignment.center,
                child: SquigglyWaveformExample(
                  maxDuration: maxDuration,
                  elapsedDuration: elapsedDuration,
                  samples: samples,
                  waveformCustomizations: waveformCustomizations,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 180,
                ),
                ElevatedButton(
                  onPressed: () {
                    audioPlayer.fixedPlayer!.pause();
                  },
                  child: const Icon(
                    Icons.pause,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (audioPlayer.fixedPlayer!.state == PlayerState.PAUSED) {
                      audioPlayer.fixedPlayer!.resume();
                    } else {
                      await playAudio();
                    }
                  },
                  child: const Icon(Icons.play_arrow),
                ),
                const SizedBox(
                  width: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      sliderValue = 0;
                      audioPlayer.fixedPlayer!
                          .seek(const Duration(milliseconds: 0));
                    });
                  },
                  child: const Icon(Icons.replay_outlined),
                ),
              ],
            ),
          ],
        ));
  }
}

class SquigglyWaveformExample extends StatelessWidget {
  const SquigglyWaveformExample({
    Key? key,
    required this.maxDuration,
    required this.elapsedDuration,
    required this.samples,
    required this.waveformCustomizations,
  }) : super(key: key);

  final Duration maxDuration;
  final Duration elapsedDuration;
  final List<double> samples;
  final WaveformCustomizations waveformCustomizations;

  @override
  Widget build(BuildContext context) {
    return SquigglyWaveform(
      maxDuration: maxDuration,
      elapsedDuration: elapsedDuration,
      samples: samples,
      height: waveformCustomizations.height,
      width: waveformCustomizations.width,
      inactiveColor: waveformCustomizations.inactiveColor,
      invert: waveformCustomizations.invert,
      absolute: waveformCustomizations.absolute,
      activeColor: waveformCustomizations.activeColor,
      showActiveWaveform: waveformCustomizations.showActiveWaveform,
      strokeWidth: waveformCustomizations.borderWidth,
    );
  }
}

class CurvedPolgonWaveformExample extends StatelessWidget {
  const CurvedPolgonWaveformExample({
    Key? key,
    required this.maxDuration,
    required this.elapsedDuration,
    required this.samples,
    required this.waveformCustomizations,
  }) : super(key: key);

  final Duration maxDuration;
  final Duration elapsedDuration;
  final List<double> samples;
  final WaveformCustomizations waveformCustomizations;

  @override
  Widget build(BuildContext context) {
    return CurvedPolygonWaveform(
      maxDuration: maxDuration,
      elapsedDuration: elapsedDuration,
      samples: samples,
      height: waveformCustomizations.height,
      width: waveformCustomizations.width,
      inactiveColor: waveformCustomizations.inactiveColor,
      invert: waveformCustomizations.invert,
      absolute: waveformCustomizations.absolute,
      activeColor: waveformCustomizations.activeColor,
      showActiveWaveform: waveformCustomizations.showActiveWaveform,
      strokeWidth: waveformCustomizations.borderWidth,
      style: waveformCustomizations.style,
    );
  }
}

class RectangleWaveformExample extends StatelessWidget {
  const RectangleWaveformExample({
    Key? key,
    required this.maxDuration,
    required this.elapsedDuration,
    required this.samples,
    required this.waveformCustomizations,
  }) : super(key: key);

  final Duration maxDuration;
  final Duration elapsedDuration;
  final List<double> samples;
  final WaveformCustomizations waveformCustomizations;

  @override
  Widget build(BuildContext context) {
    return RectangleWaveform(
      maxDuration: maxDuration,
      elapsedDuration: elapsedDuration,
      samples: samples,
      height: waveformCustomizations.height,
      width: waveformCustomizations.width,
      inactiveColor: waveformCustomizations.inactiveColor,
      inactiveGradient: waveformCustomizations.inactiveGradient,
      invert: waveformCustomizations.invert,
      absolute: waveformCustomizations.absolute,
      activeColor: waveformCustomizations.activeColor,
      activeGradient: waveformCustomizations.activeGradient,
      showActiveWaveform: waveformCustomizations.showActiveWaveform,
      borderWidth: waveformCustomizations.borderWidth,
      activeBorderColor: waveformCustomizations.activeBorderColor,
      inactiveBorderColor: waveformCustomizations.inactiveBorderColor,
      isRoundedRectangle: waveformCustomizations.isRoundedRectangle,
      isCentered: waveformCustomizations.isCentered,
    );
  }
}

class PolygonWaveformExample extends StatelessWidget {
  const PolygonWaveformExample({
    Key? key,
    required this.maxDuration,
    required this.elapsedDuration,
    required this.samples,
    required this.waveformCustomizations,
  }) : super(key: key);

  final Duration maxDuration;
  final Duration elapsedDuration;
  final List<double> samples;
  final WaveformCustomizations waveformCustomizations;

  @override
  Widget build(BuildContext context) {
    return PolygonWaveform(
      maxDuration: maxDuration,
      elapsedDuration: elapsedDuration,
      samples: samples,
      height: waveformCustomizations.height,
      width: waveformCustomizations.width,
      inactiveColor: waveformCustomizations.inactiveColor,
      inactiveGradient: waveformCustomizations.inactiveGradient,
      invert: waveformCustomizations.invert,
      absolute: waveformCustomizations.absolute,
      activeColor: waveformCustomizations.activeColor,
      activeGradient: waveformCustomizations.activeGradient,
      showActiveWaveform: waveformCustomizations.showActiveWaveform,
      style: waveformCustomizations.style,
    );
  }
}

enum WaveformType {
  polygon,
  rectangle,
  squiggly,
  curvedPolygon,
}

class WaveformCustomizations {
  WaveformCustomizations({
    required this.height,
    required this.width,
    this.activeColor = Colors.purple,
    this.inactiveColor = Colors.blue,
    this.activeGradient,
    this.inactiveGradient,
    this.style = PaintingStyle.stroke,
    this.showActiveWaveform = true,
    this.absolute = false,
    this.invert = false,
    this.borderWidth = 1.0,
    this.activeBorderColor = Colors.white,
    this.inactiveBorderColor = Colors.white,
    this.isRoundedRectangle = false,
    this.isCentered = false,
  });

  double height;
  double width;
  Color inactiveColor;
  Gradient? inactiveGradient;
  bool invert;
  bool absolute;
  Color activeColor;
  Gradient? activeGradient;
  bool showActiveWaveform;
  PaintingStyle style;
  double borderWidth;
  Color activeBorderColor;
  Color inactiveBorderColor;
  bool isRoundedRectangle;
  bool isCentered;
}
