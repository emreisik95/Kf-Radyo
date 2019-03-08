//
//  PopUpMenuViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/9/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//

import UIKit

class PopUpMenuViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var temaControl: UISegmentedControl!
    
    @IBAction func temaControler(_ sender: UISegmentedControl) {
        
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "secilenTema")
        if temaControl.selectedSegmentIndex == 0{
        Theme.darkTheme()
            self.temaControl.selectedSegmentIndex = 3
       }else if temaControl.selectedSegmentIndex == 1{
        Theme.defaultTheme()
       }else if temaControl.selectedSegmentIndex == 2{
        Theme.pinkTheme()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
    }
    
    @IBOutlet var bildirimSwitchi: UISwitch!
    @IBAction func bildirimSwitch(_ sender: Any) {
        if bildirimSwitchi.isOn == true{
            UserDefaults.standard.set(true, forKey: "bildirim")
        }else if bildirimSwitchi.isOn == false{
            UIApplication.shared.unregisterForRemoteNotifications()
            UserDefaults.standard.set(false, forKey: "bildirim")
        }
        
    }
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    override func viewWillAppear(_ animated: Bool) {
        backgroundView.image = Theme.backgroundImage
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let value = UserDefaults.standard.value(forKey: "secilenTema"){
            let selectedIndex = value as! Int
            temaControl.selectedSegmentIndex = selectedIndex
        }
        
        UserDefaults.standard.register(defaults: ["bildirim" : true])
        UserDefaults.standard.register(defaults: ["secilenTema" : 0])
        let bildirim = UserDefaults.standard.bool(forKey: "bildirim")
        bildirimSwitchi.isOn = bildirim
        // Round corners
        popupView.layer.cornerRadius = 10
        
        // Set background color to clear
        view.backgroundColor = UIColor.clear
        // Add gesture recognizer to dismiss view when touched
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeButtonPressed))
        backgroundView.isUserInteractionEnabled = true
        backgroundView.addGestureRecognizer(gestureRecognizer)
    }
    
    //*****************************************************************
    // MARK: - IBActions
    //*****************************************************************

    @IBAction func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
        self.loadView()
    }
   
    @IBAction func websiteButtonPressed(_ sender: UIButton) {
        // Use your own website URL here
        guard let url = URL(string: "https://kafaradyo.com") else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
}
