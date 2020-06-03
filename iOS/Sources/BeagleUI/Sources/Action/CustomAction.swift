/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

/// A custom action to be implemented by the application
public struct CustomAction: Action, AutoInitiable {
    
    public let name: String
    public let data: [String: String]

// sourcery:inline:auto:CustomAction.Init
    public init(
        name: String,
        data: [String: String]
    ) {
        self.name = name
        self.data = data
    }
// sourcery:end
    
    public func execute(controller: BeagleController, sender: Any) {
        controller.dependencies.customActionHandler?.handle(action: self, controller: controller) {
            [weak controller] result in guard let controller = controller else { return }
            
            switch result {
            case .start:
                controller.serverDrivenState = .loading(true)
            case .error(let error):
                controller.serverDrivenState = .error(.action(error))
            case .success(let action):
                controller.serverDrivenState = .loading(false)
                action.execute(controller: controller, sender: sender)
            }
        }
    }
}
