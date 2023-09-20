//
//  SelectView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI
import HealthKit
import UserNotifications

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

class Time: ObservableObject {
    @AppStorage("hr") var hr = 0
    @AppStorage("min") var min = 1
}

struct SelectView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject var time = Time()
    @State private var showTimerView = false
    let hour = Calendar.current.component(.hour, from: Date())
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                VStack(alignment: .leading) {
                    Spacer()
                    Spacer()
                    
                    if hour <= 12 {
                        Text("Good morning,")
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title)
                            .fontDesign(.rounded)
                            .bold()
                    }
                    else if hour <= 17 {
                        Text("Good afternoon,")
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title)
                            .fontDesign(.rounded)
                            .bold()
                    }
                    else if hour <= 21 {
                        Text("Good evening,")
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title)
                            .fontDesign(.rounded)
                            .bold()
                    } else {
                        Text("Good night,")
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title)
                            .fontDesign(.rounded)
                            .bold()
                    }
                    
                    Text("How long do you want to Pause?")
                        .foregroundStyle(Color.theme.foreground)
                        .font(.title)
                        .fontDesign(.rounded)
                        .bold()
                    
                    Spacer()
                    
                    HStack {
                        Picker("Select hours", selection: $time.hr) {
                            ForEach(0..<13, id: \.self) { i in
                                Text("\(i) hr").tag(i)
                                    .foregroundStyle(Color.theme.secondary)
                                    .font(.title)
                                    .fontDesign(.rounded)
                                    .bold()
                            }
                        }
                        .pickerStyle(.wheel)
                        
                        Picker("Select minutes", selection: $time.min) {
                            ForEach((time.hr > 0 ? 0 : 1)..<60, id: \.self) { i in
                                Text("\(i) min").tag(i)
                                    .foregroundStyle(Color.theme.secondary)
                                    .font(.title)
                                    .fontDesign(.rounded)
                                    .bold()
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    .padding(-10)
                    
                    Spacer()
                    
                    
                    NavigationLink {
                        TimerView(time: time, settings: Settings())
                    } label: {
                        Text("Let's Pause")
                            .foregroundStyle(Color.theme.foreground)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .contentShape(Rectangle())
                            .padding(.vertical)
                        
                    }
                    .background(Color.theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                    
                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Text(Image(systemName: "gear.circle.fill"))
                            .font(.system(size: 35))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(Color.theme.secondary.opacity(0.8))
            
                    }
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35)
                }
            }
            .navigationDestination(isPresented: $showTimerView) {
                TimerView(time: time, settings: Settings())
            }
        }
    
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
        .onOpenURL { url in
            time.min = 1
            showTimerView = true
        }
    }
}

struct SelectView_Previews: PreviewProvider {
    static var previews: some View {
        SelectView()
    }
}
