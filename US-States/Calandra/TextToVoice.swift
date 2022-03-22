//
//  TextToVoice.swift
//  Constitutions
//
//  Created by Anthony Abbott on 22/03/2022.
//

import Foundation
import AVFoundation

class TextToVoice
{
  static let synthesizer = AVSpeechSynthesizer()

  // Speak if we're not already speaking, otherwise stop
  static func speak(text: String) {
    
    if synthesizer.isSpeaking{
      synthesizer.stopSpeaking(at: .word)
    } else {
      let utterance   = AVSpeechUtterance(string: text)
      let language    = AVSpeechSynthesisVoice.currentLanguageCode()
      utterance.voice = AVSpeechSynthesisVoice(language: language)
      utterance.rate  = 0.5

      synthesizer.speak(utterance)
    }
  }
  
  static func stopSpeaking() {
    if synthesizer.isSpeaking{
      synthesizer.stopSpeaking(at: .word)
    }
  }
}
