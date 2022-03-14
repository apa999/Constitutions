//
//  CalAttributableString.swift
//  StandardLists1
//
//  Created by Anthony Abbott on 10/03/2022.
//

import UIKit

/// Converts a CalPage into a mutable string for display
class CalAttributableString: NSMutableAttributedString {
  
  static func calPageAsAttributedString(calPage: CalPage, textView: UITextView? = nil) -> NSMutableAttributedString {
    let pageAsAttributedString = NSMutableAttributedString()
    
    for pageText in calPage.pageText {
      var font = UIFont()
      
      let text             = pageText.Text
      let alignment        = pageText.getAlignment(AlignmentAsString: pageText.Alignment)
      let backgroundColour = pageText.getBackgroundColour(backgroundColourAsString: pageText.BackgroundColour)
      let foregroundColour = pageText.getForegroundColour(foregroundColourAsString: pageText.ForegroundColour)
      let fontSize         = CGFloat(pageText.FontSize)
      let fontWeight       = pageText.getFontWeight(FontWeightAsString: pageText.FontWeight)
      let newLines         = pageText.NewLines
      let underlined       = pageText.Underlined
      
      let paragraphStyle       = NSMutableParagraphStyle()
      paragraphStyle.alignment = alignment
      
      switch pageText.FontType {
      case CalTextType.System.rawValue           : font = UIFont.systemFont(ofSize: fontSize, weight:fontWeight)
      case CalTextType.Italics.rawValue          :
        font = fontWeight == .bold ? UIFont.italicSystemFont(ofSize: fontSize).with(traits: [ .traitBold, .traitItalic ])
                                   : UIFont.italicSystemFont(ofSize: fontSize)
        
      case CalTextType.MonoSpaceRegular.rawValue : font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
      case CalTextType.MonoSpaceBold.rawValue    : font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: fontWeight)
      default                                    : font = UIFont.systemFont(ofSize: fontSize, weight:fontWeight)
      }
      
      // Process Links
      if pageText.Link != "" {
        let link  = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: text.count)
        
        link.addAttribute(NSAttributedString.Key.link,            value: pageText.Link, range: range)
        link.addAttribute(NSAttributedString.Key.font,            value: font, range: range)
        link.addAttribute(NSAttributedString.Key.backgroundColor, value: backgroundColour, range: range)
      
        if underlined == true {
          let textRange = NSMakeRange(0, text.count)
          link.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        }
        
        pageAsAttributedString.append(link)
      }
        
      // Internal link
      else if pageText.InternalLink != ""{
        let iLink = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: text.count)
        
        iLink.addAttribute(NSAttributedString.Key.link,            value: pageText.InternalLink, range: range)
        iLink.addAttribute(NSAttributedString.Key.font,            value: font, range: range)
        iLink.addAttribute(NSAttributedString.Key.backgroundColor, value: backgroundColour, range: range)
        
        if underlined == true {
          let textRange = NSMakeRange(0, text.count)
          iLink.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        }
        
        pageAsAttributedString.append(iLink)
      }
        
      // Email
      else if pageText.Email != "" {
        let email = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: text.count - pageText.NewLines)
        
        email.addAttribute(NSAttributedString.Key.link,            value: "Email|\(pageText.Email)|\(text)", range: range)
        email.addAttribute(NSAttributedString.Key.font,            value: font, range: range)
        email.addAttribute(NSAttributedString.Key.backgroundColor, value: backgroundColour, range: range)
        
        pageAsAttributedString.append(email)
      }
      
      else if pageText.Image != "" {
        if let image = UIImage(named: pageText.Image), let textView = textView {
          let textAttachment    = NSTextAttachment()
          textAttachment.image = image
    
          let oldWidth    = textAttachment.image!.size.width;
          let scaleFactor = oldWidth / (textView.frame.size.width - 10);
          textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
         
        
          let attrStringWithImage = NSAttributedString(attachment: textAttachment)
          
          pageAsAttributedString.append(attrStringWithImage)
        }
      }
        
      // Normal line
      else {
        let attrs:[NSAttributedString.Key:AnyObject] = [
          NSAttributedString.Key.backgroundColor : backgroundColour,
          NSAttributedString.Key.font            : font,
          NSAttributedString.Key.foregroundColor : foregroundColour,
          NSAttributedString.Key.paragraphStyle  : paragraphStyle
        ]
        
        let regular =  NSMutableAttributedString(string: text, attributes:attrs)
        
        if underlined == true {
          let textRange = NSMakeRange(0, text.count)
          regular.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        }
        
        pageAsAttributedString.append(regular)
      }
      
      for _ in 0..<newLines {
        pageAsAttributedString.append(NSAttributedString(string: "\n"))
      }
    }

    return pageAsAttributedString
  }
}

extension NSMutableAttributedString
{
  /// Used to allow adjustsFontForContentSizeCategory to work
  public func setFont(_ font: UIFont) -> NSMutableAttributedString {
    addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: string.count))
    
    return self
  }
}

extension UIFont {
  var bold: UIFont {
    return with(traits: .traitBold)
  } // bold
  
  var italic: UIFont {
    return with(traits: .traitItalic)
  } // italic
  
  var boldItalic: UIFont {
    return with(traits: [.traitBold, .traitItalic])
  } // boldItalic
  
  func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
    guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else
    {
      return self
    } // guard
    
    return UIFont(descriptor: descriptor, size: 0)
  }
}
