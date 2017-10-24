//
//  FirstViewController.swift
//  collectionDemo
//
//  Created by minh ho on 10/9/17.
//  Copyright © 2017 minh ho. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var searchSubReddit: UITextField!
    
    @IBAction func searchButton(_ sender: UIButton) {
        performSegue(withIdentifier: "mySegueId", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        searchSubReddit.delegate = self
        
        // Do any additional setup after loading the view.
    }

//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "mySegueId") {
//            if let svc = segue.destination as? MyCollectionViewController {
//                svc.subRedditString = searchSubReddit.text
//            }
            let vc = segue.destination as! MyCollectionViewController
            guard let tempString = searchSubReddit.text else {return}
            vc.subRedditString = tempString
//        }
    }


}
