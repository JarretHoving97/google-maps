//
//  Binding+Value+Extension.swift
//  Amigos Chat Package
//
//  Created by Jarret on 18/02/2025.
//

import SwiftUI

extension Binding where Value == Any? {

    var toBoolBinding: Binding<Bool> {
        Binding<Bool>.init {
            self.wrappedValue != nil
        } set: { value in
            if !value {
                self.wrappedValue = nil
            }
        }
    }
}

extension Binding where Value == Int? {

    var toBoolBinding: Binding<Bool> {
        Binding<Bool>.init {
            self.wrappedValue != nil
        } set: { value in
            if !value {
                self.wrappedValue = nil
            }
        }
    }
}

extension Binding where Value == MediaAttachment? {

    var toBoolBinding: Binding<Bool> {
        Binding<Bool>.init {
            self.wrappedValue != nil
        } set: { value in
            if !value {
                self.wrappedValue = nil
            }
        }
    }
}

extension Binding where Value == URL? {

    var toBoolBinding: Binding<Bool> {
        Binding<Bool>.init {
            self.wrappedValue != nil
        } set: { value in
            if !value {
                self.wrappedValue = nil
            }
        }
    }
}

extension Binding where Value == SingleAttachmentType? {
    var toBoolBinding: Binding<Bool> {
        Binding<Bool>.init {
            self.wrappedValue != nil
        } set: { value in
            if !value {
                self.wrappedValue = nil
            }
        }
    }
}
