import SwiftUI
import MapKit
import CoreData

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct Car: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let brand: String
    let fuelLevel: Double
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


struct CarBooking {
    let carID: UUID
    var isBooked: Bool
    var startTime: Date?
    var acceptedRules: Bool = false
}

struct MainView: View {
    @AppStorage("userBalance") private var balance: Double = 0.0
    @State private var showingBalanceAlert = false
    @EnvironmentObject var authManager: AuthManager
    @State private var isExpanded = true
    @State private var dragOffset: CGFloat = 0
    @Environment(\.managedObjectContext) private var context
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 55.71209, longitude: 37.51083),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    
    @State private var selectedCar: Car?
    @State private var showCarDetails = false
    @State private var showBookingRules = false
    @State private var showCancelBooking = false
    @State private var route: MKRoute?
    @State private var cars: [Car] = {
        var cars: [Car] = []
        let brands = ["Changan UNI-T", "Chery Arrizo 8", "Haval H3", "Changan UNI-V", "Changan UNI-V"]
        for i in 0..<5 {
            let latOffset = Double.random(in: -0.005...0.005)
            let lonOffset = Double.random(in: -0.005...0.005)
            let coordinate = CLLocationCoordinate2D(latitude: 55.71209 + latOffset, longitude: 37.51083 + lonOffset)
            let fuelLevel = Double.random(in: 0.3...1.0)
            cars.append(Car(coordinate: coordinate, brand: brands[i], fuelLevel: fuelLevel))
        }
        return cars
    }()
    let fakeUserLocation = CLLocationCoordinate2D(latitude: 55.71209, longitude: 37.51083)
    
    @State private var bookings: [UUID: CarBooking] = [:]
    private let pricePerMinute: Double = 12
    @State private var timer: Timer? = nil
    @State private var now: Date = Date()
    @State private var distanceToCar: Double = 0
    @State private var timeToCar: TimeInterval = 0
    @State private var showProfile = false
    
    @State private var dashPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                ForEach(cars) { car in
                    Annotation("", coordinate: car.coordinate) {
                        Image(systemName: "car.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(bookings[car.id]?.isBooked ?? false ? .red : .blue)
                            .shadow(radius: 3)
                            .onTapGesture { handleCarTap(car) }
                    }
                }
                
                Annotation("", coordinate: fakeUserLocation) {
                    VStack(spacing: 3) {
                        Image(systemName: "figure.walk")
                            .resizable()
                            .frame(width: 20, height: 35)
                            .foregroundColor(.green)
                        Circle()
                            .fill(Color.green.opacity(0.25))
                            .frame(width: 45, height: 45)
                    }
                }
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(
                            .black,
                            style: StrokeStyle(
                                lineWidth: 2,
                                lineCap: .round,
                                lineJoin: .round,
                                dash: [6, 4],
                                dashPhase: dashPhase
                            )
                        )
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            
            VStack {
                HStack {
                    Button(action: { showProfile = true }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.purple)
                            .shadow(radius: 2)
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)
                    Spacer()
                }
                Spacer()
            }
            
            if showCarDetails, let car = selectedCar {
                ZStack {
                    VStack(spacing: 0) {
                        Spacer()

                        CarDetailView(
                            car: car,
                            booking: bookings[car.id],
                            distance: distanceToCar,
                            travelTime: timeToCar,
                            pricePerMinute: pricePerMinute,
                            now: $now,
                            onBook: {
                                if bookings[car.id]?.isBooked ?? false {
                                    showCancelBooking = true
                                } else if bookings.values.contains(where: { $0.isBooked && $0.carID != car.id }) {
                                } else if bookings[car.id]?.acceptedRules ?? false {
                                    toggleBookCar(car)
                                } else {
                                    showBookingRules = true
                                }
                            },
                            onClose: { closeCarDetails() }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .frame(maxWidth: .infinity)
                        .background(Color.clear)
                        .ignoresSafeArea(edges: .bottom)
                    }
                    .edgesIgnoringSafeArea(.bottom)

                    VStack {
                        Spacer()

                        HStack {
                            Button(action: { closeCarDetails() }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(8)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 280)
                        .padding(.leading, 5)
                    }
                }
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(authManager)
        }
        .fullScreenCover(isPresented: $showBookingRules) {
            BookingRulesView { accepted in
                if let car = selectedCar, accepted {
                    var booking = bookings[car.id] ?? CarBooking(carID: car.id, isBooked: false, startTime: nil)
                    booking.acceptedRules = true
                    bookings[car.id] = booking
                    toggleBookCar(car)
                }
                showBookingRules = false
            }
        }
        .fullScreenCover(isPresented: $showCancelBooking) {
            CancelBookingView {
                if let car = selectedCar {
                    let startTime = bookings[car.id]?.startTime ?? Date()
                    completeBookingIfNeeded(car: car, startTime: startTime)
                    
                    var booking = bookings[car.id] ?? CarBooking(carID: car.id, isBooked: false, startTime: nil)
                    booking.isBooked = false
                    booking.startTime = nil
                    bookings[car.id] = booking
                }
                showCancelBooking = false
            }
        }
        .alert("Недостаточно средств", isPresented: $showingBalanceAlert) {
            Button("Пополнить баланс") {
                showProfile = true
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Пополните баланс, чтобы арендовать машину.")
        }
        .onAppear {
            startGlobalTimer()
            startDashAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showCarDetails)
    }
    
    private let animationSpeed: Double = 0.1
    private let dashStep: CGFloat = 3
    
    private func startDashAnimation() {
            Timer.scheduledTimer(withTimeInterval: animationSpeed, repeats: true) { _ in
                withAnimation(.linear(duration: animationSpeed)) {
                    dashPhase -= dashStep
                }
            }
        }
    
    private func handleCarTap(_ car: Car) {
        selectedCar = car
        showCarDetails = true
        calculateRoute(to: car.coordinate)
        calculateDistanceAndTime(to: car.coordinate)
    }
    
    private func calculateRoute(to destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: fakeUserLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .walking
        MKDirections(request: request).calculate { response, _ in
            if let route = response?.routes.first {
                self.route = route
                let region = MKCoordinateRegion(center: route.polyline.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
                cameraPosition = .region(region)
            }
        }
    }
    
    private func calculateDistanceAndTime(to destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: fakeUserLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .walking
        MKDirections(request: request).calculate { response, _ in
            if let route = response?.routes.first {
                self.distanceToCar = route.distance
                self.timeToCar = route.expectedTravelTime
            }
        }
    }
    
    private func toggleBookCar(_ car: Car) {
        var booking = bookings[car.id] ?? CarBooking(carID: car.id, isBooked: false, startTime: nil)
        
        if booking.isBooked {
            booking.isBooked = false
            booking.startTime = nil
        } else {
            if balance <= 0 {
                showingBalanceAlert = true
                return
            }
            booking.isBooked = true
            booking.startTime = Date()
        }
        
        bookings[car.id] = booking
    }
    
    private func closeCarDetails() {
        showCarDetails = false
        selectedCar = nil
        route = nil
        distanceToCar = 0
        timeToCar = 0
    }
    
    private func startGlobalTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            now = Date()
        }
    }
    
    private func completeBookingIfNeeded(car: Car, startTime: Date) {
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        let minutesElapsed = Int(duration / 60)
        let cost = Double(minutesElapsed) * pricePerMinute
        
        if cost > 0 {
            if balance >= cost {
                balance -= cost
            } else {
                balance = 0
            }
        }
        
        if duration >= 10 {
            BookingHistoryManager.saveBooking(
                carBrand: car.brand,
                carID: car.id,
                startTime: startTime,
                endTime: endTime,
                amount: cost,
                status: true,
                context: context
            )
        }
    }
}

