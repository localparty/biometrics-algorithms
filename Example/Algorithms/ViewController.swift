//
//  ViewController.swift
//  Algorithms
//
//  Created by localparty on 02/21/2019.
//  Copyright (c) 2019 localparty. All rights reserved.
//

import UIKit
import Algorithms

class ViewController: UIViewController {
    
    var randomData: RandomData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let printSignatureDelegate: PrintSignatureDelegate = PrintSignatureDelegate()
        let dataDelegate = EEGEventRange(
            eegEventDelegate: printSignatureDelegate,
            attentionRange: 40.0 ... 50.0,
            meditationRange: 40.0 ... 50.0)
        
        randomData = RandomData(
            rawFrequency: 30,
            attentionFrequency: 1,
            meditationFrequency: 1,
            delegate: dataDelegate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

