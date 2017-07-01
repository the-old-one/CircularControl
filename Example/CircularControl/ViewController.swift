//
//  ViewController.swift
//  CircularControl
//
//  Created by Peyotle on 06/28/2017.
//  Copyright (c) 2017 Peyotle. All rights reserved.
//

import UIKit
import CircularControl

class ViewController: UIViewController {

    let valueLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        addCircularControl()
        setupLabel()
    }

    func addCircularControl() {
        let control = CircularControl(radius: 150 , lineWidth: 20)
        control.center = view.center
        control.minimumValue = 0
        control.maximumValue = 10
        control.trackColor = .darkGray
        control.value = 5
        control.startAngle = 90
        
        control.addTarget(self, action: #selector(trackValueChanged(sender:)), for: .valueChanged)
        view.addSubview(control)
    }

    func setupLabel() {
        valueLabel.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        valueLabel.center = view.center
        view.addSubview(valueLabel)
    }

    func trackValueChanged(sender: CircularControl) {
        let valueString = String(format: "%.2f", sender.value)
        valueLabel.text = valueString
    }
}

