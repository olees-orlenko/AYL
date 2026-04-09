//
//  WebViewContainer.swift
//  AYL
//
//  Created by Олеся Орленко on 06.04.2026.
//

import SwiftUI
import WebKit

// MARK: - WebView Container

struct WebViewContainer: UIViewRepresentable {
    
    // MARK: - Properties
    
    let urlString: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?

    // MARK: - UIViewRepresentable Methods
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString), uiView.url == nil {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    // MARK: - Coordinator
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewContainer

        init(_ parent: WebViewContainer) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if let response = navigationResponse.response as? HTTPURLResponse {
                if response.statusCode >= 400 {
                    parent.errorMessage = "Страница не найдена (Код: \(response.statusCode))"
                    parent.isLoading = false
                    decisionHandler(.cancel)
                    return
                }
            }
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if parent.errorMessage == nil {
                parent.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            if parent.errorMessage == nil {
                parent.errorMessage = error.localizedDescription
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            if parent.errorMessage == nil {
                parent.errorMessage = error.localizedDescription
            }
        }
    }
}
