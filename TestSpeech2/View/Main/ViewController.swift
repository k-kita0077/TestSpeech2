//
//  ViewController.swift
//  TestSpeech2
//
//  Created by kita kensuke on 2020/07/22.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SpeechControllerDelegate {
    
    
    
    @IBOutlet weak var textView: UITextView!
    
    let speechController = SpeechController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechController.delegate = self
    }
    
    //画面描画時に録音開始
    override func viewWillAppear(_ animated: Bool) {
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                if status == .authorized {
                    try! self.speechController.startLiveTranscription("完了")
                } else {
                    let action = UIAlertController(title: "音声認識が利用できません", message: "端末の設定で音声認識の利用を許可して下さい", preferredStyle: .alert)
                    self.present(action, animated: true, completion: nil)
                }
            }
        }
    }
    
    //画面遷移で録音終了
    override func viewWillDisappear(_ animated: Bool) {
        speechController.stopLiveTranscription()
        textView.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func acquiredText(_ str: String) {
        textView.text = str
    }
    
    func didRecognize(_ detailInfo: DetailInfo) {
        let vc = DetailViewController()
        //住所情報等を遷移先に渡す
        vc.detailInfo = detailInfo
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

