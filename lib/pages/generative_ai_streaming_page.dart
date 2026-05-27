import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class GenerativeAiStreamingPage extends StatefulWidget {
  const GenerativeAiStreamingPage({super.key});

  @override
  State<GenerativeAiStreamingPage> createState() =>
      _GenerativeAiStreamingPageState();
}

class _GenerativeAiStreamingPageState extends State<GenerativeAiStreamingPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;

  String? _currentQuestion;
  String _streamingAnswer = "";
  bool _isStreaming = false;
  StreamSubscription<StreamResponse>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _startStreaming() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    // Cancel any active stream before starting a new one
    await _streamSubscription?.cancel();

    setState(() {
      _currentQuestion = question;
      _streamingAnswer = "";
      _isStreaming = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'answerQuestionWithSystem',
      );
      final stream = callable.stream(<String, dynamic>{
        'question': question,
        'system':
            // 'Make sure you return the answer in Markdown format. Also include references to your answer.',
            'You are a helpful assistant. Give the answer to the question in a narration format.',
      });

      _streamSubscription = stream.listen(
        (event) {
          if (event is Chunk) {
            final data = event.partialData;
            setState(() {
              if (data is String) {
                _streamingAnswer += data;
              } else if (data is Map) {
                _streamingAnswer += data['message'] ?? data.toString();
              } else {
                _streamingAnswer += data.toString();
              }
            });
            _scrollToBottom();
          }
        },
        onError: (error) {
          setState(() {
            _streamingAnswer +=
                "\n\n⚠️ Error during stream: ${error.toString()}";
            _isStreaming = false;
          });
          _scrollToBottom();
        },
        onDone: () {
          setState(() {
            _isStreaming = false;
          });
          _scrollToBottom();
        },
      );
    } catch (e) {
      setState(() {
        _streamingAnswer = "Failed to initiate connection: $e";
        _isStreaming = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sleek dark palette design system tokens
    const Color darkBg = Color(0xFF0F0F1A);
    const Color cardColor = Color(0xFF1E1E2F);
    const Color accentColor = Color(0xFF6C63FF);
    const Color userBubbleBg = Color(0xFF2C2C4E);
    const Color telemetryGreen = Color(0xFF00FFB0);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBg,
        cardColor: cardColor,
        colorScheme: const ColorScheme.dark(
          primary: accentColor,
          secondary: telemetryGreen,
          surface: cardColor,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Gemini Streaming Flow",
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
          backgroundColor: cardColor,
          elevation: 0,
          actions: [
            // Telemetry Active Indicator
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: telemetryGreen.withOpacity(
                            0.3 + 0.7 * _pulseController.value,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: telemetryGreen,
                              blurRadius: 4 + 6 * _pulseController.value,
                              spreadRadius: 1 + 2 * _pulseController.value,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Telemetry Active",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [darkBg, Color(0xFF16162A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: _currentQuestion == null
                    ? _buildWelcomeScreen(accentColor, telemetryGreen)
                    : _buildConversationView(
                        userBubbleBg,
                        cardColor,
                        accentColor,
                      ),
              ),
              _buildInputSection(cardColor, accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(Color primary, Color telemetryGreen) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Genkit Live Stream",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Ask a question and receive real-time streamed responses directly from Gemini 3.5 Flash.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            _buildFeatureBadge(
              Icons.network_check_rounded,
              "Optimized Streaming Pipeline",
            ),
            const SizedBox(height: 12),
            _buildFeatureBadge(
              Icons.analytics_outlined,
              "Real-time Telemetry Instrumented",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2F).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildConversationView(
    Color userBubbleBg,
    Color cardColor,
    Color accentColor,
  ) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      children: [
        // User Question
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: userBubbleBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _currentQuestion ?? "",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Gemini Streaming Response
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Icon(Icons.psychology, color: accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gemini 3.5 Flash",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      border: Border.all(
                        color: _isStreaming
                            ? accentColor.withOpacity(0.3)
                            : Colors.white10,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _streamingAnswer.isEmpty
                              ? "Initializing connection..."
                              : _streamingAnswer,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing: 0.1,
                          ),
                        ),
                        if (_isStreaming) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    accentColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Streaming chunks in real-time...",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputSection(Color cardColor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: cardColor,
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F1A),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _isStreaming ? Colors.transparent : Colors.white10,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !_isStreaming,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _startStreaming(),
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: "Ask anything...",
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isStreaming
                      ? [Colors.grey[700]!, Colors.grey[800]!]
                      : [accentColor, const Color(0xFF8E87FF)],
                ),
                boxShadow: [
                  if (!_isStreaming)
                    BoxShadow(
                      color: accentColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  _isStreaming
                      ? Icons.hourglass_empty_rounded
                      : Icons.send_rounded,
                  color: Colors.white,
                ),
                onPressed: _isStreaming ? null : _startStreaming,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
