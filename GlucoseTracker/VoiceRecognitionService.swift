import Foundation
import Speech
import AVFoundation

class VoiceRecognitionService: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var transcription = ""
    @Published var isAuthorized = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // MARK: - Completion Handler
    var onTranscriptionComplete: ((VoiceRecognitionResult) -> Void)?
    
    override init() {
        super.init()
        requestPermissions()
    }
    
    // MARK: - Permission Methods
    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.isAuthorized = true
                case .denied, .restricted, .notDetermined:
                    self?.isAuthorized = false
                    self?.errorMessage = "Speech recognition permission denied"
                @unknown default:
                    self?.isAuthorized = false
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                if !granted {
                    self?.errorMessage = "Microphone permission denied"
                }
            }
        }
    }
    
    // MARK: - Recording Methods
    func startRecording() {
        guard !isRecording else { return }
        guard isAuthorized else {
            errorMessage = "Speech recognition not authorized"
            return
        }
        
        do {
            try startRecordingSession()
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        isRecording = false
    }
    
    private func startRecordingSession() throws {
        // Cancel any previous task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw VoiceRecognitionError.unableToCreateRequest
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Get input node
        let inputNode = audioEngine.inputNode
        
        // Create recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let result = result {
                    self?.transcription = result.bestTranscription.formattedString
                    
                    if result.isFinal {
                        self?.handleFinalTranscription(result)
                    }
                }
                
                if let error = error {
                    self?.errorMessage = "Recognition error: \(error.localizedDescription)"
                    self?.stopRecording()
                }
            }
        }
        
        // Configure audio format
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
        
        isRecording = true
        transcription = ""
        errorMessage = nil
    }
    
    private func handleFinalTranscription(_ result: SFSpeechRecognitionResult) {
        let voiceResult = VoiceRecognitionResult(
            transcription: result.bestTranscription.formattedString,
            confidence: result.bestTranscription.averageConfidence
        )
        
        onTranscriptionComplete?(voiceResult)
        stopRecording()
    }
    
    // MARK: - Cleanup
    deinit {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
}

// MARK: - Voice Recognition Error
enum VoiceRecognitionError: Error {
    case unableToCreateRequest
    case audioEngineFailure
    case speechRecognizerUnavailable
    
    var localizedDescription: String {
        switch self {
        case .unableToCreateRequest:
            return "Unable to create speech recognition request"
        case .audioEngineFailure:
            return "Audio engine failed to start"
        case .speechRecognizerUnavailable:
            return "Speech recognizer is not available"
        }
    }
}