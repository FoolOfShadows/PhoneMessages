//
//  MessageModel.swift
//  PhoneMessages
//
//  Created by Fool on 3/6/18.
//  Copyright © 2018 Fool. All rights reserved.
//

import Cocoa

struct Message {
    
    var theText:String
    
    private let currentDate = Date()
    private let formatter = DateFormatter()
    var messageDate:String {
        formatter.dateStyle = DateFormatter.Style.short
        return formatter.string(from: currentDate)
    }
    var labelDate:String {
        formatter.dateFormat = "yyMMdd"
        return formatter.string(from: currentDate)
    }
    
    var ptInnerName:String {return nameAgeDOB(theText).0}
    var ptLabelName:String {return getFileLabellingName(ptInnerName)}
    var ptDOB:String {return nameAgeDOB(theText).2}
    var phone:String {return nameAgeDOB(theText).3}
    var allergies:String {return theText.simpleRegExMatch(Regexes.allergies.rawValue).cleanTheTextOf(basicAllergyBadBits)/*getAllergyTextFrom(theText)*/}
    var medicines:String {return theText.simpleRegExMatch(Regexes.medications.rawValue).cleanTheTextOf(medBadBits)/*getMedTextFrom(theText)*/}
    var lastAppointment:String {return getLastAptInfoFrom(theText)}
    var nextAppointment:String {return getNextAptInfoFrom(theText)}

    enum Regexes:String {
        case social = "(?s)(Social history).*((?<=)Past medical history)"
        case family1 = "(?s)(Family health history).*(Preventive care)"
        case family2 = "(?s)(Family health history).*(Social history)"
        case nutrition1 = "(?s)(Nutrition history).*((?<=)Developmental history)"
        case nutrition2 = "(?s)(Nutrition history).*((?<=)Allergies\\n)"
        case diagnoses = "(?s)Diagnoses.*Social history*?\\s(?=\\nSmoking status*?\\s\\n)"
        case medications = "(?s)(Medications).*(Encounters)"
        case allergies = "(?s)(\nAllergies\n).*(Medications)"
        case pmh = "(?s)(Ongoing medical problems).*(Family health history)"
        case psh = "(?s)(Major events).*(Ongoing medical problems)"
        case preventive = "(?s)(Preventive care).*((?<=)Social history)"
    }
    
}


func nameAgeDOB(_ theText: String) -> (String, String, String, String){
    var ptName = ""
    var ptAge = ""
    var ptDOB = ""
    var ptPhoneArray = [String]()
    let theSplitText = theText.components(separatedBy: "\n")
    
    var lineCount = 0
    if !theSplitText.isEmpty {
        for currentLine in theSplitText {
            if currentLine.range(of: "PRN: ") != nil {
                let ageLine = theSplitText[lineCount + 1]
                ptName = theSplitText[lineCount - 1]
                ptAge = ageLine.simpleRegExMatch("^\\d*")
            } else if currentLine.hasPrefix("DOB: ") {
                let dobLine = currentLine
                ptDOB = dobLine.simpleRegExMatch("\\d./\\d./\\d*")
            } else if currentLine.hasPrefix("H: (") || currentLine.hasPrefix("W: (") || currentLine.hasPrefix("M: (") {
                 ptPhoneArray.append(currentLine)
            }
            lineCount += 1
        }
    }
    //print(ptName, ptAge, ptDOB, ptPhone)
    return (ptName, ptAge, ptDOB, ptPhoneArray.joined(separator: "\t"))
    
}

//Parse a string containing a full name into it's components and returns
//the version of the name we use to label files
func getFileLabellingName(_ name: String) -> String {
    var fileLabellingName = String()
    var ptFirstName = ""
    var ptLastName = ""
    var ptMiddleName = ""
    var ptExtraName = ""
    let extraNameBits = ["Sr", "Jr", "II", "III", "IV", "MD"]
    
    func checkForMatchInSets(_ arrayToCheckIn: [String], arrayToCheckFor: [String]) -> Bool {
        var result = false
        for item in arrayToCheckIn {
            if arrayToCheckFor.contains(item) {
                result = true
                break
            }
        }
        return result
    }
    
    let nameComponents = name.components(separatedBy: " ")
    
    let extraBitsCheck = checkForMatchInSets(nameComponents, arrayToCheckFor: extraNameBits)
    
    if extraBitsCheck == true {
        ptLastName = nameComponents[nameComponents.count-2]
        ptExtraName = nameComponents[nameComponents.count-1]
    } else {
        ptLastName = nameComponents[nameComponents.count-1]
        ptExtraName = ""
    }
    
    if nameComponents.count > 2 {
        if nameComponents[nameComponents.count - 2] == "Van" {
            ptLastName = "Van " + ptLastName
        }
    }
    
    //Get first name
    ptFirstName = nameComponents[0]
    
    //Get middle name
    if (nameComponents.count == 3 && extraBitsCheck == true) || nameComponents.count < 3 {
        ptMiddleName = ""
    } else {
        ptMiddleName = nameComponents[1]
    }
    
    fileLabellingName = "\(ptLastName)\(ptFirstName)\(ptMiddleName)\(ptExtraName)"
    fileLabellingName = fileLabellingName.replacingOccurrences(of: " ", with: "")
    fileLabellingName = fileLabellingName.replacingOccurrences(of: "-", with: "")
    fileLabellingName = fileLabellingName.replacingOccurrences(of: "'", with: "")
    fileLabellingName = fileLabellingName.replacingOccurrences(of: "(", with: "")
    fileLabellingName = fileLabellingName.replacingOccurrences(of: ")", with: "")
    fileLabellingName = fileLabellingName.replacingOccurrences(of: "\"", with: "")
    
    
    return fileLabellingName
}

