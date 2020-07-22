//
//  SpeechController.swift
//  TestSpeech2
//
//  Created by kita kensuke on 2020/07/22.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import Foundation
import Speech
import AVFoundation

protocol SpeechControllerDelegate: class {
    
    func acquiredText(_ str: String)
    
    func didRecognize(_ detailInfo: DetailInfo)
}

class SpeechController {
    let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ja_JP"))!
    var audioEngine: AVAudioEngine = AVAudioEngine()
    var recognitionReq: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    
    weak var delegate: SpeechControllerDelegate?
    
    //読み取り終了
    func stopLiveTranscription() {
        //オーディオセッションをplaysessionに戻す
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.setMode(AVAudioSession.Mode.default)
        } catch{
            print("audio session error")
        }
        
        recognitionTask?.cancel()
        recognitionTask?.finish()
        recognitionTask = nil
        recognitionReq?.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
    }
    
    //読み取り開始
    func startLiveTranscription(_ str: String ) throws {
        
        // もし前回の音声認識タスクが実行中ならキャンセル
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // 音声認識リクエストの作成
        recognitionReq = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionReq = recognitionReq else {return}
        recognitionReq.shouldReportPartialResults = true
        
        // オーディオセッションの設定
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // マイク入力の設定
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 2048, format: recordingFormat) { (buffer, time) in
            recognitionReq.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = recognizer.recognitionTask(with: recognitionReq, resultHandler: { (result, error) in
            if let error = error {
                print("\(error)")
            } else {
                guard let talkResult = result?.bestTranscription.formattedString else {return}
                //文字起こし
                self.delegate?.acquiredText(talkResult)
                
                //読み取った文字の中に”完了”があったら終了
                if talkResult.contains(str) {
                    //読み取った文字から”完了”を探してその前の文を取得
                    let talkIndex = talkResult.range(of: str)
                    let talkFlag = talkResult.distance(from: talkResult.startIndex, to: talkIndex!.lowerBound)
                    let talkValue = talkResult[talkResult.index(talkResult.startIndex, offsetBy: 0)..<talkResult.index(talkResult.startIndex, offsetBy: talkFlag)]
                    //文字起こし
                    self.delegate?.acquiredText(String(talkValue))
                    
                    //住所情報などを取得
                    let getDate = self.detectDate(String(talkValue))
                    let date = self.getSpeechDate(getDate)
                    
                    let getAddress = self.detectAddress(String(talkValue))
                    let address = self.getSpeechAddress(getAddress)
                    
                    let getPhone = self.detectPhone(String(talkValue))
                    let phone = self.getSpeechPhone(getPhone)
                    
                    let detailInfo = DetailInfo(memo: String(talkValue), date: date, address: address, phone: phone)
                    
                    self.delegate?.didRecognize(detailInfo)
                    
                }
                
            }
            
        })
        
    }
    
    //文中から日付を取得
    func detectDate(_ str: String) -> [NSTextCheckingResult] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        if let d = detector {
            return d.matches(in: str, range: NSMakeRange(0, str.count))
        } else {
            return []
        }
    }
    
    func getSpeechDate(_ getValue: [NSTextCheckingResult]) -> Date?{
        var v: Date?
        getValue.forEach {
            v = $0.date
        }
        return v
    }
    
    //文中から住所を取得
    func detectAddress(_ str: String) -> [NSTextCheckingResult] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.address.rawValue)
        if let d = detector {
            return d.matches(in: str, range: NSMakeRange(0, str.count))
        } else {
            return []
        }
    }
    
    func getSpeechAddress(_ getValue: [NSTextCheckingResult]) -> [NSTextCheckingKey : String]?{
        var v: [NSTextCheckingKey : String]?
        getValue.forEach {
            v = $0.addressComponents
        }
        return v
    }
    
    //文中から電話番号を取得
    func detectPhone(_ str: String) -> [NSTextCheckingResult] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        if let d = detector {
            return d.matches(in: str, range: NSMakeRange(0, str.count))
        } else {
            return []
        }
    }
    
    func getSpeechPhone(_ getValue: [NSTextCheckingResult]) -> String?{
        var phone: String?
        getValue.forEach {
            phone = $0.phoneNumber
        }
        return phone
    }
}
