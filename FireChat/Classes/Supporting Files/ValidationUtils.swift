//
//  ValidationUtils.swift
//  FireChat
//
//  Created by Nirzar Gandhi on 08/10/25.
//

import Foundation

public struct ValidationUtils {
    
    /// Method to validate if the given email Input String is in valid Email format.
    ///
    /// - parameter emailInputString: Email Input String.
    ///
    /// - returns: Whether the Email String is valid or not.
    public static func isValidEmail(_ emailInputString: String) -> Bool {
        
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: emailInputString)
    }
    
    /// Method to validate if the Password String is Valid or not.
    /// Minimum 8 and Maximum  characters at least 1 Alphabet, 1 Number and 1 Special Character
    /// - parameter inputString: Input String to be Validated.
    ///
    /// - returns: Returns a bool indicating whether the field was empty or not.
    public static func isValidPassword(_ inputString: String) -> Bool {
        
        let regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: inputString)
    }
}
