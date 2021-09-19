//
//  HomePageViewController.swift
//  Manor
//
//  Created by Colin Birkenstock on 8/23/21.
//

import UIKit
import DropDown

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var contactsView: UIView!
    @IBOutlet weak var directMessagesLabel: UILabel!
    @IBOutlet weak var groupChatLabel: UILabel!
    @IBOutlet weak var titleStackView: UIStackView!
    @IBOutlet weak var profileBarButton: UIBarButtonItem!
    
    let dropDown = DropDown()
    
    @IBOutlet weak var titleStackHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //self.directMessagesLabel.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideNavigationBar), name: NSNotification.Name("hideNavigationBar"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showNavigationBar), name: NSNotification.Name("showNavigationBar"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.makeDMTitleBold), name: NSNotification.Name("makeDMTitleBold"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.makeGroupChatTitleBold), name: NSNotification.Name("makeGroupChatTitleBold"), object: nil)
        
        //sets up drop down for choosing between new DM or group chat
        dropDown.anchorView = self.titleStackView
        dropDown.dataSource = ["New Direct Message", "New Group Chat"]
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        dropDown.width = screenWidth
        //dropDown.bottomOffset = CGPoint(x: 20, y:0)
        dropDown.backgroundColor =
        UIColor(named: K.BrandColors.purple)
        DropDown.appearance().cornerRadius = 10
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 18, weight: .semibold)
        DropDown.appearance().textColor = .white
        DropDown.appearance().cellHeight = 30
        //DropDown.appearance().setupMaskedCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        dropDown.selectionAction = { (index: Int, item: String) in
            if (item == "New Direct Message") {
                self.performSegue(withIdentifier: K.Segues.newDirectMessageSegue, sender: self)
            }
            
            if (item == "New Group Chat") {
                self.performSegue(withIdentifier: K.Segues.newGroupMessageSegue, sender: self)
            }
        }
        dropDown.willShowAction = {
            DropDown.appearance().selectionBackgroundColor = UIColor(named: K.BrandColors.purple)!
        }
        
        self.setupNavigationBar()
    }
    
    @IBAction func profileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    @IBAction func CreateNewMessagePressed(_ sender: Any) {
        dropDown.show()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor(named: K.BrandColors.purple)
    }
    
    @objc func makeDMTitleBold() {
        //had to switch quickly before rush so that's why this is confusing
        self.groupChatLabel.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        self.directMessagesLabel.font = UIFont.systemFont(ofSize: 21, weight: .regular)
    }
    
    @objc func makeGroupChatTitleBold() {
        //had to switch quickly before rush so that's why this is confusing 
        self.directMessagesLabel.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        self.groupChatLabel.font = UIFont.systemFont(ofSize: 21, weight: .regular)
    }
    

    @objc func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.titleStackHeightConstraint.constant = 0
        self.view.layoutIfNeeded()
        //UIView.animate(withDuration: 0.05) { self.view.layoutIfNeeded() }
    }
    
    @objc func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.titleStackHeightConstraint.constant = 25.5
        self.view.layoutIfNeeded()
        //UIView.animate(withDuration: 0.05) { self.view.layoutIfNeeded() }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.setHidesBackButton(false, animated: false)
    }
    
    
    
}
