//
//  ViewController.swift
//  SpeechRecognitionA001
//
//  Created by Amit Gupta on 11/4/20.
//


import UIKit
import Speech
//import Kingfisher

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var buttonMain: UIButton!
    @IBOutlet weak var transcribedText: UITextView!
    
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    private var recognitionTask: SFSpeechRecognitionTask?
    
    var micOn : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buildUI()
        getPermissions()
        guard SFSpeechRecognizer.authorizationStatus() == .authorized
        else {
            print("guard failed...")
            return
        }
        
    }
        
    @IBAction func buttonPressed(_ sender: Any) {
        // Toggle the mic on vs. off
        micOn = !micOn
            if micOn{
                // Turn mic ON
                print("Turning microphone ON")
                buttonMain.setImage(UIImage(systemName: "mic.fill"), for: .normal)
                        do{
                            //self.transcribedTextOrig.text = ""
                            transcribedText.text = ""
                            try self.startRecording()
                        }catch(let error){
                            print("error is \(error.localizedDescription)")
                        }
            }
            else{
                // Turn mic OFF
                print("Turning OFF microphone")
                if audioEngine.isRunning {
                    recognitionRequest?.endAudio()
                    audioEngine.stop()
                }
                buttonMain.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
            }
    }
    
    func buildUI()
    {
        buttonMain.setImage(UIImage(systemName: "mic.slash.fill"), for: .normal)
        buttonMain.setTitle("", for: .normal)
        //buttonMain.imageView?.contentMode = .scaleAspectFill
        //buttonMain.alpha=0.5
        //buttonMain.imageView?.heightAnchor.constraint(equalToConstant: 43.0).isActive = true
        //buttonMain.imageView?.widthAnchor.constraint(equalToConstant: 43.0).isActive = true
        
        topLabel.font=topLabel.font.withSize(36)
        topLabel.layer.cornerRadius = 25.0
        topLabel.tintColor = UIColor.lightGray
        
        transcribedText.font=transcribedText.font?.withSize(24)
        transcribedText.layer.cornerRadius = 25.0
        transcribedText.tintColor = UIColor.yellow
        
        transcribedText.text=""
        topLabel.text="Talk to me!!"
        
        //let url = URL(string: "https://media.istockphoto.com/vectors/pastel-multi-color-gradient-vector-backgroundsimple-form-and-blend-vector-id821760914")
        //backgroundImage.kf.setImage(with: url)
        //backgroundImage.contentMode = .scaleAspectFill
        
    }
    
    func startRecording() throws {

        recognitionTask?.cancel()
        self.recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true

        if #available(iOS 13, *) {
            if speechRecognizer?.supportsOnDeviceRecognition ?? false{
                recognitionRequest.requiresOnDeviceRecognition = true
            }
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                        let transcribedString = result.bestTranscription.formattedString
                        //self.transcribedTextOrig.text = (transcribedString)
                    self.transcribedText.text = (transcribedString)
                }
            }
            
            if error != nil {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
    }
    
    func getPermissions(){
        SFSpeechRecognizer.requestAuthorization{authStatus in
            OperationQueue.main.addOperation {
               switch authStatus {
                    case .authorized:
                        print("authorised..")
                    default:
                        print("none")
               }
            }
        }
    }
}

