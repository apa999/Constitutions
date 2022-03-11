//
//  CalText.swift
//  StandardDocument
//
//  Created by Anthony Abbott on 28/02/2022.
//

import UIKit


let DefaultFontSize = 20.0
let DefaultNewLines = 2

// MARK:- Default attributes
struct CalTextDefaults {
  static let DefaultFontSize         = 20.0
  static let DefaultNewLines         = 2
  static let DefaultUnderlined       = false
  static let DefaultBackgroundColour = "Clear"
  static let DefaultForegroundColour = "NHSBlue"
  static let DefaultFontWeight       = "Regular"
  static let DefaultFontType         = "System"
  static let DefaultAlignment        = "Justified"
  static let DefaultLink             = ""
}


enum CalTextType : String {
  case System           = "system"
  case Italics          = "italics"
  case MonoSpaceBold    = "monoppacebold"
  case MonoSpaceRegular = "monospaceregular"
}

class CalText: CustomStringConvertible {
  var description: String {
    var s = ""
    
    s    += "Text                : \(Text)\n"
    s    += "Alignment           : \(Alignment)\n"
    s    += "BackgroundColour    : \(BackgroundColour)\n"
    s    += "FontSize            : \(FontSize)\n"
    s    += "FontType            : \(FontType)\n"
    s    += "FontWeight          : \(FontWeight)\n"
    s    += "ForegroundColour    : \(ForegroundColour)\n"
    s    += "Image               : \(Image)\n"
    s    += "InternalLink        : \(InternalLink)\n"
    s    += "Link                : \(Link)\n"
    s    += "NewLines            : \(NewLines)\n"
    s    += "Underlined          : \(Underlined)\n"
    s    += "Email               : \(Email)\n"
    s    += "User0               : \(User0)\n"
    s    += "User1               : \(User1)\n"
    s    += "User2               : \(User2)\n"
    s    += "User3               : \(User3)\n"
    
    return s
  }
  
  var Alignment          : String          // e.g. left, right, center, justified...
  var BackgroundColour   : String
  var Email              : String
  var FontSize           : Double
  var FontType           : String
  var FontWeight         : String          // e.g. regular, semibold...
  var ForegroundColour   : String
  var Image              : String
  var InternalLink       : String
  var Link               : String
  var Text               : String
  var NewLines           : Int
  var Underlined         : Bool
  var User0              : String
  var User1              : String
  var User2              : String
  var User3              : String
  
  
  init() {
    Text                 = ""
    Alignment            = CalTextDefaults.DefaultAlignment
    BackgroundColour     = CalTextDefaults.DefaultBackgroundColour
    Email                = ""
    FontSize             = CalTextDefaults.DefaultFontSize
    FontType             = CalTextDefaults.DefaultFontType
    FontWeight           = CalTextDefaults.DefaultFontWeight
    ForegroundColour     = CalTextDefaults.DefaultForegroundColour
    Image                = ""
    InternalLink         = ""
    Link                 = CalTextDefaults.DefaultLink
    NewLines             = CalTextDefaults.DefaultNewLines
    Underlined           = false
    User0                = ""
    User1                = ""
    User2                = ""
    User3                = ""
  }
  
  init(Text             : String?  = "",
       Alignment        : String?  = CalTextDefaults.DefaultAlignment,
       BackgroundColour : String?  = "",
       Email            : String?  = "",
       FontSize         : Double?  = CalTextDefaults.DefaultFontSize,
       FontType         : String?  = CalTextDefaults.DefaultFontType,
       FontWeight       : String?  = CalTextDefaults.DefaultFontWeight,
       ForegroundColour : String?  = "",
       Image            : String?  = "",
       InternalLink     : String?  = "",
       Link             : String?  = CalTextDefaults.DefaultLink,
       NewLines         : Int?     = CalTextDefaults.DefaultNewLines,
       Underlined       : Bool?    = CalTextDefaults.DefaultUnderlined,
       User0            : String?  = "",
       User1            : String?  = "",
       User2            : String?  = "",
       User3            : String?  = ""
    ) {
    self.Alignment        = Alignment!
    self.BackgroundColour = BackgroundColour!
    self.Text             = Text!
    self.Email            = Email!
    self.FontSize         = FontSize!
    self.FontWeight       = FontWeight!
    self.ForegroundColour = ForegroundColour!
    self.NewLines         = NewLines!
    self.Underlined       = Underlined!
    self.FontType         = FontType!.lowercased()
    self.Image            = Image!
    self.InternalLink     = InternalLink!
    self.Link             = Link!
    self.User0            = User0!
    self.User1            = User1!
    self.User2            = User2!
    self.User3            = User3!
  }
}

extension CalText {
  func getAlignment(AlignmentAsString: String) -> NSTextAlignment {
    var alignment : NSTextAlignment?
    
    switch AlignmentAsString.lowercased() {
    case "justified" : alignment = NSTextAlignment.justified
    case "center"    : alignment = NSTextAlignment.center
    case "left"      : alignment = NSTextAlignment.left
    case "right"     : alignment = NSTextAlignment.right
    case "natural"   : alignment = NSTextAlignment.natural
    default          : alignment = NSTextAlignment.justified
    }
    
    return alignment!
  }
  
