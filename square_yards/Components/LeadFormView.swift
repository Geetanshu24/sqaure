//
//  LeadFormView.swift
//  square_yards
//

import SwiftUI

struct LeadFormView: View {
    let onClose: () -> Void

    @StateObject private var viewModel = LeadFormViewModel()
    @State private var isWhatsAppPreferred = true

    private var errors: [String] {
        viewModel.validate()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Capsule()
                .fill(Color.black.opacity(0.16))
                .frame(width: 54, height: 6)
                .frame(maxWidth: .infinity)
                .padding(.top, 2)

            header

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    formField(title: "Name", placeholder: "Sudhanshu Singh", text: $viewModel.form.fullName, keyboardType: .default)
                    mobileField
                    cityField

                    Button {
                        isWhatsAppPreferred.toggle()
                    } label: {
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .stroke(Color.black.opacity(0.14), lineWidth: 1)
                                .frame(width: 20, height: 20)
                                .overlay {
                                    if isWhatsAppPreferred {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.green)
                                    }
                                }

                            Text("You can reach me on")
                                .foregroundStyle(.black.opacity(0.8))

                            Image(systemName: "message.fill")
                                .foregroundStyle(Color.green)

                            Text("WhatsApp")
                                .foregroundStyle(Color.green)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                    .buttonStyle(.plain)

                    if viewModel.hasSubmitted, errors.isEmpty == false {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(errors, id: \.self) { error in
                                Text(error)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                            }
                        }
                    }

                    Button {
                        viewModel.submit()
                        if errors.isEmpty {
                            onClose()
                            viewModel.reset()
                        }
                    } label: {
                        Text("Submit")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    }
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 0)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Contact Our Domain Experts")
                    .font(.system(size: 18, weight: .bold))

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(.black.opacity(0.65))
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 4)
    }

    private func formField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.words)
                .keyboardType(keyboardType)
                .padding(.top, 24)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.black.opacity(0.14), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(alignment: .topLeading) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.black.opacity(0.58))
                        .padding(.top, 10)
                        .padding(.horizontal, 16)
                }
        }
    }

    private var mobileField: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                HStack(spacing: 8) {
                    Text("+91")
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                }
                .frame(width: 102, height: 60)

                Divider()

                TextField("Mobile", text: $viewModel.form.phoneNumber)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 16)
                    .frame(height: 60)
            }
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.black.opacity(0.14), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var cityField: some View {
        HStack {
            TextField("City", text: $viewModel.form.city)
                .foregroundStyle(.black)

            Spacer()

            Image(systemName: "chevron.down")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 16)
        .frame(height: 58)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.black.opacity(0.14), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
