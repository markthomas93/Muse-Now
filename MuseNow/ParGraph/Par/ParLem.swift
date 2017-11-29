//
//  ParObj.swift
//  ParGraph
//
//  Created by warren on 7/30/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation


@available(iOS 11,*)
@available(watchOS 4,*)

class ParLem:ParWords {

    fileprivate var wordSets = [String: Set<String>]()
    fileprivate var languages = [String: String]()

    convenience init(_ str_: String) {

        self.init(str_)
    }

    #if false
    /// Takes a string and produces a set of word forms from it, including all of the words of the text and their lemmas.
    /// - Tag: setOfWords
    fileprivate func setOfWords(string: String, language: inout String?) -> Set<String> {
        var wordSet = Set<String>()
        let tagger = NSLinguisticTagger(tagSchemes: [.lemma, .language], options: 0)
        let range = NSRange(location: 0, length: string.utf16.count)

        tagger.string = string
        if let language = language {
            // If language has a value, it is taken as a specification for the language of the text and set on the tagger.
            let orthography = NSOrthography.defaultOrthography(forLanguage: language)
            tagger.setOrthography(orthography, range: range)
        } else {
            // If language is nil, then the tagger sets it based on automatic identification of the language of the string.
            language = tagger.dominantLanguage
        }

        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: [.omitPunctuation, .omitWhitespace]) { tag, tokenRange, _ in
            let token = (string as NSString).substring(with: tokenRange)
            // Each word of the text is inserted into the result set (in lowercase form).
            wordSet.insert(token.lowercased())
            if let lemma = tag?.rawValue {
                // If there is a lemma, it is also inserted into the result set (in lowercase form).
                wordSet.insert(lemma.lowercased())
            }
        }
        return wordSet
    }
#endif

}

