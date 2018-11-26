//
//  ThirdCustom.swift
//  CustomCheckboxExample
//
//  Created by Fool on 10/22/15.
//  Copyright © 2015 Fulgent Wake. All rights reserved.
//

import Cocoa
import QuartzCore

//Creates a circular checkbox button that is white when OFF, red when ON, and green when MIXED.
//The checkbox button cell needs to be set to this class rather than the button itself.
//To keep the top of the circle from clipping the heigth of the
//controller needs to be set to at least 20 (the default in IB is 19)
@IBDesignable
class RedGreenCheckbox: NSButtonCell {
	@IBInspectable
	var onStateColor: NSColor = NSColor.green
	@IBInspectable
	var offStateColor: NSColor = NSColor.white
	@IBInspectable
	var mixedStateColor: NSColor = NSColor.red
	
	override func drawImage(_ image: NSImage, withFrame frame: NSRect, in controlView: NSView) {
		
		let path = NSBezierPath(ovalIn: frame)
		//let path2 = NSBezierPath(roundedRect: frame, xRadius: 0.7, yRadius: 0.7)
		
		NSColor.black.setFill()
		//NSRectFill(frame)
		path.fill()
		
		let insetRect = NSInsetRect(frame, 0.5, 0.5)
		let insetPath = NSBezierPath(ovalIn: insetRect)
		//NSColor.white.setFill()
		//NSRectFill(NSInsetRect(frame, 1, 1))
		
		if self.allowsMixedState {
			if self.state == .on {
				//NSColor.greenColor().setFill()
				onStateColor.setFill()
			} else if self.state == .off {
				//NSColor.whiteColor().setFill()
				offStateColor.setFill()
			} else if self.state == .mixed {
				//NSColor.redColor().setFill()
				mixedStateColor.setFill()
			}
		} else {
			if self.state == .on {
				mixedStateColor.setFill()
			} else if self.state == .off {
				//NSColor.whiteColor().setFill()
				offStateColor.setFill()
				
			}
		}
		
		insetPath.fill()
		//NSRectFill(NSInsetRect(frame, 4, 4))
		
	}
    
    override func prepareForInterfaceBuilder() {
        
    }
}


@IBDesignable class coloredButton: NSButton {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    @IBInspectable var buttonColor:NSColor = NSColor.purple {
        didSet {
            sharedInit()
        }
    }
    
//    func refreshColor(_ color:CGColor) {
//
//    }
    
    func sharedInit() {
        //(self.cell as? NSButtonCell)?.isBordered = false
        //(self.cell as? NSButtonCell)?.backgroundColor = buttonColor
        
    }
}

