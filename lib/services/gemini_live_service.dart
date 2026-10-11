import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:record/record.dart';
// Note: In a production app, the API key must come securely from your backend (e.g., via an ephemeral token).
// For now, we stub this or expect the backend to provide it.

class GeminiLiveService extends GetxService {
  WebSocketChannel? _channel;
  StreamSubscription? _audioSubscription;
  final _audioRecorder = AudioRecorder();
  
  // Observables
  final RxBool isConnected = false.obs;
  final RxBool isRecording = false.obs;
  final RxString transcript = ''.obs;
  final RxString lastError = ''.obs;

  // We will need a way to pass the API key or Token here.
  // In the future, this comes from ApiClient.
  Future<void> connect(String urlOrToken, String systemInstruction) async {
    try {
      lastError.value = '';
      _channel = WebSocketChannel.connect(Uri.parse(urlOrToken));
      
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          isConnected.value = false;
          stopRecording();
          debugPrint('WebSocket disconnected');
        },
        onError: (error) {
          isConnected.value = false;
          lastError.value = 'Connection error: $error';
          stopRecording();
          debugPrint('WebSocket error: $error');
        },
      );
      
      // Wait for connection to establish
      await _channel!.ready;
      isConnected.value = true;
      debugPrint('WebSocket connected');
      
      // Send initial setup message
      _sendSetupMessage(systemInstruction);
      
    } catch (e) {
      isConnected.value = false;
      lastError.value = 'Failed to connect: $e';
      debugPrint(lastError.value);
    }
  }

  void _sendSetupMessage(String instruction) {
    if (_channel == null) return;
    
    final setupMsg = {
      "setup": {
        "model": "models/gemini-2.0-flash-exp",
        "systemInstruction": {
          "parts": [
            {"text": instruction}
          ]
        }
      }
    };
    
    _channel!.sink.add(jsonEncode(setupMsg));
  }

  Future<void> startRecording() async {
    if (!isConnected.value) return;
    
    if (await _audioRecorder.hasPermission()) {
      final stream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      
      isRecording.value = true;
      
      _audioSubscription = stream.listen((data) {
        _sendAudioChunk(data);
      });
    } else {
      lastError.value = 'Microphone permission denied';
    }
  }

  void _sendAudioChunk(Uint8List data) {
    if (_channel == null || !isConnected.value) return;
    
    final base64Audio = base64Encode(data);
    final msg = {
      "realtimeInput": {
        "mediaChunks": [
          {
            "mimeType": "audio/pcm;rate=16000",
            "data": base64Audio
          }
        ]
      }
    };
    
    _channel!.sink.add(jsonEncode(msg));
  }

  Future<void> stopRecording() async {
    await _audioSubscription?.cancel();
    await _audioRecorder.stop();
    isRecording.value = false;
  }

  void _handleMessage(dynamic message) {
    try {
      // In a real app, you would parse the JSON and handle 'serverContent'
      // which contains audio to play and transcript parts to show.
      if (message is String) {
        final data = jsonDecode(message);
        if (data['serverContent'] != null && data['serverContent']['modelTurn'] != null) {
          final parts = data['serverContent']['modelTurn']['parts'];
          for (var part in parts) {
            if (part['text'] != null) {
              transcript.value += part['text'];
            }
            if (part['inlineData'] != null) {
              // Handle incoming audio playback here (PCM data)
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error parsing message: $e');
    }
  }

  void disconnect() {
    stopRecording();
    _channel?.sink.close();
    _channel = null;
    isConnected.value = false;
  }
  
  @override
  void onClose() {
    disconnect();
    _audioRecorder.dispose();
    super.onClose();
  }
}
