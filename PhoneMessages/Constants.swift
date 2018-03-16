//
//  Constants.swift
//  PTVN Builder
//
//  Created by Fool on 2/1/16.
//  Copyright © 2016 Fulgent Wake. All rights reserved.
//

import Foundation

let dxBadBits = ["Chronic diagnoses\n", "No active Acute diagnoses.\n", "Acute diagnoses\n", "Diagnoses", "Social history", "Term\n", "Show by", "ICD-10"]

let medBadBits = ["Medications", "Encounters", " Show historical"]

let nutritionBadBits = ["Nutrition history\n", "Advanced directives", "Developmental history/n"]

let socialBadBits = ["Past medical history", "Social history (free text) \n", "Social history \n", "Smoking status \n", "Gender identity \n", "No gender identity recorded\n", "Sexual orientation \n", "No sexual orientation recorded\n"]

let fmhBadBits = ["Family health history\n", "Preventive care", "Social history"]

let basicAllergyBadBits = ["Drug allergies\n", "Environmental allergies\n", "No environmental allergies recorded\n", "Food allergies\n", "Allergies\n", "Medications", "You have previously recorded allergies in a free-text note", "To receive interaction alerts, record the note in a structured format here. Record",  "(free-text note) Delete"]

let freeAllergyBadBits = ["Allergies (free text)\n", "ALLERGIES:", "ALLERGIES", "Use structured allergies to receive interaction alerts\n", "Food allergies:", "Food Allergies:", "Food Allergies", "Food allergies\n", "Food Allergies\n", "Environmental allergies:\n", "Environmental allergies: ", "Environmental allergies\n", "Environmental Allergies\n", "Drug allergies:", "Drug allergies-", "Drug allergies", "No Known Drug Allergies", "No Known", "Drug Allergies:", "Drug Allergies", "Family health history", "Preventive care", "No food allergies recorded\n", "Allergies\n"]

let preventiveBadBits = ["Preventive care\n", "Social history", "Advance directives"]

let pshBadBits = ["Major events\n", "Ongoing medical problems", "PSH:\n", "PHS:\n"]

let pmhBadBits = ["Ongoing medical problems\n", "Allergies (free text)", "Allergies\n", "PMH:\n", "PHM:\n", "Preventive care", "Family health history"]

let visitBoilerplateText = "CC:  \nProblems:  \n\n\nS:  \n\nLocation:  \nSeverity:  \nQuality:  \nDuration:  \nTiming:  \nContext:  \nModifying factors:  \nAssociated symptoms:  \n\n\nNEW PMH:  \n\n\nA(Charge):  \n\n\nP(lan):  \n\n**Rx**  \n\n\nO(PE):  \n\n\n"

let medKey = "(- = currently taking; x = not currently taking; ? = unsure)\n"

let mucusColor = ["", "Clear", "White", "Yellow", "Green", "Brown", "Bloody"]

let pharmacies = ["", "Krogers", "Matthewsons", "Walgreens", "Super1", "Walmart", "CVS", "Killions", "Humana", "Express Scripts", "Optum Rx", "Walmart (Carthage)", "Super1 (Tyler)", "Krogers (Longview)", "City Drug", "Well Dynamix", "Davita Rx", "Walmart (4th St.)", "Written script"]
let resultsList = ["", "XRAY", "MRI", "CT", "Ultrasound","Labs", "Referral"]
