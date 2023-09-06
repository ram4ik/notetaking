//
//  notetakingApp.swift
//  notetaking
//
//  Created by Ramill Ibragimov on 06.09.2023.
//

import SwiftUI

@main
struct notetakingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
