/*
* Copyright 2016 Google Inc. All Rights Reserved.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

/**
 View for rendering a `FieldInputLayout`.
 */
@objc(BKYFieldInputView)
public class FieldInputView: FieldView {
  // MARK: - Properties

  /// The `FieldInput` backing this view
  public var fieldInput: FieldInput? {
    return fieldLayout?.field as? FieldInput
  }

  /// The text field to render
  public private(set) lazy var textField: InsetTextField = {
    let textField = InsetTextField(frame: CGRectZero)
    textField.delegate = self
    textField.borderStyle = .RoundedRect
    textField.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    textField
      .addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
    return textField
  }()

  // MARK: - Initializers

  public required init() {
    super.init(frame: CGRectZero)

    addSubview(textField)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("Called unsupported initializer")
  }

  // MARK: - Super

  public override func refreshView(forFlags flags: LayoutFlag = LayoutFlag.All) {
    super.refreshView(forFlags: flags)

    guard let layout = self.fieldLayout,
      let fieldInput = self.fieldInput else
    {
      return
    }

    if flags.intersectsWith(Layout.Flag_NeedsDisplay) {
      if textField.text != fieldInput.text {
        textField.text = fieldInput.text
      }

      // TODO:(#27) Standardize this font
      textField.font = UIFont.systemFontOfSize(14 * layout.engine.scale)
      textField.insetPadding = layout.config.edgeInsetFor(LayoutConfig.FieldTextFieldInsetPadding)
    }
  }

  public override func prepareForReuse() {
    super.prepareForReuse()

    textField.text = ""
  }

  // MARK: - Private

  private dynamic func textFieldDidChange(sender: UITextField) {
    fieldInput?.text = (textField.text ?? "")
  }
}

// MARK: - UITextFieldDelegate

extension FieldInputView: UITextFieldDelegate {
  public func textFieldShouldReturn(textField: UITextField) -> Bool {
    // This will dismiss the keyboard
    textField.resignFirstResponder()
    return true
  }
}

// MARK: - FieldLayoutMeasurer implementation

extension FieldInputView: FieldLayoutMeasurer {
  public static func measureLayout(layout: FieldLayout, scale: CGFloat) -> CGSize {
    guard let fieldInput = layout.field as? FieldInput else {
      bky_assertionFailure("`layout.field` is of type `(layout.field.dynamicType)`. " +
        "Expected type `FieldInput`.")
      return CGSizeZero
    }

    let textPadding = layout.config.edgeInsetFor(LayoutConfig.FieldTextFieldInsetPadding)
    let maxWidth = layout.config.floatFor(LayoutConfig.FieldTextFieldMaximumWidth)
    // TODO:(#27) Use a standardized font size that can be configurable for the project
    let measureText = fieldInput.text + " "
    let font = UIFont.systemFontOfSize(14 * scale)
    var measureSize = measureText.bky_singleLineSizeForFont(font)
    measureSize.height += textPadding.top + textPadding.bottom
    measureSize.width = min(measureSize.width + textPadding.left + textPadding.right, maxWidth)
    return measureSize
  }
}
