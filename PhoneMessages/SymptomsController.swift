//
//  SymptomsController.swift
//  PhoneMessages
//
//  Created by Fool on 3/12/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

class SymptomsController: NSViewController {
    
    @IBOutlet weak var symptomsButtonView: NSView!
    @IBOutlet weak var coughMucusPopup: NSPopUpButton!
    @IBOutlet weak var noseMucusPopup: NSPopUpButton!
    
    var selectedSymptoms = [String]()
    
    weak var symptomDelegate: symptomsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        addSelectorToButtonsInView(symptomsButtonView)
        clearSymptoms(self)
    }

    
    @IBAction func clearSymptoms(_ sender: Any) {
        self.view.clearControllers()
        noseMucusPopup.removeAllItems()
        noseMucusPopup.addItems(withTitles: mucusColor)
        noseMucusPopup.selectItem(at: 0)
        coughMucusPopup.removeAllItems()
        coughMucusPopup.addItems(withTitles: mucusColor)
        coughMucusPopup.selectItem(at: 0)
    }
    
    @IBAction func processSymptoms(_ sender: Any) {
        let firstVC = presenting as! MainVC
        firstVC.notedSymptoms = selectedSymptoms
        symptomDelegate?.symptomsSelectionWillBeDismissed(sender: self)
        print(selectedSymptoms.joined(separator: ", "))
        self.dismiss(self)
    }
    
    @objc func appendToSelectedSymptoms(_ sender: NSButton) {
        if sender.state == .on {
            selectedSymptoms.append(sender.title.lowercased())
        } else if sender.state == .off {
            selectedSymptoms = selectedSymptoms.filter {$0 != sender.title.lowercased()}
        }
    }
    
    func addSelectorToButtonsInView(_ view:NSView) {
        for item in view.subviews {
            if let button = item as? NSButton, item as? NSPopUpButton == nil {
                button.target = self
                button.action = #selector(appendToSelectedSymptoms)
            } else {
                addSelectorToButtonsInView(item)
            }
        }
    }
    
    @IBAction func addCoughSymptomWithMucusColor(_ sender: NSPopUpButton) {
        if !sender.titleOfSelectedItem!.isEmpty {
            selectedSymptoms.append("productive cough (\(sender.title.lowercased()))")
        }
    }
    
    @IBAction func addNoseSymptomWithMucusColor(_ sender: NSPopUpButton) {
        if !sender.titleOfSelectedItem!.isEmpty {
            selectedSymptoms.append("runny nose (\(sender.title.lowercased()))")
        }
    }
}
