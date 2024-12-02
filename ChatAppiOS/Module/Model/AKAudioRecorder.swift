//
//  AKAudioRecorder.swift
//  AKAudioRecorder
//
//  Created by Roberto Flores on 26/11/24.
//
//

import Foundation
import AVFoundation
import AVKit

class AKAudioRecorder: NSObject {
    
    //MARK:- Instance
    static let shared = AKAudioRecorder()
    
    //MARK:- Variables ( Private )
    let audioSession = AVAudioSession.sharedInstance()
    
    private var settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ] as [String : Any]
    
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var fileName: String?
    fileprivate var timer: Timer!
    var myRecordings = [String]()
    
    //MARK:- Public Variables
    var isRecording: Bool = false
    var isPlaying: Bool = false
    var duration: CGFloat = 0.0
    var recordingName: String?
    var numberOfLoops: Int?
    var rate: Float? {
        didSet {
            if rate! < 0.5 {
                rate = 0.5
                print("Rate cannot be less than 0.5")
            } else if rate! > 2.0 {
                rate = 2.0
                print("Rate cannot exceed 2")
            }
        }
    }
    
    //MARK:- Pre-Recording Setup
    private func InitialSetup() {
        fileName = UUID().uuidString
        let audioFilename = getDocumentsDirectory().appendingPathComponent((recordingName?.appending(".m4a") ?? fileName!.appending(".m4a")))
        myRecordings.append(recordingName ?? fileName!)
        
        if !checkRepeat(name: recordingName ?? fileName!) {
            print("Same name reused, recording will be overwritten")
        }
        
        do {
            try audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioPlayer?.stop()
        } catch let error as NSError {
            print("Error setting up: \(error.localizedDescription)")
        }
    }
    
    //MARK:- Record
    func record() {
        InitialSetup()
        if let audioRecorder = audioRecorder, !isRecording {
            do {
                try audioSession.setActive(true)
                duration = 0
                isRecording = true
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateDuration), userInfo: nil, repeats: true)
                audioRecorder.record()
                debugLog("Recording")
            } catch let error as NSError {
                print("Error recording: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK:- Stop Recording
    func stopRecording() {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
            do {
                try audioSession.setActive(false)
                isRecording = false
                debugLog("Recording Stopped")
            } catch {
                print("stop(): \(error.localizedDescription)")
            }
        }
    }
    
    //MARK:- Play Recording
    func play(name: String) {
        let fileName = name + ".m4a"
        let path = getDocumentsDirectory().appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: path.path), !isRecording, !isPlaying {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: path)
                audioPlayer.delegate = self
                audioPlayer.play()
                isPlaying = true
                debugLog("Playing")
            } catch {
                print("play(): \(error.localizedDescription)")
            }
        } else {
            print("File Does Not Exist")
        }
    }
    
    func getAudioURL(name: String) -> URL?{
            let fileName = name + ".m4a"
            
            let path = getDocumentsDirectory().appendingPathComponent(fileName)
            return path
    }
    
    //MARK:- Stop Playing
    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
        debugLog("Stopped Playing")
    }
    
    //MARK:- Delete Recording
    func deleteRecording(name: String) {
        let path = getDocumentsDirectory().appendingPathComponent(name.appending(".m4a"))
        let manager = FileManager.default
        
        if manager.fileExists(atPath: path.path) {
            do {
                try manager.removeItem(at: path)
                removeRecordingFromArray(name: name)
                debugLog("Recording Deleted")
            } catch {
                print("deleteRecording(): \(error.localizedDescription)")
            }
        } else {
            print("File Does Not Exist")
        }
    }
    
    private func removeRecordingFromArray(name: String) {
        if let index = myRecordings.firstIndex(of: name) {
            myRecordings.remove(at: index)
        }
    }
    
    //MARK:- Helper Methods
    private func checkRepeat(name: String) -> Bool {
        var count = myRecordings.filter { $0 == name }.count
        if count > 1 {
            while count != 1 {
                if let index = myRecordings.firstIndex(of: name) {
                    myRecordings.remove(at: index)
                    count -= 1
                }
            }
            return false
        }
        return true
    }
    
    @objc private func updateDuration() {
        if isRecording {
            duration += 1
        } else {
            timer.invalidate()
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var getRecordings: [String] {
            return self.myRecordings
    }
}

//MARK:- AVAudioRecorderDelegate
extension AKAudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        timer.invalidate()
        debugLog(flag ? "Recording Finished" : "Recording Error")
    }
}

//MARK:- AVAudioPlayerDelegate
extension AKAudioRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        debugLog("Finished Playing")
    }
}
extension CGFloat {
    var timeStringFormatter: String {
        let minutes = Int(self) / 60   // Calcula los minutos
        let seconds = Int(self) % 60   // Calcula los segundos restantes
        
        // Formatea el tiempo como "mm:ss", asegurando que siempre tenga dos dígitos
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

//MARK:- Debugging Helper
public func debugLog(_ message: String) {
    #if DEBUG
    print("=================================================")
    print(message)
    print("=================================================")
    #endif
}

