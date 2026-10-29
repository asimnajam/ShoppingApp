//
//  productCardView.swift
//  ShoppingApp
//
//  Created by Syed Asim Najam on 16/10/2026.
//

import SwiftUI

struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color(uiColor: .tertiarySystemGroupedBackground)
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    RemoteImageView(url: product.thumbnail)
                    .padding(16)
                }
                .clipped()
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text(product.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2, reservesSpace: true)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(
                    product.price,
                    format: .currency(code: "USD")
                )
                .font(.headline)
            }
            .padding(12)
        }
        .background(
            Color(uiColor: .secondarySystemGroupedBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}
