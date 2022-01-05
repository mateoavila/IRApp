//
//  IntroViewController.swift
//  IRApp
//
//  Created by Mateo Avila on 5/11/21.
//

import UIKit

class IntroViewController: UIViewController {

    @IBOutlet weak var beginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.styleFilledButton(beginButton)
    }
    

    @IBAction func beginButtonTapped(_ sender: Any) {
        transitionMainScreen()
    }
    
    func transitionMainScreen() {
        let mainViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.mainViewController) as? MainViewController
        
        view.window?.rootViewController = mainViewController
        view.window?.makeKeyAndVisible()
    }
    
}
