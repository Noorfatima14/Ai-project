import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this for date formatting
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:open_file/open_file.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';


void main()  {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Poker Emotion Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFFBCB8B1),  // Updated color
        hintColor: const Color(0xFFF4F3EE),    // Updated color
      ),
      home: const EmotionSelectionForm(),
    );
  }
}

class EmotionSelectionForm extends StatefulWidget {
  const EmotionSelectionForm({super.key});

  @override
  EmotionSelectionFormState createState() => EmotionSelectionFormState();
}

class EmotionSelectionFormState extends State<EmotionSelectionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _bankrollController = TextEditingController();
  String? _blindLevel;
  String? _selectedEmotion;
  final List<String> _emotions = [  'Happy', 'Sad', 'Angry', 'Excited', 'Frustrated', 'Calm', 'Nervous'
  ];

  @override
  void dispose() {
    _startDateController.dispose();
    _bankrollController.dispose();
    super.dispose();
  }

  void _validateForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SessionReminder()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Selection'),
        backgroundColor: const Color(0xFFBCB8B1),  // Updated color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _bankrollController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Starting Bankroll',
                  labelStyle: TextStyle(color: Color(0xFF8A817C)),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _startDateController,
                decoration: InputDecoration(
                  labelText: 'Date',
                  labelStyle: const TextStyle(color: Color(0xFF8A817C)),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, color: Color(0xFF8A817C)),
                    onPressed: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        _startDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _blindLevel,
                decoration: const InputDecoration(
                  labelText: 'Blind Level',
                  labelStyle: TextStyle(color: Color(0xFF8A817C)),
                  border: OutlineInputBorder(),
                ),
                items: ['NL2', 'NL5', 'NL10'].map((blind) {
                  return DropdownMenuItem(
                    value: blind,
                    child: Text(blind),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _blindLevel = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a blind level' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEmotion,
                decoration: const InputDecoration(
                  labelText: 'Emotion',
                  labelStyle: TextStyle(color: Color(0xFF8A817C)),
                  border: OutlineInputBorder(),
                ),
                items: _emotions.map((emotion) {
                  return DropdownMenuItem(
                    value: emotion,
                    child: Text(emotion),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEmotion = value;
                  });
                },
                validator: (value) => value == null ? 'Please select an emotion' : null,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validateForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4F3EE),  // Updated button color
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SessionReminder extends StatefulWidget {
  const SessionReminder({super.key});

  @override
  SessionReminderState createState() => SessionReminderState();
}

class SessionReminderState extends State<SessionReminder> {
  Timer? _timer;
  int _reminderInterval = 10; // default reminder interval in minutes
  bool _isSessionActive = false;

  void _startReminder() {
    if (_isSessionActive) return;
    setState(() {
      _isSessionActive = true;
    });
    _timer = Timer.periodic(Duration(minutes: _reminderInterval), (timer) {
      _showReminder();
    });
  }

  void _stopReminder() {
    _timer?.cancel();
    setState(() {
      _isSessionActive = false;
    });
  }

  void _showReminder() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reminder'),
          content: const Text('Please record your current emotion.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Reminder'),
        backgroundColor: const Color(0xFFBCB8B1),  // Updated color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<int>(
              value: _reminderInterval,
              items: [10, 20, 30,40,50].map((interval) {
                return DropdownMenuItem<int>(
                  value: interval,
                  child: Text('$interval Minutes'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _reminderInterval = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: _isSessionActive ? _stopReminder : _startReminder,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF4F3EE)),
              child: Text(_isSessionActive ? 'End Session' : 'Start Session'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SessionSummary()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF4F3EE)),
              child: const Text('End Session & View Summary'),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionSummary extends StatelessWidget {
   SessionSummary({super.key});
   final GlobalKey _chartKey = GlobalKey();

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      final RenderRepaintBoundary boundary =
      _chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Image(pw.MemoryImage(pngBytes)),
        ),
      );

      Directory directory = await getApplicationDocumentsDirectory();
      String path = directory.path;
      File file = File('$path/session_summary.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open the PDF file
      await OpenFile.open(file.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved at $path/session_summary.pdf')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Tracking Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: screenWidth * 0.87,
          height: screenHeight * 0.99, // 70% of the screen height

         child: Column(
            children: [
              const SizedBox(height: 140),
              Expanded(
                child: RepaintBoundary(
                  key: _chartKey,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1, // Y-axis step
                          reservedSize: 50,
                          getTitlesWidget: (value, _) {
                            return Text(value.toString());
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 10, // X-axis step for minutes/hands
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('0 min');
                              case 10:
                                return const Text('10 min');
                              case 20:
                                return const Text('20 min');
                              case 30:
                                return const Text('30 min');
                              case 40:
                                return const Text('40 min');
                              case 50:
                                return const Text('50 min');
                              default:
                                return const SizedBox(); // Return empty if not a defined point
                            }
                          },
                        ),
                      ),
                    ),
                    minX: 0, // Start from minute 0 or hand 0
                    maxX: 50, // Assume 60 minutes or hands
                    minY: -5, // Emotions scale minimum
                    maxY: 5, // Emotions scale maximum
                    lineBarsData: [
                      // Example line chart data for each emotion
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 3),
                          FlSpot(10, 4),
                          FlSpot(20, 5),
                          FlSpot(30, 4),
                          FlSpot(40, 3),
                          FlSpot(50, 4),
                        ],
                        isCurved: true,
                        color: Colors.yellow,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, -3),
                          FlSpot(10, -4),
                          FlSpot(20, -2),
                          FlSpot(30, -3),
                          FlSpot(40, -5),
                          FlSpot(50, -4),
                        ],
                        isCurved: true,
                        color: Colors.brown,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Line for Angry
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, -4), // Example data points for angry
                          const FlSpot(10, -3),
                          const FlSpot(20, -2),
                          const FlSpot(30, -1),
                          const FlSpot(40, -3),
                          const FlSpot(50, -2),

                        ],
                        isCurved: true,
                        color: Colors.red,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Line for Excited
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 4), // Example data points for excited
                          const FlSpot(10, 5),
                          const FlSpot(20, 3),
                          const FlSpot(30, 4),
                          const FlSpot(40, 5),
                          const FlSpot(50, 4),

                        ],
                        isCurved: true,
                        color: Colors.orange,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Line for Frustrated
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, -2), // Example data points for frustrated
                          const FlSpot(10, -3),
                          const FlSpot(20, -4),
                          const FlSpot(30, -3),
                          const FlSpot(40, -5),
                          const FlSpot(50, -4),

                        ],
                        isCurved: true,
                        color: Colors.purple,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Line for Calm
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 3), // Example data points for calm
                          const FlSpot(10, 4),
                          const FlSpot(20, 3),
                          const FlSpot(30, 5),
                          const FlSpot(40, 4),
                          const FlSpot(50, 3),

                        ],
                        isCurved: true,
                        color: Colors.blue,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      // Line for Nervous
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, -1), // Example data points for nervous
                          const FlSpot(10, -2),
                          const FlSpot(20, -3),
                          const FlSpot(30, -1),
                          const FlSpot(40, -4),
                          const FlSpot(50, -3),

                        ],
                        isCurved: true,
                        color: Colors.grey,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.black),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipMargin: 8,
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((LineBarSpot spot) {
                            String emotion;
                            switch (spot.barIndex) {
                              case 0:
                                emotion = 'Happy';
                                break;
                              case 1:
                                emotion = 'Sad';
                                break;
                              case 2:
                                emotion = 'Angry';
                                break;
                              case 3:
                                emotion = 'Excited';
                                break;
                              case 4:
                                emotion = 'Frustrated';
                                break;
                              case 5:
                                emotion = 'Calm';
                                break;
                              case 6:
                                emotion = 'Nervous';
                                break;
                              default:
                                return null;
                            }
                            return LineTooltipItem(
                              '$emotion: ${spot.y.toString()}',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                    ),
                    ),
                  ),
                ),
              ),
              ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF4F3EE)),
                  child: const Text('Go Back'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _exportToPDF(context),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF4F3EE)),
                  child: const Text('Export to PDF'),
                ),

                ],
              ),
        ),
      ),
    );
  }
}



