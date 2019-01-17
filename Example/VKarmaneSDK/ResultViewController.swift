//
//  ResultViewController.swift
//  VKarmaneSDK_Example
//
//  Created by a.kulabukhov on 14/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import VKarmaneSDK

final class ResultViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    fileprivate var result: Result!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch result! {
        case .success(let jsonString): textView.text = jsonString
        case .failure(let error): textView.text = error.localizedDescription
        case .cancelled: textView.text = "Заполнение было отменено"
        }
    }
    
}

// MARK: URL Hanling

extension ResultViewController {
    
    fileprivate enum Result {
        case success(jsonString: String)
        case cancelled
        case failure(error: Error)
    }
    
    static func make(withUrl url: URL, privateKey: SecKey) -> UIViewController? {
        guard let result = getResultFromURL(url: url, privateKey: privateKey) else { return nil }
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: self)) as! ResultViewController
        controller.result = result
        return controller
    }
    
    fileprivate static func getResultFromURL(url: URL, privateKey: SecKey) -> Result? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        guard components.scheme?.lowercased() == Const.urlScheme else { return nil }
        
        switch components.host {
        case Const.successPath:
            do { return .success(jsonString: try VKarmaneSDK.getJsonFromLink(url, privateKey: privateKey)) }
            catch { return .failure(error: error) }
        case Const.errorPath: return .failure(error: VKarmaneSDK.getErrorFromLink(url))
        case Const.cancelPath: return .cancelled
        default: return nil
        }
    }
    
}

extension VKarmaneSDKError: LocalizedError {
    
    public var errorDescription: String? {
        return "Код ошибки: \(rawValue)\n\(userReadableInfo)"
    }
    
    var userReadableInfo: String {
        switch self {
        case .badActionParameters: return "Были переданы сломанные параметры action"
        case .badXCallbackParameters: return "Не удалось получить параметры протокола x-callback"
        case .internalError: return "Неизвестная ошибка"
        case .unauthorized: return "Пользователь не авторизован во ВКармане"
        case .unknownAction: return "Неизвестный action"
        case .unsupportedVersion: return "Неподдерживаемая версия протокола"
        case .cryptographyError: return "Ошибка криптографии"
        }
    }
}
