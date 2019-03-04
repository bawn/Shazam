//
//  ViewController.swift
//  Shazam-Demo
//
//  Created by bawn on 2019/2/22.
//  Copyright © 2019 bawn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBAction func buttonAction(_ sender: Any) {
        navigationController?.pushViewController(PageViewController(), animated: true)
    }
}

