//
//  ItemView.swift
//  Wlist
//
//  Created by Bryce Campbell on 2/14/26.
//

import SwiftUI

struct ItemView: View {
    @State var item: Item
    
    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            if item.quantity > 1 {
                Text("x\(item.quantity)")
                Spacer()
            }
            
            if let url = item.url {
                Text(url.absoluteString)
            }
        }
    }
}

#Preview {
    ItemView(item: Item(name: "Nintendo Switch 2", quantity: 2, url: URL(string: "https://example.com/nintendo-switch-2")))
}
