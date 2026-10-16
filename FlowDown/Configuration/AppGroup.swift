//
//  AppGroup.swift
//  FlowDown
//
//  Created by qaq on 13/12/2025.
//

import Foundation

enum AppGroup {
    /// Substituted from APP_GROUP_IDENTIFIER in the target Info.plist.
    private static let identifier: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "APP_GROUP_IDENTIFIER") as? String,
              !value.isEmpty,
              !value.contains("$(")
        else {
            preconditionFailure("APP_GROUP_IDENTIFIER must be set in the target Info.plist")
        }
        return value
    }()

    private static var containerURL: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: identifier,
        )
    }

    private static var flowDownDirectoryURL: URL? {
        containerURL?.appendingPathComponent("FlowDown")
    }

    static var sharedCloudModelsURL: URL? {
        flowDownDirectoryURL?
            .appendingPathComponent("Models")
            .appendingPathComponent("Cloud")
    }

    /// The app writes this file and FlowDownTranslationProvider, which links this source file, reads it.
    static var sharedAdditionalPromptURL: URL? {
        flowDownDirectoryURL?
            .appendingPathComponent("Prompts")
            .appendingPathComponent("Additional.txt")
    }
}
