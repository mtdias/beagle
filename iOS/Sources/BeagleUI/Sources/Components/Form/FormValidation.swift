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

/// Types of transitions between screens
public struct FieldError: Decodable, AutoInitiable {
    
    public let inputName: String
    public let message: String

// sourcery:inline:auto:FieldError.Init
    public init(
        inputName: String,
        message: String
    ) {
        self.inputName = inputName
        self.message = message
    }
// sourcery:end
}

/// Action to represent a form validation error
public struct FormValidation: Action {
    
    public let errors: [FieldError]
    
    public init(
        errors: [FieldError]
    ) {
        self.errors = errors
    }
    
    public func execute(controller: BeagleController, sender: Any) {
        let inputViews = (sender as? SubmitFormGestureRecognizer)?.formInputViews()
        for error in errors {
            let errorListener = inputViews?.first { view in
                (view.beagleFormElement as? FormInput)?.name == error.inputName
            } as? ValidationErrorListener
            errorListener?.onValidationError(message: error.message)
        }
    }
}
