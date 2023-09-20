//
//  SettingsView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/28/23.
//

import SwiftUI
import HealthKit
import UserNotifications

extension Date: RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}

class Settings: ObservableObject {
    @AppStorage("isSnapBackOn") var isSnapBackOn = true
    @AppStorage("interval") var interval = 15.0
}

struct SettingsView: View {
    @State private var isHealthAccessGranted = false
    @State private var isNotificationAccessGrated = false
    
    @AppStorage("selectedDate") var selectedDate = Date()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var settings = Settings()
    @State private var healthAuthorizationStatus: HKAuthorizationStatus = .notDetermined
    @State private var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @ObservedObject private var healthKitManager = HealthKitManager()
    
    let intervals = [5.0, 10.0, 15.0, 20.0, 30.0, 60.0]
    let notify = NotificationManager()
    
    var body: some View {
        ZStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "alarm.fill")
                        Toggle(isOn: $settings.isSnapBackOn) {
                            Text("SnapBacks")
                                .foregroundStyle(Color.theme.foreground)
                        }
                    }
                    if settings.isSnapBackOn {
                        Picker(selection: $settings.interval) {
                            ForEach(intervals, id: \.self) { interval in
                                Text("\(interval.formatted()) sec").tag(interval)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "timer")
                                Text("Interval")

                                    .foregroundStyle(Color.theme.foreground)
                            }
                        }
                    }
                } header: {
                    Text("Pause").foregroundStyle(Color.theme.secondary)
                } footer: {
                    Text("SnapBacks help you focus on the present moment by nudging you with visual, audio, and sensory stimuli.")
                    
                }

                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Color.theme.secondary.opacity(0.1))
                        .padding(2)
                )
                .listRowSeparator(.hidden)
                
                Section {
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                        Toggle(isOn: $isHealthAccessGranted) {
                            Text("Apple Health")
                                .foregroundStyle(Color.theme.foreground)
                        }
                        .onChange(of: isHealthAccessGranted) { newValue in
                            if newValue == true {
                                DispatchQueue.main.async {
                                    healthKitManager.requestAuthorization()
                                }
                            }
                        }
                    }
                } header: {
                    Text("Connect")
                } footer: {
                    Text("Enable Mindful Moments by going to Settings > Health > Data Access & Devices > MindfulPause.")
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Color.theme.secondary.opacity(0.1))
                        .padding(2)
                )
                
                Section {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                        Toggle(isOn: $isNotificationAccessGrated) {
                            Text("Daily Reminder")
                                .foregroundStyle(Color.theme.foreground)
                        }
                        .onChange(of: isNotificationAccessGrated) { newValue in
                            if newValue == false {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                            }
                        }
                    }
                    if isNotificationAccessGrated {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            DatePicker(selection: $selectedDate, displayedComponents: .hourAndMinute) {
                                Text("When?")
                                    .foregroundStyle(Color.theme.foreground)
                            }
                            .onChange(of: selectedDate) { newValue in
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                notify.sendNotification(date: selectedDate, title: "Time to Pause!", body: "Feeling stressed? Complete a short Pause right now.")
                                print(selectedDate)
                            }
                        }
                        
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("You will be reminded to Pause daiy at \(selectedDate.formatted(.dateTime.hour().minute())).")
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Color.theme.secondary.opacity(0.1))
                        .padding(2)
                )
                .listRowSeparator(.hidden)
                
                Section {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Link("Credit", destination: URL(string: "https://github.com/matsveil/mindful-pause/blob/main/CREDIT.md")!)
                            .foregroundStyle(Color.theme.foreground)
                    }
                    HStack {
                        Image(systemName: "curlybraces.square.fill")
                        Link("Open Source", destination: URL(string: "https://github.com/matsveil/mindful-pause/blob/main/LICENSE")!)
                            .foregroundStyle(Color.theme.foreground)
                    }
                } header: {
                    Text("Legal")
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Color.theme.secondary.opacity(0.1))
                        .padding(2)
                     
                )
                .listRowSeparator(.hidden)
            }
            .environment(\.defaultMinListRowHeight, 60)
            .tint(Color.theme.accent)
            .background(Color.theme.background)
            .foregroundStyle(Color.theme.secondary)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    } label: {
                        Text(Image(systemName: "arrow.uturn.backward.circle.fill"))
                            .font(.system(size: 35))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(Color.theme.secondary.opacity(0.8))
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Settings")
                            .fontDesign(.rounded)
                            .font(.title2)
                            .bold()
                    }
                }
                
            }
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            healthKitManager.checkAuthorizationStatus { status in
                healthAuthorizationStatus = status
            }
                        
            healthKitAuthorization()
            notificationAuthorization()
            
            print(selectedDate)
            
        }
    }
    
    private func healthKitAuthorization() {
        switch healthAuthorizationStatus {
        case .notDetermined:
            isHealthAccessGranted = false
        case .sharingDenied:
            isHealthAccessGranted = false
        case .sharingAuthorized:
            isHealthAccessGranted = true
        @unknown default:
            isHealthAccessGranted = false
        }
    }
    
    private func notificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Checking notification status")
            
            switch settings.authorizationStatus {
            case .notDetermined:
                isNotificationAccessGrated = false
            case .authorized:
                isNotificationAccessGrated = true
            case .denied:
                isNotificationAccessGrated = false
            case .ephemeral:
                isNotificationAccessGrated = true
            case .provisional:
                isNotificationAccessGrated = true
            @unknown default:
                isNotificationAccessGrated = false
            }
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
