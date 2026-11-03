import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DLMSMatrixScreen(),
  ));
}

class DLMSMatrixScreen extends StatefulWidget {
  const DLMSMatrixScreen({super.key});

  @override
  State<DLMSMatrixScreen> createState() => _DLMSMatrixScreenState();
}

class _DLMSMatrixScreenState extends State<DLMSMatrixScreen> {
  WebSocketChannel? _channel;
  bool _isConnected = false;

  double _masterVolume = 0.0;
  bool _muteAll = false;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.4.1/ws'),
      );
      setState(() => _isConnected = true);

      _channel!.stream.listen(
        (data) {
          final json = jsonDecode(data);
          setState(() {
            if (json.containsKey('masterVol')) {
              _masterVolume = (json['masterVol'] as num).toDouble();
            }
            if (json.containsKey('muteAll')) {
              _muteAll = json['muteAll'] as bool;
            }
          });
        },
        onDone: () => setState(() => _isConnected = false),
        onError: (err) => setState(() => _isConnected = false),
      );
    } catch (e) {
      setState(() => _isConnected = false);
    }
  }

  void _sendCommand(Map<String, dynamic> data) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            const Text('DZAFA DLMS (2 IN / 4 OUT)', style: TextStyle(fontSize: 15, color: Colors.white)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _isConnected ? 'Connected' : 'Offline',
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _connectWebSocket,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // MATRIKS ROUTING (2 INPUT -> 4 OUTPUT)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                border: Border.all(color: Colors.grey.shade800),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  // Kolom Input A & B
                  Column(
                    children: List.generate(2, (i) {
                      String name = String.fromCharCode(65 + i);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 55,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.red.shade900,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text('Input $name', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 4),
                            _miniBtn('Gain'),
                            _miniBtn('PEQ'),
                            _miniBtn('Delay'),
                            _miniBtn('Comp'),
                          ],
                        ),
                      );
                    }),
                  ),

                  // Canvas Garis Matrix Routing
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: CustomPaint(
                        painter: Matrix2x4Painter(),
                      ),
                    ),
                  ),

                  // Kolom Output 1 - 4
                  Column(
                    children: List.generate(4, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          children: [
                            _miniBtn('Gain'),
                            const SizedBox(width: 3),
                            _miniBtn('PEQ'),
                            const SizedBox(width: 3),
                            _miniBtn('X-Over'),
                            const SizedBox(width: 3),
                            _miniBtn('Delay'),
                            const SizedBox(width: 3),
                            Container(
                              width: 45,
                              height: 24,
                              alignment: Alignment.center,
                              color: Colors.cyan.shade900,
                              child: Text('Out ${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // PANEL FADER LEVEL & METERING
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.grey.shade800),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...List.generate(2, (i) {
                    String name = String.fromCharCode(65 + i);
                    return _buildFaderChannel('IN $name', Colors.redAccent);
                  }),
                  Container(width: 2, height: 160, color: Colors.grey.shade800),
                  ...List.generate(4, (i) {
                    return _buildFaderChannel('OUT ${i + 1}', Colors.cyanAccent);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniBtn(String label) {
    return Container(
      width: 38,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        border: Border.all(color: Colors.grey.shade600),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9)),
    );
  }

  Widget _buildFaderChannel(String label, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          width: 16,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 35,
                color: Colors.green,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          color: Colors.grey.shade800,
          child: const Text('0.0 dB', style: TextStyle(color: Colors.white, fontSize: 8)),
        ),
      ],
    );
  }
}

class Matrix2x4Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [Colors.redAccent, Colors.yellowAccent];

    for (int i = 0; i < 2; i++) {
      double startY = 22.0 + (i * 50.0);
      final paint = Paint()
        ..color = colors[i]
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      for (int j = 0; j < 4; j++) {
        double endY = 12.0 + (j * 25.0);
        canvas.drawLine(
          Offset(0, startY),
          Offset(size.width, endY),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}