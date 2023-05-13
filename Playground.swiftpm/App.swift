import SwiftUI

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            Root()
        }
    }
}

struct Root: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        UIStoryboard(name: "Main", bundle: .main).instantiateInitialViewController()!
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
