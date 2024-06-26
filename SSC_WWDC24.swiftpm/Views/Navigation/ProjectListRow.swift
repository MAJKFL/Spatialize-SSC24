//
//  File.swift
//  
//
//  Created by Jakub Florek on 08/12/2023.
//

import SwiftUI

/// Used for navigating to a project.
struct ProjectListRow: View {
    /// Current project.
    @Bindable var project: Project
    
    /// Specifies whether text field is editable.
    @State private var isTextFieldEnabled = false
    /// Focuses the textfield.
    @FocusState private var isRenaming: Bool
    
    var body: some View {
        TextField("Name", text: $project.name)
            .focused($isRenaming)
            .autocorrectionDisabled()
            .disabled(!isTextFieldEnabled)
            .contextMenu(ContextMenu() {
                Button(action: { isTextFieldEnabled = true }) {
                    Label("Rename", systemImage: "pencil")
                }
            })
            .onChange(of: isTextFieldEnabled) { oldValue, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isRenaming = true
                    }
                }
            }
            .onChange(of: isRenaming) { oldValue, newValue in
                if !newValue {
                    isTextFieldEnabled = false
                }
            }
    }
}