//Check that the Diagnosis "Show by" is set to ICD-10
func checkForICD10(_ theText: String, window: NSWindow) -> Bool {
    var icd10bool = true
    let start = "Diagnoses  Show by"
    let end = "Chronic diagnoses"
    let regex = try! NSRegularExpression(pattern: "\(start).*?\(end)", options: NSRegularExpression.Options.dotMatchesLineSeparators)
    let length = theText.count
    
    if let match = regex.firstMatch(in: theText, options: [], range: NSRange(location: 0, length: length)) {
        let theResult = (theText as NSString).substring(with: match.range)
        if !theResult.contains("ICD-10") {
            icd10bool = false
            //Create an alert to let the user know the diagnoses are not set to ICD10
            print("Not set to ICD10")
            //After notifying the user, break out of the program
            let theAlert = NSAlert()
            theAlert.messageText = "It appears Practice Fusion is not set to show ICD-10 diagnoses codes.  Please set the Show by option in the Diagnoses section to ICD-10 and try again."
            theAlert.beginSheetModal(for: window) { (NSModalResponse) -> Void in
                let returnCode = NSModalResponse
                print(returnCode)}
        }
    }
    return icd10bool
}

//func getAllergyTextFrom(_ theText:String) -> String {
//    var allergyResults = [String]()
//    //Get the allergy info
//    if var basicAllergyRegex = theText.findRegexMatchBetween(basicAllergyStartOfText, and: basicAllergyEndOfText) {
//        basicAllergyRegex = basicAllergyRegex.cleanTheTextOf(basicAllergyBadBits)
//        basicAllergyRegex = basicAllergyRegex.replacingOccurrences(of: "\n\n", with: "\n")
//        allergyResults.append(basicAllergyRegex)
//    }
//
//
//    let finalAllergiesParameter = defineFinalParameter(theText, firstParameter: freeAllergyEndOfTextFirstParameter, secondParameter: freeAllergyEndOfTextSecondParameter)
//    if var freeAllergyRegex = theText.findRegexMatchBetween(freeAllergyStartOfText, and: finalAllergiesParameter) {
//        freeAllergyRegex = freeAllergyRegex.cleanTheTextOf(freeAllergyBadBits)
//        freeAllergyRegex = freeAllergyRegex.replacingOccurrences(of: "\n\n", with: "\n")
//        allergyResults.append(freeAllergyRegex)
//    }
//    //print(allergyResults)
//    return allergyResults.joined(separator: "\n")
//}

//func getMedTextFrom(_ theText:String) -> String {
//    guard let theResults = theText.findRegexMatchBetween(medStartOfText, and: medEndOfText) else {return "No med info found"}
//    if theResults.isEmpty || theResults == "" {
//        return "Meds turned up empty"
//    }
//    return theResults
//}

//Check for the existence of certain strings in the text
//in order to determine the best string to use in the regexTheText function
//func defineFinalParameter(_ theText: String, firstParameter: String, secondParameter: String) -> String {
//    var theParameter = ""
//    if theText.range(of: firstParameter) != nil {
//        theParameter = firstParameter
//    } else if theText.range(of: secondParameter) != nil {
//        theParameter = secondParameter
//    }
//    return theParameter
//}

func getLastAptInfoFrom(_ theText: String) -> String {
    guard let baseSection = theText.findRegexMatchFrom("Encounters", to: "Appointments") else {return ""}
    //print(baseSection)
    guard let encountersSection = baseSection.findRegexMatchBetween("Encounters", and: "Messages") else {return ""}
    //print(encountersSection)
    let activeEncounters = encountersSection.ranges(of: "(?s)(\\d./\\d./\\d*)(.*?)(\\n)(?=\\d./\\d./\\d*)", options: .regularExpression).map{encountersSection[$0]}.map{String($0)}.filter {!$0.contains("No chief complaint recorded")}
    print(activeEncounters)
    if activeEncounters.count > 0 {
    return activeEncounters[0].simpleRegExMatch("\\d./\\d./\\d*")
    } else {
        return "Last apt not found"
    }
}

func getNextAptInfoFrom(_ theText: String) -> String {
    guard let nextAppointments = theText.findRegexMatchBetween("Appointments", and: "View all appointments") else {return ""}
    //print(nextAppointments)
    let activeEncounters = nextAppointments.ranges(of: "(?s)(\\w\\w\\w \\d\\d, \\d\\d\\d\\d)(.*?)(\\n)(?=\\w\\w\\w \\d\\d, \\d\\d\\d\\d)", options: .regularExpression).map{nextAppointments[$0]}.map{String($0)}.filter {$0.contains("Pending arrival")}
    if activeEncounters.count > 0 {
        return activeEncounters[0].simpleRegExMatch("\\w\\w\\w \\d\\d, \\d\\d\\d\\d - \\d\\d:\\d\\d \\w\\w")
    } else {
        return "Next apt not found"
    }
}
    