struct CarDetailView: View {
    let car: Car
    let booking: CarBooking?
    let distance: Double
    let travelTime: TimeInterval
    let pricePerMinute: Double
    @Binding var now: Date
    let onBook: () -> Void
    let onClose: () -> Void
    
    @State private var isExpanded: Bool = false
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        let booked = booking?.isBooked ?? false
        let start = booking?.startTime ?? now
        let elapsed = booked ? now.timeIntervalSince(start) : 0
        let minutesElapsed = Int(elapsed / 60)
        let cost = minutesElapsed * Int(pricePerMinute)

        VStack(spacing: 12) {
                    Capsule()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 50, height: 5)
                        .padding(.bottom, 20)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if value.translation.height > 0 {
                                        dragOffset = value.translation.height
                                    }
                                }
                                .onEnded { value in
                                    if value.translation.height > 50 {
                                        withAnimation(.easeInOut) {
                                            onClose() 
                                        }
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
            
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text(car.brand)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Spacer()
                    
                }
                
                .padding(.top, 20)
                
                HStack(spacing: 20) {
                    Label("\(Int(car.fuelLevel * 100))%", systemImage: "fuelpump.fill")
                        .foregroundColor(.orange)
                        .font(.subheadline)
                    Label("\(formatDistance(distance))", systemImage: "road.lanes")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.subheadline)
                    Label("\(formatTime(travelTime))", systemImage: "clock")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.subheadline)
                }
                
                if booked {
                    Text("Время аренды: \(formatTime(elapsed))")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.yellow)
                    Text("Стоимость аренды: \(cost) ₽")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            Button(action: onBook) {
                Text(booking?.isBooked ?? false ? "Отменить броннирование" : "Забронировать")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(booking?.isBooked ?? false ? Color.orange.opacity(0.9) : Color(red: 0.0, green: 1.0, blue: 0.0))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.35)
        .background(
            Color(red: 0.75, green: 0.15, blue: 1.0)
                .opacity(0.80)
        )
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.25), radius: 12, y: -6)
        .offset(y: dragOffset)
        .ignoresSafeArea(edges: [.bottom])
    }

    private func formatDistance(_ distance: Double) -> String {
        distance < 1000 ? "\(Int(distance)) м" : String(format: "%.1f км", distance / 1000)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let sec = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, sec)
    }
}

