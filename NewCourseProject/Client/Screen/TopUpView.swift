import SwiftUI

struct TopUpView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userBalance") private var balance: Double = 0.0
    @AppStorage("promoUsed") private var promoUsed: Bool = false

    @State private var amountText: String = ""
    @State private var cardNumber: String = ""
    @State private var cardExpiry: String = ""
    @State private var cardCVV: String = ""
    @State private var promoCode: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {
            Color(red: 0.75, green: 0.15, blue: 1.0).ignoresSafeArea()
                .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Spacer()
                }
                .padding()

                Text("Пополнение баланса")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.top, 10)

                VStack(spacing: 12) {
                    HStack {
                        Text("Сумма (₽)")
                            .foregroundColor(.white)
                        Spacer()
                        TextField("100", text: $amountText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                            .padding(8)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Оплата картой")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("Номер карты", text: $cardNumber)
                            .keyboardType(.numberPad)
                            .textContentType(.creditCardNumber)
                            .padding(10)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        HStack {
                            TextField("MM/YY", text: $cardExpiry)
                                .frame(width: 100)
                                .padding(10)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            TextField("CVV", text: $cardCVV)
                                .frame(width: 80)
                                .keyboardType(.numberPad)
                                .padding(10)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        Text("Данные карты не передаются — это демонстрация интерфейса.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Промокод")
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack {
                            TextField("Введите промокод", text: $promoCode)
                                .padding(10)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            Button("Применить") {
                                applyPromo()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.15)))
                            .foregroundColor(.white)
                        }
                        Text(promoUsed ? "Промокод уже использован." : "Промокод даёт +500₽ (однократно).")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.1)))
                .padding(.horizontal)

                Button(action: payByCard) {
                    Text("Оплатить картой")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.0, green: 1.0, blue: 0.0))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.bottom)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Внимание"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func payByCard() {
        guard let amount = Double(amountText.filter("0123456789".contains)), amount > 0 else {
            alertMessage = "Введите корректную сумму для пополнения."
            showingAlert = true
            return
        }
        balance += amount
        alertMessage = "Успешно пополнено на \(Int(amount))₽. Текущий баланс: \(Int(balance))₽."
        showingAlert = true
    }

    private func applyPromo() {
        let code = promoCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else {
            alertMessage = "Введите промокод."
            showingAlert = true
            return
        }
        if promoUsed {
            alertMessage = "Промокод уже использован."
            showingAlert = true
            return
        }
        if code == "kmept" {
            balance += 500
            promoUsed = true
            alertMessage = "Промокод успешно применён — +500₽! Текущий баланс: \(Int(balance))₽."
            showingAlert = true
        } else {
            alertMessage = "Неверный промокод."
            showingAlert = true
        }
    }
}
