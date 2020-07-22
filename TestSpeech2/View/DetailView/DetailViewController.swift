//
//  DetailViewController.swift
//  TestSpeech2
//
//  Created by kita kensuke on 2020/07/22.
//  Copyright © 2020 kita kensuke. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var detailInfo: DetailInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //遷移元から渡されたデータを表示
        guard let detail = detailInfo else {return}
        memoTextView.text = detail.memo
        if let date = detail.date {
            print(date)
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            dateTextField.text = formatter.string(from: date)
        }
        if let address = detail.address {
            print(address)
            var getAddress: String = ""
            if let state = address[NSTextCheckingKey(rawValue: "State")] {
                getAddress = getAddress + state
            }
            if let city = address[NSTextCheckingKey(rawValue: "City")] {
                getAddress = getAddress + city
            }
            if let street = address[NSTextCheckingKey(rawValue: "Street")] {
                getAddress = getAddress + street
            }
            addressTextField.text = getAddress
        }
        if let phone = detail.phone {
            print(phone)
            phoneTextField.text = phone
        }
    }
    
    //画面遷移でテキストクリア
    override func viewWillDisappear(_ animated: Bool) {
        memoTextView.text = ""
        dateTextField.text = ""
        addressTextField.text = ""
        phoneTextField.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
