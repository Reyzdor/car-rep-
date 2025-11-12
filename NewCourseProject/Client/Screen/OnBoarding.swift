import SwiftUI

struct OnBoardingView: View {
    @Binding var hasCompletedBoarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            ZStack {
                Color(red: 0.75, green: 0.15, blue: 1.0)
                    .ignoresSafeArea(.all)
                
                VStack {
                    HStack {
                        ForEach(0..<3, id:\.self) { index in
                            Capsule()
                                .frame(width: currentPage == index ? 30 : 15, height: 8)
                                .foregroundColor(currentPage == index ? .white : .gray.opacity(0.5))
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    
                    .padding(.top, 60)
                    
                    Spacer()
                
                    
                    LargeCardView(
                                iconName: "pin2",
                                title: "Найдите автомобиль рядом",
                                description: "Тысячи автомобилей доступны в вашем городе.\nВыберите ближайший и отправляйтесь в путь!"
                            )
                    
                    
                    HStack(spacing: 25){
                        SmallCardView(iconName: "security", title: "Безопасность", description: "Автомобили\nзастрахованы")
                        
                        SmallCardView(iconName: "star", title: "Качество", description: "Проверенные\nавто")
                        
                        SmallCardView(iconName: "flash", title: "Быстро", description: "Открытие за\n30 секунд")
                    }
                    
                    Spacer()
                    
                    OnBoardingButton(
                        title: "Далее",
                        action: {
                            currentPage = 1
                        },
                        backgroundColor: Color(red: 0.0, green: 1.0, blue: 0.0),
                        showArrow: true
                    )
                    .padding(.bottom, 20)
                    Text("Нажимая на кнопку, вы принимаете условия пользовательского соглашения и политики конфиденциальности")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                        .frame(maxWidth: .infinity)
                }
                SkipOnBoardingView(
                    text: "Пропустить",
                    hasCompetedBoarding: $hasCompletedBoarding
                )
            
            }
            .tag(0)
            
            ZStack {
                Color(red: 0.75, green: 0.15, blue: 1.0)
                    .ignoresSafeArea(.all)
                
                VStack {
                    HStack {
                        ForEach(0..<3, id:\.self) { index in
                            Capsule()
                                .frame(width: currentPage == index ? 30 : 15, height: 8)
                                .foregroundColor(currentPage == index ? .white : .gray.opacity(0.5))
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    LargeCardView(
                                iconName: "time",
                                title: "Оплата по минутам",
                                description: "Платите только за фактическое время\nиспользования. Гибкие тарифы для любых поездок"
                            )
                    
                    MiddleCardView(
                        titleTarif: "Примеры тарифов",
                        types: ["Эконом", "Комфорт", "Бизнес"],
                        prices: ["от 280₽/час", "от 350₽/час", "от 500₽/час"]
                    )
                    
                    Spacer()
                    
                    OnBoardingButton(
                        title: "Далее",
                        action: {
                            currentPage = 2
                        },
                        backgroundColor: Color(red: 0.0, green: 1.0, blue: 0.0),
                        showArrow: true
                    )
                   
                    .padding(.bottom, 20)
                    Text("Нажимая на кнопку, вы принимаете условия пользовательского соглашения и политики конфиденциальности")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                        .frame(maxWidth: .infinity)
                }
                SkipOnBoardingView(
                    text: "Пропустить",
                    hasCompetedBoarding: $hasCompletedBoarding
                )
            }
            .tag(1)
            
            ZStack {
                Color(red: 0.75, green: 0.15, blue: 1.0)
                    .ignoresSafeArea(.all)
                
                VStack {
                    HStack {
                        ForEach(0..<3, id:\.self) { index in
                            Capsule()
                                .frame(width: currentPage == index ? 30 : 15, height: 8)
                                .foregroundColor(currentPage == index ? .white : .gray.opacity(0.5))
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    LargeCardView(
                                iconName: "bigflash",
                                title: "Быстрое бронирование",
                                description: "Мгновенное подтверждение бронирования.\nЦифровой процесс для вашего удобства"
                            )
                    
                    StripesOnBoardingView(
                        iconName: "phone",
                        title: "1. Выберите машину",
                        description: "На карте или в списке",
                        approved: "checkmark.circle.fill",
                        circleColor: Color(red: 0.98, green: 0.45, blue: 0.09),
                        iconColor: Color(.white)
                    )
                    
                    StripesOnBoardingView(
                        iconName: "card",
                        title: "2. Подтвердить бронь",
                        description: "Одним нажатием",
                        approved: "checkmark.circle.fill",
                        circleColor: Color(red: 0.0, green: 1.0, blue: 0.0),
                        iconColor: Color(.black)

                    )
                    
                    StripesOnBoardingView(
                        iconName: "flash",
                        title: "3. Садитесь и наслаждайтесь",
                        description: "За 30 секунд",
                        approved: "checkmark.circle.fill",
                        circleColor: Color(red: 0.58, green: 0.20, blue: 0.92),
                        iconColor: Color(.white)

                    )
                    
                    Spacer()
                    
                    OnBoardingButton(
                        title: "Начать пользоваться",
                        action: {
                            hasCompletedBoarding = true
                        },
                        backgroundColor: Color(red: 0.0, green: 1.0, blue: 0.0),
                        showArrow: false
                    )
                    .padding(.bottom, 20)
                    Text("Нажимая на кнопку, вы принимаете условия пользовательского соглашения и политики конфиденциальности")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)
                        .frame(maxWidth: .infinity)
                }
            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea(.all)
    }
}
