import Foundation

@MainActor
final class LeadFormViewModel: ObservableObject {
    @Published var form = LeadForm()
    @Published private(set) var hasSubmitted = false

    func validate() -> [String] {
        var errors: [String] = []

        if form.fullName.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
            errors.append("Please enter a valid full name.")
        }

        let digits = form.phoneNumber.filter(\.isNumber)
        if digits.count != 10 {
            errors.append("Phone number must contain 10 digits.")
        }

        if form.city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Please enter your city.")
        }

        return errors
    }

    func submit() {
        hasSubmitted = true
    }

    func reset() {
        form = LeadForm()
        hasSubmitted = false
    }
}
