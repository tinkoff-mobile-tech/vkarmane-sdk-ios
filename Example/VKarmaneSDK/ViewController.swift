//
//  ViewController.swift
//  VKarmaneSDK
//
//  Created by a.kulabukhov on 09/13/2018.
//  Copyright (c) 2018 a.kulabukhov. All rights reserved.
//

import UIKit
import VKarmaneSDK

class ViewController: UIViewController {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.color = .red
        indicator.hidesWhenStopped = true
        indicator.center = view.center
        view.addSubview(indicator)
        return indicator
    }()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var multiselectSwitch: UISwitch!
    @IBOutlet weak var button: UIButton!
    
    var keys: RSA.KeyPair?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !VKarmaneSDK.isAppInstalled {
            showError("Приложение ВКармане не установлено, некоторые функции могут не работать")
        }
    }
    
}

// MARK: Logic

extension ViewController {
    
    var selectedKinds: [DocumentKind] {
        return tableView.indexPathsForSelectedRows?.map { DocumentKind.allCases[$0.row] } ?? []
    }
    
    @IBAction func getDocumentsAction(_ sender: UIButton) {
        setLoading(true)
        doAsync(action: { [weak self] () -> String in
            guard let self = self else { throw NSError() }
            return try self.refreshKeysAndGetPublic()
        }, completion: { [weak self] publicKey, error in
            guard let self = self else { return }
            self.setLoading(false)
            if let publicKey = publicKey {
                do {
                    let url = try self.prepareUrl(publicKey: publicKey)
                    self.processUrl(url)
                }
                catch {
                    self.showError(error.localizedDescription)
                }
            }
            if let error = error {
                self.showError(error.localizedDescription)
            }
        })
    }
    
    private func refreshKeysAndGetPublic() throws -> String {
        let keys = try VKarmaneSDK.makeKeys()
        self.keys = keys
        return try keys.publicKey.getData().base64EncodedString()
    }
    
    private func prepareUrl(publicKey: String) throws -> URL {
        return try LinkBuilder.buildUrl(source: Bundle.main.name!, kinds: selectedKinds, publicKey: publicKey, isMultichoice: multiselectSwitch.isOn)
    }
    
    private func processUrl(_ url: URL) {
        let controller = UIAlertController(title: "ВКармане", message: "Запустить приложение по ссылке? Вы можете отредактировать ссылку, чтобы проверить негативные кейсы", preferredStyle: .alert)
        
        let textField = UITextView(frame: .zero)
        textField.text = url.absoluteString
        
        let viewInjection = controller.setContentView(textField, heightPoints: 8)
        
        controller.addAction(UIAlertAction(title: "Перейти", style: .default) { [unowned self] action in
            guard let url = URL(string: textField.text) else { self.showError("Ссылка сильно испорчена, попробуйте поаккуратнее"); return }
            self.openURL(url)
        })
        controller.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(controller, animated: true) {
            viewInjection()
            textField.becomeFirstResponder()
        }
    }
    
    private func openURL(_ url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:])
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func setLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        button.isEnabled = !isLoading
    }
    
}

// MARK: Table configuration

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    static let cellId = "Cell"
    
    func prepareTable() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ViewController.cellId)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DocumentKind.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.cellId, for: indexPath)
        cell.textLabel?.text = DocumentKind.allCases[indexPath.row].rawValue
        return cell
    }
    
}

// MARK: Utils

extension ViewController {
    
    func doAsync<T>(action: @escaping () throws -> T, completion: ((T?, Error?) -> Void)?) {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let result = try action()
                DispatchQueue.main.async { completion?(result, nil) }
            }
            catch {
                DispatchQueue.main.async { completion?(nil, error) }
            }
        }
    }
    
    func showError(_ text: String) {
        let controller = UIAlertController(title: "Ошибка", message: text, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller, animated: true)
    }
    
}

extension Bundle {
    var name: String? {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String
    }
}
