//
//  ContentView.swift
//  notetaking
//
//  Created by Ramill Ibragimov on 06.09.2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \NoteEntry.updatedAt, ascending: true)],
        animation: .default)
    private var noteEntries: FetchedResults<NoteEntry>

    var body: some View {
        NavigationView {
            List {
                ForEach(noteEntries) { noteEntry in
                    NoteEntryView(noteEntry: noteEntry)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button(action: PersistenceController.shared.addNoteEntity) {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
            Text("Select an note")
        }
    }
}

struct NoteEntryView: View {
    @ObservedObject var noteEntry: NoteEntry
    
    @State private var shouldShowDeleteButton: Bool = false
    @State private var shouldPresentConfirm: Bool = false
    
    ///Define states to store values of the text inputs
    @State private var titleInput: String = ""
    @State private var contentInput: String = ""
    
    var body: some View {
        if let title = noteEntry.title,
           let content = noteEntry.content,
           let updatedAt = noteEntry.updatedAt {
                NavigationLink {
                    VStack {
                        ///Text field for Title. One-line Text Input.
                        TextField("Title", text: $titleInput)
                        ///When the view is rendered, assuming the FetchRequest is finished
                        ///update the text input with the fetch result
                            .onAppear() {
                                self.titleInput = title
                            }
                            .onChange(of: titleInput) { newTitle in
                                PersistenceController.shared.updateNoteEntry(noteEntry: noteEntry, title: newTitle, content: contentInput)
                            }
                        ///Text Editor for Content. Multi-line Text Input.
                        TextEditor(text: $contentInput)
                            .onAppear() {
                                self.contentInput = content
                            }
                            .onChange(of: contentInput) { newContent in
                                PersistenceController.shared.updateNoteEntry(noteEntry: noteEntry, title: titleInput, content: newContent)
                            }
                    }
                } label: {
                    HStack {
                        Text(title)
                        Text(updatedAt, formatter: itemFormatter)
                        Spacer()
                        if shouldShowDeleteButton || shouldPresentConfirm {
                            Button {
                                shouldPresentConfirm = true
                            } label: {
                                Image(systemName: "minus.circle")
                            }
                            .buttonStyle(.plain)
                            .confirmationDialog("Are you sure?", isPresented: $shouldPresentConfirm) {
                                Button("Delete this note", role: .destructive) {
                                    PersistenceController.shared.deleteNoteEntry(noteEntry: noteEntry)
                                }
                            }
                        }
                    }.onHover { isHover in
                        shouldShowDeleteButton = isHover
                    }
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
