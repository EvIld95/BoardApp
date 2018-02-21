//
//  MainViewController.swift
//  BoardApp
//
//  Created by Paweł Szudrowicz on 21.02.2018.
//  Copyright © 2018 Paweł Szudrowicz. All rights reserved.
//

import UIKit
import SwiftSocket

class MainViewController: UIViewController {
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var rpmLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    private let client = TCPClient(address: "10.10.0.1", port: 1246)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch client.connect(timeout: 5) {
            case .success:
                print("SUCCES CONNECT!")
            
            case .failure(let error):
                print(error)
        }
        
        
        DispatchQueue.global(qos: .background).async { [unowned self] in
            while(true) {
                guard let data = self.client.read(64) else { continue }
                guard let response = String(bytes: data, encoding: .utf8) else { continue }
                DispatchQueue.main.async {
                    print("RESP" + response)
                    let values = response.components(separatedBy: "!")
                    
                    for value in values[0..<values.count-1] {
                        let cleanData = value.components(separatedBy: " ")
                        print(cleanData)
                        
                        guard cleanData.count > 1 else {
                            continue
                        }
                        let name = cleanData[0]
                        let valueString = cleanData[1]
                        
                        
                        if(name == "v_in") {
                            self.batteryLabel.text = valueString + "V"
                        } else if(name == "rpm") {
                            self.rpmLabel.text = valueString + "RPM"
                        } else if(name == "current_motor") {
                            self.currentLabel.text = valueString + "AMP"
                        }
                    }
                }
            }
        }
    }
}
