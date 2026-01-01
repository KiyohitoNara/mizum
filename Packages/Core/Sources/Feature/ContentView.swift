import SwiftUI

public struct ContentView: View {
    // 外部からインスタンス化するために public initializer も追加
    public init() {}

    public var body: some View {
        Text("Hello, world!")
            .padding()
    }
}