  func getBackgroundColour(backgroundColourAsString: String) -> UIColor {
    var backgroundColour : UIColor?
    
    switch backgroundColourAsString.lowercased() {
    case "black":          backgroundColour = UIColor.black
    case "blue":           backgroundColour = UIColor.blue
    case "brown":          backgroundColour = UIColor.brown
    case "clear":          backgroundColour = UIColor.clear
    case "cyan":           backgroundColour = UIColor.cyan
    case "darkGray":       backgroundColour = UIColor.darkGray
    case "darkText":       backgroundColour = UIColor.darkText
    case "gray":           backgroundColour = UIColor.gray
    case "green":          backgroundColour = UIColor.green
    case "lightGray":      backgroundColour = UIColor.lightGray
    case "lightText":      backgroundColour = UIColor.lightText
    case "magenta":        backgroundColour = UIColor.magenta
    case "orange":         backgroundColour = UIColor.orange
    case "purple":         backgroundColour = UIColor.purple
    case "red":            backgroundColour = UIColor.red
    case "white":          backgroundColour = UIColor.white
    case "yellow":         backgroundColour = UIColor.yellow
    case "appendixamber":  backgroundColour = UIColor.init(netHex: AppendixAmber)
    case "appendixred":    backgroundColour = UIColor.init(netHex: AppendixRed)
    case "appendixgreen":  backgroundColour = UIColor.init(netHex: AppendixGreen)
    case "scheduleorange": backgroundColour = UIColor.init(netHex: ScheduleOrange)
    case "NHSGray":        backgroundColour = UIColor.init(netHex: NHSGray)
    default:               backgroundColour = UIColor.clear
    }
    
    return backgroundColour!
  }
  
  func getForegroundColour(foregroundColourAsString: String) -> UIColor {
    var foregroundColour : UIColor?
    
    switch foregroundColourAsString.lowercased() {
    case "black":     foregroundColour = UIColor.black
    case "blue":      foregroundColour = UIColor.blue
    case "brown":     foregroundColour = UIColor.brown
    case "clear":     foregroundColour = UIColor.clear
    case "cyan":      foregroundColour = UIColor.cyan
    case "darkGray":  foregroundColour = UIColor.darkGray
    case "darkText":  foregroundColour = UIColor.darkText
    case "gray":      foregroundColour = UIColor.gray
    case "green":     foregroundColour = UIColor.green
    case "lightGray": foregroundColour = UIColor.lightGray
    case "lightText": foregroundColour = UIColor.lightText
    case "magenta":   foregroundColour = UIColor.magenta
    case "orange":    foregroundColour = UIColor.orange
    case "purple":    foregroundColour = UIColor.purple
    case "red":       foregroundColour = UIColor.red
    case "white":     foregroundColour = UIColor.white
    case "yellow":    foregroundColour = UIColor.yellow
    default:          foregroundColour = UIColor.systemBlue
    }
    
    return foregroundColour!
  }
  
  /// Returns the FontWeightAsString expressed as UIFont.Weight
  func getFontWeight(FontWeightAsString: String) -> UIFont.Weight {
    var fontWeight : UIFont.Weight?
    
    switch FontWeightAsString.lowercased() {
    case "ultralight" : fontWeight = UIFont.Weight.ultraLight
    case "thin"       : fontWeight = UIFont.Weight.thin
    case "light"      : fontWeight = UIFont.Weight.light
    case "regular"    : fontWeight = UIFont.Weight.regular
    case "medium"     : fontWeight = UIFont.Weight.medium
    case "semibold"   : fontWeight = UIFont.Weight.semibold
    case "bold"       : fontWeight = UIFont.Weight.bold
    case "heavy"      : fontWeight = UIFont.Weight.heavy
    default           : fontWeight = UIFont.Weight.regular
    }
    
    return fontWeight!
  }
}


// MARK: - Colour
let NHSBlue        = 0x0072C6
let Silver         = 0xCCCCCC
let Magnesium      = 0xB3B3B3
let AppendixAmber  = 0xFDBF2D
let AppendixGreen  = 0x94CE58
let AppendixRed    = 0xFC0D1B
let ScheduleOrange = 0xE16C22
let CaseStudyBlue  = 0x8AFFEC
let NHSGray        = 0xE5E5E5


// MHCB Colours
let F312           = 0xE26C22
let F311           = 0xF9C02F
let F310           = 0xFBD5B7
let F317           = 0xBFBFBF
let F313           = 0xBACDE4
let F314           = 0x96B4D5
let F315           = 0x396190
let F316           = 0x23C411


func != (lhs: (Int, Int), rhs: (Int, Int)) -> Bool {
  return lhs.0 != rhs.0 && rhs.1 != lhs.1
}

//MARK:- Extensions
extension UIColor {
  convenience init(red: Int, green: Int, blue: Int) {
    assert(red   >= 0 && red   <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue  >= 0 && blue  <= 255, "Invalid blue component")
    
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }
  
  convenience init(netHex:Int) {
    self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
  }
}
