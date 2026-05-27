# Lecture 18 - 02 - Generative AI

We now use GenKit to process streaming requests.

## Cloud Functions

### GenKit setup
Using these packages in our `index.js`:
```javascript
const { googleAI } = require('@genkit-ai/google-genai');
const { defineSecret } = require("firebase-functions/params");
const { enableFirebaseTelemetry } = require('@genkit-ai/firebase');
const { onCallGenkit } = require("firebase-functions/https");
const { genkit, z } = require("genkit");
```
we define our **AI** model and enable Telemetry for AI Generation Monitoring in Firebase:
```javascript
const ai = genkit({
    plugins: [googleAI()],
    model: 'googleai/gemini-3.5-flash',
});
enableFirebaseTelemetry();
```
### Defining the Flow and Function
```javascript
const answerQuestionFlow = ai.defineFlow({
    name: "answerQuestion",
    inputSchema: z.object({
        question: z.string(),
    }),
    outputSchema: z.string(),
    streamSchema: z.string(),
}, async (input, { sendChunk }) => {
    const { stream, response } = await ai.generateStream({
        prompt: input.question,
    });

    for await (const chunk of stream) {
        if (chunk.text) {
            sendChunk(chunk.text);
        }
    }

    const finalResponse = await response;
    return finalResponse.text;
});

exports.answerQuestion = onCallGenkit({
    secrets: ['GOOGLE_API_KEY'],
    timeoutSeconds: 540,
}, answerQuestionFlow);
```

## Flutter

Add StreamBuilder to process the streaming response:
```dart
 final callable = FirebaseFunctions.instance.httpsCallable(
        'answerQuestion',
      );
      final stream = callable.stream(<String, dynamic>{
        'question': question,
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
```
Here the stream coming back from the cloud function is incrementally shown on the page.