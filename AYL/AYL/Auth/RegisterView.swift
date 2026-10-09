//
//  RegisterView.swift
//  AYL
//
//  Created by Олеся Орленко on 02.09.2026.
//

import SwiftUI

struct RegisterView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    
    @State private var name = ""
    @State private var phone = ""
    @State private var role: ParticipantRole = .unspecified
    @State private var email = ""
    @State private var password = ""
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var acceptedLegalRepresentativeConsent = false
    @State private var acceptedTerms = false
    @State private var showingTerms = false
    @State private var acceptedPersonalData = false
    @State private var showingPersonalDataPolicy = false
    
    private var minBirthDate: Date {
        Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()
    }
    
    private var ageYears: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    private var isUnder14: Bool {
        ageYears < 14
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 6 &&
        acceptedTerms &&
        acceptedPersonalData &&
        (!isUnder14 || acceptedLegalRepresentativeConsent)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Данные участника") {
                    TextField("Имя", text: $name)
                    TextField("Телефон", text: $phone)
                        .keyboardType(.phonePad)
                    DatePicker("Дата рождения", selection: $birthDate, in: minBirthDate...Date(), displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                    Picker("Роль", selection: $role) {
                        ForEach(ParticipantRole.profileRoles) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                }
                Section("Вход") {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Пароль (минимум 6 символов)", text: $password)
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                Section {
                    Toggle(isOn: $acceptedTerms) {
                        Button("Я принимаю условия использования") {
                            showingTerms = true
                        }
                        .font(.subheadline)
                        .underline()
                    }
                    Toggle(isOn: $acceptedPersonalData) {
                        Button("Я даю согласие на обработку персональных данных") {
                            showingPersonalDataPolicy = true
                        }
                        .font(.subheadline)
                        .underline()
                    }
                    if isUnder14 {
                        Toggle(isOn: $acceptedLegalRepresentativeConsent) {
                            Text("Регистрацию ребёнка младше 14 лет подтверждает его законный представитель (родитель, усыновитель или опекун) и даёт согласие на обработку персональных данных ребёнка")
                                .font(.subheadline)
                        }
                    }
                }
                Button {
                    register()
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Зарегистрироваться")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(!isFormValid || viewModel.isSaving)
            }
            .navigationTitle("Регистрация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
            }
            .sheet(isPresented: $showingTerms) {
                TermsOfServiceView()
            }
            .sheet(isPresented: $showingPersonalDataPolicy) { PersonalDataPolicyView()
            }
        }
    }
    
    // MARK: - Private methods
    
    private func register() {
        viewModel.register(
            name: name,
            phone: phone,
            role: role,
            email: email,
            password: password,
            birthDate: birthDate,
            legalRepresentativeConsent: isUnder14 ? acceptedLegalRepresentativeConsent : false
        ) { success in
            if success {
                dismiss()
            }
        }
    }
}
