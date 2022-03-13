//
//  Parser.swift
//  StandardDocument
//
//  Created by Anthony Abbott on 28/02/2022.
//

import Foundation

class CalParser : NSObject, XMLParserDelegate {
  private var calDocument           : CalDocument!
  private var collectedString       = ""
  private var pages                 = [CalPage]()
  private var currentPage           : CalPage?
  private var pageText              = [CalText]()
  private var newEntryID            = -1
  private var newContentTitle       = ""
  private var documentTitle         = ""
  
  // Private vars for Contents details
  private var number                = ""
  private var title                 = ""
  private var subTitle              = ""
  private var reference             = ""
  
  // Text attributes
  private var Alignment             = ""
  private var BackgroundColour      = ""
  private var Email                 = ""
  private var FontSize              = CalTextDefaults.DefaultFontSize
  private var FontType              = ""
  private var FontWeight            = ""
  private var ForegroundColour      = ""
  private var Image                 = ""
  private var InternalLink          = ""
  private var Link                  = ""
  private var NewLines              = CalTextDefaults.DefaultNewLines
  private var Title                 = ""
  private var Underlined            = false
  private var User0                 = ""
  private var User1                 = ""
  private var User2                 = ""
  private var User3                 = ""
  
  //MARK: - Init
  init(calDocument : CalDocument) {
    self.calDocument = calDocument
  }
  
  //MARK: - Public
  /// Returns true if the file is found and parsed without errors
  func parse(filePath: String)-> Bool {
    var parsedOK = true
    
    if let parser  = XMLParser(contentsOf: URL(fileURLWithPath: filePath)) {
      parser.delegate = self
      parser.parse()
    } else {
      parsedOK = false
      NSLog("Failed to find or open document file with path: \(filePath)")
    }
    
    return parsedOK
  }
  
  func parserDidEndDocument(_ parser: XMLParser) {
  }
  
  //MARK: - NSXMLParser delegate methods
  func parser(_ parser: XMLParser,
              didStartElement elementName: String,
              namespaceURI: String?,
              qualifiedName qName: String?,
              attributes attributeDict: [String : String]) {
    var calContentEntryType : CalEntry.EntryType?
    
    switch elementName {
      case CalDocumentFields.H0: parseTitleAttributes(attributes: attributeDict)
        calDocument.set(title: documentTitle)
        
      case CalDocumentFields.H1  : calContentEntryType = .H1
      case CalDocumentFields.H2  : calContentEntryType = .H2
      case CalDocumentFields.H3  : calContentEntryType = .H3
      case CalDocumentFields.H4  : calContentEntryType = .H4
      case CalDocumentFields.H5  : calContentEntryType = .H5
      case CalDocumentFields.H6  : calContentEntryType = .H6
        
      case CalDocumentFields.PG: Title = ""
        parseTextAttributes(attributes: attributeDict)
      case CalDocumentFields.TX: parseTextAttributes(attributes: attributeDict)
        
      default: NSLog("Unrecognised CalContentEntryFields: \(elementName)")
    }
    
    if let dht = calContentEntryType {
      parseContentAttributes(attributes: attributeDict)
      
      newEntryID = calDocument.addHeader(entryType: dht,
                                                number: number,
                                                title: title,
                                                subTitle: subTitle,
                                                reference: reference)
      newContentTitle   = title
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if (elementName as NSString).isEqual(to: CalDocumentFields.TX) {
      let calText = CalText(Text             : collectedString,
                            Alignment        : Alignment,
                            BackgroundColour : BackgroundColour,
                            Email            : Email,
                            FontSize         : FontSize,
                            FontType         : FontType,
                            FontWeight       : FontWeight,
                            ForegroundColour : ForegroundColour,
                            Image            : Image,
                            InternalLink     : InternalLink,
                            Link             : Link,
                            NewLines         : NewLines,
                            Underlined       : Underlined,
                            User0            : User0,
                            User1            : User1,
                            User2            : User2,
                            User3            : User3
      )
      
      pageText.append(calText)
      
      resetAttributes()
    }
    
    else if elementName ==  CalDocumentFields.PG {
      Title = Title == "" ? newContentTitle : Title // If the page has its own title use that, otherwise use the content entry's title
      
      let newPage = CalPage(pageText: pageText, entryID: newEntryID, pageTitle: Title)
      
      calDocument.add(page: newPage)
      
      pageText.removeAll()
    }
    
    collectedString = ""
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    let  fs = string.replacingOccurrences(of: "\n", with: "",  options: NSString.CompareOptions.literal, range: nil)
    
    if fs.count == (string).count {
      collectedString += string
    }
  }
  
  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print(parseError)
  }
  
  
  //MARK:- Private functions
  private func parseContentAttributes(attributes attributeDict: [String : String]) {
    for key in attributeDict.keys {
      switch key {
        case CalDocumentFields.Number   : number    = (attributeDict[key] as String?)!
        case CalDocumentFields.Title    : title     = (attributeDict[key] as String?)!
        case CalDocumentFields.SubTitle : subTitle  = (attributeDict[key] as String?)!
        case CalDocumentFields.Reference: reference = (attributeDict[key] as String?)!
        
        case CalDocumentFields.Filename : break
        case CalDocumentFields.URL      : break
        case CalDocumentFields.Code     : break
          
        default: NSLog("Unrecognised attributes key: \(key)")
      }
    }
  }
  