struct BookingRulesView: View {
    @State private var checkbox1 = false
    @State private var checkbox2 = false
    let onConfirm: (Bool) -> Void

    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Spacer()
                Button(action: { onConfirm(false) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(8)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
                .padding(.trailing, 20)
                .padding(.top, 180)
            }
            Text("Важно перед бронированием")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Button(action: { checkbox1.toggle() }) {
                        Image(systemName: checkbox1 ? "checkmark.square.fill" : "square")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Text("Я ознакомился с правилами бронирования и обязуюсь соблюдать их")
                        .foregroundColor(.white)
                        .font(.headline)
                        .onTapGesture { checkbox1.toggle() }
                }
                
                HStack {
                    Button(action: { checkbox2.toggle() }) {
                        Image(systemName: checkbox2 ? "checkmark.square.fill" : "square")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Text("Я обязуюсь соблюдать ПДД при использовании автомобиля")
                        .foregroundColor(.white)
                        .font(.headline)
                        .onTapGesture { checkbox2.toggle() }
                }
            }
            .padding(.horizontal, 30)
            Button(action: { onConfirm(checkbox1 && checkbox2) }) {
                Text("Подтвердить")
                    .font(.headline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.0, green: 1.0, blue: 0.0))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 30)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.75, green: 0.15, blue: 1.0).ignoresSafeArea())
    }
}

struct CancelBookingView: View {
    @State private var checkbox = false
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    Button(action: { onConfirm() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(8)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 200)
                }

                Text("Вы точно хотите отменить аренду?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                HStack(alignment: .top, spacing: 12) {
                    Button(action: { checkbox.toggle() }) {
                        Image(systemName: checkbox ? "checkmark.square.fill" : "square")
                            .foregroundColor(.white)
                            .font(.title2)
                    }

                    Text("Я проверил, что припарковал машину в разрешённом месте")
                        .foregroundColor(.white)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .onTapGesture { checkbox.toggle() }
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: { if checkbox { onConfirm() } }) {
                    Text("Подтвердить отмену")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.0, green: 1.0, blue: 0.0))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .padding(.horizontal, 30)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.75, green: 0.15, blue: 1.0).ignoresSafeArea())
    }
}
