//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by Itsuki on 2025/10/22.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit


// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    var shieldConfiguration = ShieldConfiguration(
        backgroundBlurStyle: nil,
        backgroundColor: UIColor.yellow.withAlphaComponent(0.1),
        icon: UIImage(systemName: "slash.circle")?.withTintColor(UIColor.systemRed),
        title: .init(text: "You are banned!", color: .black),
        subtitle: .init(text: "Please go do something else!", color: .secondaryLabel),
        primaryButtonLabel: .init(text: "Fine! Got it!", color: .white),
        primaryButtonBackgroundColor: UIColor.systemRed,
        secondaryButtonLabel: .init(text: "Remove Restrictions! RIGHT NOW!", color: .black),
    )
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
        
        shieldConfiguration
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        shieldConfiguration
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        shieldConfiguration
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        shieldConfiguration
    }
}
