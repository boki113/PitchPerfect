//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Perica on 13.02.18.
//  Copyright © 2018 Boris. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    let LabelTextRecordingInProgess = "Recording in Progress"
    let LabelTextTaptoRecord = "Tap to Record"
    let ErrorMessageRecordingFailed = "Recording failed while trying to stop the recording. Please try again"
    let StopRecordingSegueIdentifier = "stopRecording"
    
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stopRecordingButton.isEnabled = false
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        configureUI(isRecording: true)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with:AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        configureUI(isRecording: false)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: StopRecordingSegueIdentifier, sender: audioRecorder.url)
        } else {
             showAlert("Recording failed", message: ErrorMessageRecordingFailed)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            if let playSoundsVC = segue.destination as? PlaySoundsViewController {
                if let recordedAudioURL = sender as? URL {
                    playSoundsVC.recordedAudioURL = recordedAudioURL
                }
            }
        }
    }
    
    // Change UI Component values depending on the state of recording (stop/start)
    func configureUI(isRecording: Bool) {
        
        if isRecording {
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
            recordingLabel.text = LabelTextRecordingInProgess
            
            return
        }
        
        recordButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        recordingLabel.text =  LabelTextTaptoRecord
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Recording Alert" , style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
