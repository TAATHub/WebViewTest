//
//  ViewController.swift
//  WebViewTest
//
//  Created by 董 亜飛 on 2022/08/22.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // index.htmlのパスを取得する
        let path: String = Bundle.main.path(forResource: "index", ofType: "html")!
        let localHtmlUrl: URL = URL(fileURLWithPath: path, isDirectory: false)
        
        let config: WKWebViewConfiguration = WKWebViewConfiguration()
        let controller: WKUserContentController = WKUserContentController()

        // JavaScriptから呼び出せるメッセージハンドラを設定する
        controller.add(self, name: "callbackHandler")
        controller.add(self, name: "userDefaultsHandler")

        config.userContentController = controller

        webView = WKWebView(frame: self.view.bounds, configuration: config)
        self.view.addSubview(webView)
        
        // Delegate
        webView.uiDelegate = self
        
        // ローカルのHTMLページを読み込む
        webView.loadFileURL(localHtmlUrl, allowingReadAccessTo: localHtmlUrl)
        
        UserDefaults.standard.set("ローカルに保存されたメッセージ", forKey: "localmessage")
    }
}

extension ViewController: WKUIDelegate {
    /// アラートを表示する
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - message: メッセージ
    ///   - frame: WKFrameInfo
    ///   - completionHandler: 完了時の処理
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        // 受け取ったメッセージでアラートを作成
        let alert = UIAlertController(title: "タイトル",
                                      message: message,
                                      preferredStyle: .alert)
                
        let action = UIAlertAction(title: "OK", style: .default) { action in
            // OKボタン押下時の処理
            completionHandler()
            
        }
                
        alert.addAction(action)
                
        present(alert ,animated: true ,completion: nil)
    }
    
    /// 確認ダイアログを表示する
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - message: メッセージ
    ///   - frame: WKFrameInfo
    ///   - completionHandler: 完了時の処理
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        // 受け取ったメッセージでアラートを作成
        let alert = UIAlertController(title: "タイトル",
                                      message: message,
                                      preferredStyle: .alert)
        
        // キャンセルアクション
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            completionHandler(false)
        }
    
        // OKアクション
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            completionHandler(true)
        }
            
        alert.addAction(cancelAction)
        alert.addAction(okAction)
            
        present(alert ,animated: true ,completion: nil)
    }
    
    /// 入力ダイアログを表示する
    /// - Parameters:
    ///   - webView: WKWebView
    ///   - prompt: プロンプト
    ///   - defaultText: デフォルトテキスト
    ///   - frame: WKFrameInfo
    ///   - completionHandler: 完了時の処理
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        // 受け取ったメッセージでアラートを作成
        let alert = UIAlertController(title: "タイトル",
                                      message: prompt,
                                      preferredStyle: .alert)
        // キャンセルアクション
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            completionHandler("")
        }

        // OKアクション
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            if let textField = alert.textFields?.first {
                            // 入力したテキストを処理する
                completionHandler(textField.text)
            } else {
                completionHandler("")
            }
        }
            
        alert.addTextField() { $0.text = defaultText }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
            
        present(alert ,animated: true ,completion: nil)
    }
}

extension ViewController: WKScriptMessageHandler {
    
    /// WebViewからスクリプトメッセージを受信した時の処理
    /// - Parameters:
    ///   - userContentController: WKUserContentController
    ///   - message: 受信したメッセージ（オブジェクトの場合も）
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "callbackHandler":
            print("\(message.body)")
        case "userDefaultsHandler":
            let localmessage = UserDefaults.standard.string(forKey: "localmessage") ?? ""
            webView.evaluateJavaScript("showLocalMessage(\"\(localmessage)\")", completionHandler: { (object, error) -> Void in
            })
        default:
            break
        }
    }
}
