//
//  Character+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 19/02/2025.
//


extension Character {
    /// Returns whether the character is an emoji
    ///
    /// An emoji can either be a 2 byte unicode character or a normal UTF8 character with an emoji modifier appended as is the case with 3️⃣
    ///
    /// 0x238C is the first instance of UTF16 emoji that requires no modifier.
    /// `isEmoji` on the `UnicodeScalar` will evaluate to `true` for any character that can be turned into an emoji by adding a modifier such as the digit "3".
    /// To avoid this we confirm that any character below `0x238C` has an emoji modifier attached
    ///
    ///
    /// This code snippet is taken from [StackOverflow](https://stackoverflow.com/a/39425959/3825788) and modified to suit the needs.
    /// Also, [Understanding Swift Strings](https://betterprogramming.pub/understanding-swift-strings-characters-and-scalars-a4b82f2d8fde) has been referred
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238c || unicodeScalars.count > 1)
    }
}