  private func parseTextAttributes(attributes attributeDict: [String : String])
  {
    let attrs = attributeDict as [String: NSString]
    
    if let prop = attrs[CalDocumentFields.Alignment]{
      Alignment = (prop as String?)!
    }
    
    if let prop = attrs[CalDocumentFields.BackgroundColour]{
      BackgroundColour = prop as String
    }
    
    if let prop = attrs[CalDocumentFields.Email]{
      Email = prop as String
    }
    
    if let prop = attrs[CalDocumentFields.FontSize]{
      FontSize = Double(prop as String)!
    }
    
    if let prop = attrs[CalDocumentFields.FontType]{
      FontType = (prop as String?)!
    }
    
    if let prop = attrs[CalDocumentFields.FontWeight]{
      FontWeight = (prop as String?)!
    }
    
    if let prop = attrs[CalDocumentFields.ForegroundColour]{
      ForegroundColour = (prop as String?)!
    }
    
    if let prop = attrs[CalDocumentFields.Image]{
      Image = (prop as String?)!
    }
    
    if let prop = attrs[CalDocumentFields.InternalLink]{
      InternalLink = (prop as String?)!
    }
    
    if let prop = attrs[CalDocumentFields.Link]{
      Link = (prop as String?)!
    }
    
    if let prop = attrs[CalDocumentFields.NewLines]{
      NewLines = Int(prop as String)!
    }
    
    if let prop = attrs[CalDocumentFields.Title]{
      Title = (prop as String?)!
    }
    
    if let prop = attrs[CalDocumentFields.Underlined]{
      Underlined = Bool(prop as String)!
    }
  }
  
  private func parseTitleAttributes(attributes attributeDict: [String : String]){
    let attrs = attributeDict as [String: NSString]
    
    if let prop = attrs[CalDocumentFields.Title]{
      documentTitle = (prop as String?)!
    }
  }
  
  //MARK: - Private
  private func resetAttributes() {
    Alignment           = CalTextDefaults.DefaultAlignment
    BackgroundColour    = ""
    Email               = ""
    FontSize            = CalTextDefaults.DefaultFontSize
    FontType            = CalTextDefaults.DefaultFontType
    FontWeight          = CalTextDefaults.DefaultFontWeight
    ForegroundColour    = ""
    Image               = ""
    InternalLink        = ""
    Link                = ""
    NewLines            = CalTextDefaults.DefaultNewLines
    Underlined          = false
    User0               = ""
    User1               = ""
    User2               = ""
    User3               = ""
  }
}
