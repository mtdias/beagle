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

public class Beagle {

    public static var dependencies: BeagleDependenciesProtocol = BeagleDependencies()

    private init() {}

    // MARK: - Public Functions
    
    /// Register a custom component
    public static func registerCustomComponent<C: ServerDrivenComponent>(
        _ name: String,
        componentType: C.Type
    ) {
        dependencies.decoder.register(componentType, for: name)
    }

    public static func screen(_ type: ScreenType) -> BeagleScreenViewController {
        return BeagleScreenViewController(type)
    }
}
