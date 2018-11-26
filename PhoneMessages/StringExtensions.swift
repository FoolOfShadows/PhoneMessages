//
//  StringExtensions.swift
//  PTVN to PF 2
//
//  Created by Fool on 1/10/17.
//  Copyright © 2017 Fulgent Wake. All rights reserved.
//

import Cocoa

extension String {
	func findRegexMatchFrom(_ start: String, to end:String) -> String? {
		if self.contains(start) && self.contains(end) {
			guard let startRegex = try? NSRegularExpression(pattern: start, options: []) else { return nil }
			guard let endRegex = try? NSRegularExpression(pattern: end, options: []) else {return nil }
			let startMatch = startRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
			let endMatch = endRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
			
			let startRange = startMatch[0].range
			let endRange = endMatch[0].range
			
			let r = self.index(self.startIndex, offsetBy: startRange.location) ..< self.index(self.startIndex, offsetBy: endRange.location + endRange.length)
            
			return String(self[r])
		} else {
			return ""
		}
	}
	
	
	func findRegexMatchBetween(_ start: String, and end: String) -> String? {
        let startStripped = start.removeRegexCharactersFromString()
        let endStripped = end.removeRegexCharactersFromString()
        //print("Stripped start is: \(startStripped)\nand stripped end is: \(endStripped)")
        if self.contains(startStripped) && self.contains(endStripped) {
            //print("Starting text: \(start), Ending text: \(end)")
            guard let startRegex = try? NSRegularExpression(pattern: start, options: []) else { return nil }
            guard let endRegex = try? NSRegularExpression(pattern: end, options: []) else {return nil }
            
            let startMatch = startRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            let endMatch = endRegex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            
            let startRange = startMatch[0].range
            let endRange = endMatch[0].range
            
            //print("Start range is \(startRange.location), and the end range is \(endRange.location)")
            
            if startRange.location > endRange.location {
                return "Range for this section is out of bounds"
            } else {
                let r = self.index(self.startIndex, offsetBy: startRange.location + startRange.length) ..< self.index(self.startIndex, offsetBy: endRange.location)
                
                return String(self[r])
            }
        } else {
            return ""
        }
	}
    
    //A basic regular expression search function
    func simpleRegExMatch(_ theExpression: String) -> String {
        var theResult = ""
        let regEx = try! NSRegularExpression(pattern: theExpression, options: [.anchorsMatchLines])
        let length = self.count
        
        if let match = regEx.firstMatch(in: self, options: [], range: NSRange(location: 0, length: length)) {
            theResult = (self as NSString).substring(with: match.range)
        }
        return theResult
    }
	
	
    func removeWhiteSpace() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func replaceRegexPattern(_ pattern:String, with goodBit:String) -> String {
        let regex = try? NSRegularExpression(pattern: pattern)
        if let results = regex?.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0,length: self.count), withTemplate: goodBit) {
            return results
        }
        
        return ""
    }
    
    //Clean extraneous text from the sections
    func cleanTheTextOf(_ badBits:[String]) -> String {
        var cleanedText = self.removeWhiteSpace()
        for theBit in badBits {
            //cleanedText = cleanedText.replacingOccurrences(of: theBit, with: "")
            cleanedText = cleanedText.replacingOccurrences(of: theBit, with: "", options: .regularExpression, range: nil)
        }
        let cleanedArray = cleanedText.components(separatedBy: "\n").filter {!$0.allRegexMatchesFor("[a-zA-Z0-9]").isEmpty}
        //let cleanedArray = cleanedText.components(separatedBy: "\n").filter {!$0.ranges(of: "[a-zA-Z0-9]", options: .regularExpression).isEmpty}
        cleanedText = cleanedArray.joined(separator: "\n").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return cleanedText
    }
    
    func convertListToArray() -> [String] {
        let baseArray = self.components(separatedBy: "\n")
        //let newArray = baseArray.map { $0.cleanTheTextOf(["-  "]) }
        return baseArray
    }
	
	func removeRegexCharactersFromString() -> String {
		let regexCharacters:Set<Character> = Set("\\*")
		return String(self.filter({ !regexCharacters.contains($0) }))
	}
	
	func prependSectionHeader(_ header:String) -> String {
		if !self.isEmpty {
			return "\(header):\n\(self)"
		}
		return self
	}
	
	func prependLineHeader(_ header:String) -> String {
		if !self.isEmpty {
			return "\(header):  \(self)"
		}
		return self
	}
    
    func addCharacterToBeginningOfEachLine(_ theCharacter:String) -> String {
        var newTextArray = [String]()
        let textArray = self.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty}
        for line in textArray {
            newTextArray.append("\(theCharacter) \(line)")
        }
        
        return newTextArray.joined(separator: "\n")
    }
	
	func copyToPasteboard() {
		let myPasteboard = NSPasteboard.general
		myPasteboard.clearContents()
		myPasteboard.setString(self, forType: NSPasteboard.PasteboardType.string)
	}
    
    //This method returns an array of all substrings in a string which match the regex passed in
    func allRegexMatchesFor(_ regex: String) -> [String] {
        //If the string passed in can't be converted to a regex, return an empty array
        guard let regex = try? NSRegularExpression(pattern: regex) else { return [] }
        //Get an array textcheckingresults (ranges) of matches for the regex in the
        //calling string
        let results = regex.matches(in: self,
                                    range: NSRange(self.startIndex..., in: self))
        //Convert the textcheckingresults into an array of strings using map()
        //and return the results
        return results.map { (self as NSString).substring(with: $0.range) }
    }
    
    //A cribbed extension allowing for the extraction of blocks of text.  I don't yet understand how it works.
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    
    func toDate(withFormat format:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        return dateFormatter.date(from: self)!
    }
}


