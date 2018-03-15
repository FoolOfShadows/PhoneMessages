//
//  MainVC.swift
//  PhoneMessages
//
//  Created by Fool on 3/6/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

protocol scriptTableDelegate: class {
    func currentMedsWillBeDismissed(sender: CurrentMedsController)
}

protocol symptomsDelegate: class {
    func symptomsSelectionWillBeDismissed(sender: SymptomsController)
}

class MainVC: NSViewController, scriptTableDelegate, symptomsDelegate {

    @IBOutlet weak var dateView: NSTextField!
    @IBOutlet weak var nameView: NSTextField!
    @IBOutlet weak var dobView: NSTextField!
    @IBOutlet weak var phoneView: NSTextField!
    @IBOutlet weak var pharmacyView: NSTextField!
    @IBOutlet weak var allergiesScroll: NSScrollView!
    @IBOutlet weak var messageScroll: NSScrollView!
    @IBOutlet weak var includeAllergiesCheckbox: NSButton!
    @IBOutlet weak var coughMucusPopup: NSPopUpButton!
    @IBOutlet weak var noseMucusPopup: NSPopUpButton!
    
    //For some reason the program crashes on B's MacBook if I try to connect
    //these NSTextViews direct to their outlets in IB
    var allergiesView: NSTextView {
        get {
            return allergiesScroll.contentView.documentView as! NSTextView
        }
    }
    
    var messageView: NSTextView {
        get {
            return messageScroll.contentView.documentView as! NSTextView
        }
    }
    
