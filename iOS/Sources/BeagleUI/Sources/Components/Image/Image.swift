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

import UIKit

public struct Image: Widget, AutoInitiableAndDecodable {
    
    // MARK: - Public Properties
    
    public let name: String
    public let contentMode: ImageContentMode?
    public var widgetProperties: WidgetProperties
    
// sourcery:inline:auto:Image.Init
    public init(
        name: String,
        contentMode: ImageContentMode? = nil,
        widgetProperties: WidgetProperties = WidgetProperties()
    ) {
        self.name = name
        self.contentMode = contentMode
        self.widgetProperties = widgetProperties
    }
// sourcery:end
}

extension Image: Renderable {

    public func toView(controller: BeagleController) -> UIView {
        let image = UIImageView(frame: .zero)
        image.clipsToBounds = true
        image.contentMode = (contentMode ?? .fitCenter).toUIKit()
        image.setImageFromAsset(named: name, bundle: controller.dependencies.appBundle)
        
        image.beagle.setup(self)
        
        return image
    }
}

private extension UIImageView {
    func setImageFromAsset(named: String, bundle: Bundle) {
        self.image = UIImage(named: named, in: bundle, compatibleWith: nil)
    }
}