    var medicationString = String()
    var wantedMeds = [String]()
    var notedSymptoms = [String]()
    var currentMessageText:Message = Message(theText: String())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearMessage(self)
        allergiesView.font = NSFont.systemFont(ofSize: 18)
        messageView.font = NSFont.systemFont(ofSize: 18)
       
    }
    
    @IBAction func startNewMessage(_ sender: Any) {
        guard let theWindow = self.view.window else { return }
        //Get the clipboard to process
        let pasteBoard = NSPasteboard.general
        guard let theText = pasteBoard.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) else { return }
        if checkForICD10(theText, window: theWindow) == true {
            if !theText.contains("Flowsheets") {
                //Create an alert to let the user know the clipboard doesn't contain
                //the correct PF data
                print("You broke it!")
                //After notifying the user, break out of the program
                let theAlert = NSAlert()
                theAlert.messageText = "It doesn't look like you've copied the correct bits out of Practice Fusion.\nPlease try again or click the help button for complete instructions.\nIf the problem continues, please contact the administrator."
                theAlert.beginSheetModal(for: theWindow) { (NSModalResponse) -> Void in
                    let returnCode = NSModalResponse
                    print(returnCode)}
            }
        }
        
        currentMessageText = Message(theText: theText)
        dateView.stringValue = currentMessageText.messageDate
        nameView.stringValue = currentMessageText.ptInnerName
        dobView.stringValue = currentMessageText.ptDOB
        phoneView.stringValue = currentMessageText.phone
        //lastEncounterView.stringValue = currentMessageText.lastAppointment
        allergiesView.string = currentMessageText.allergies
        medicationString = currentMessageText.medicines
        messageView.string = "Last apt: \(currentMessageText.lastAppointment) - Next apt: \(currentMessageText.nextAppointment)"
    }
    
    @IBAction func getMeds(_ sender: Any) {
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue == "showCurrentMeds" {
            if let toViewController = segue.destinationController as? CurrentMedsController {
                //For the delegate to work, it needs to be assigned here
                //rather than in view did load.  Because it's a modal window?
                toViewController.medReloadDelegate = self
                toViewController.medicationsString = medicationString
            }
        } else if segue.identifier?.rawValue == "showSymptoms" {
            if let toViewController = segue.destinationController as? SymptomsController {
                toViewController.symptomDelegate = self
                toViewController.selectedSymptoms = [String]()
            }
        }
    }
    
    @IBAction func saveFile(_ sender: Any) {
        var allergySelection = String()
        if includeAllergiesCheckbox.state == .on {
            allergySelection = "\n\n\nALLERGIES:\n\(currentMessageText.allergies)"
        }
        let messageText = "\(currentMessageText.messageDate)\n\(currentMessageText.ptInnerName) (DOB: \(currentMessageText.ptDOB))\n\(currentMessageText.phone)\n\(pharmacyView.stringValue)\n\nMESSAGE:\n\(messageView.string)\n\nRESPONSE:\(allergySelection)"
        guard let fileTextData = messageText.data(using: String.Encoding.utf8) else { return }
        saveExportDialogWithData(fileTextData, andFileExtension: ".txt")
    }
    
    
    func saveExportDialogWithData(_ data: Data, andFileExtension ext: String) {
        let savePath = NSHomeDirectory()
        let saveLocation = "WPCMSharedFiles"
        
        let saveDialog = NSSavePanel()
        saveDialog.nameFieldStringValue = "\(currentMessageText.ptLabelName) PMSG \(currentMessageText.labelDate)"
        saveDialog.directoryURL = NSURL.fileURL(withPath: "\(savePath)/\(saveLocation)")
        saveDialog.begin(completionHandler: {(result: NSApplication.ModalResponse) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton {
                if let filePath = saveDialog.url {
                    if let path = URL(string: String(describing: filePath) + ext) {
                        do {
                            try data.write(to: path, options: .withoutOverwriting)
                        } catch {
                            let alert = NSAlert()
                            alert.messageText = "There is already a file with this name.\n Please choose a different name."
                            alert.beginSheetModal(for: self.view.window!) { (NSModalResponse) -> Void in
                                let returnCode = NSModalResponse
                                print(returnCode)
                            }
                        }
                    }
                }
                
            }})
    }
    
    @IBAction func clearMessage(_ sender: Any) {
        self.view.clearControllers()
        currentMessageText = Message(theText: String())
        wantedMeds = [String]()
        noseMucusPopup.removeAllItems()
        noseMucusPopup.addItems(withTitles: mucusColor)
        noseMucusPopup.selectItem(at: 0)
        coughMucusPopup.removeAllItems()
        coughMucusPopup.addItems(withTitles: mucusColor)
        coughMucusPopup.selectItem(at: 0)
    }
    
    func currentMedsWillBeDismissed(sender: CurrentMedsController) {
        if messageView.string.isEmpty {
        messageView.string = "REQUESTED REFILLS:\n\(wantedMeds.joined(separator: "\n"))"
        } else {
            messageView.string += "\n\nREQUESTED REFILLS:\n\(wantedMeds.joined(separator: "\n"))"
        }
    }
    
    func symptomsSelectionWillBeDismissed(sender: SymptomsController) {
        if !notedSymptoms.isEmpty {
        if messageView.string.isEmpty {
            messageView.string = "SYMPTOMS:\n\(notedSymptoms.joined(separator: ", "))"
        } else {
            messageView.string += "\n\nSYMPTOMS:\n\(notedSymptoms.joined(separator: ", "))"
        }
        }
    }
    
    @IBAction func addSymptom(_ sender: NSButton) {
        if sender.state == .on {
        let newSymptom = sender.title
        messageView.string += "\n\(newSymptom)"
        }
    }
    
    @IBAction func addCoughSymptomWithMucusColor(_ sender: NSPopUpButton) {
        if !sender.titleOfSelectedItem!.isEmpty {
            let newSymptom = "productive cough (\(sender.title.lowercased()))"
            messageView.string += "\n\(newSymptom)"
        }
    }
    
    @IBAction func addNoseSymptomWithMucusColor(_ sender: NSPopUpButton) {
        if !sender.titleOfSelectedItem!.isEmpty {
            let newSymptom = "runny nose (\(sender.title.lowercased()))"
            messageView.string += "\n\(newSymptom)"
        }
    }
    
}
