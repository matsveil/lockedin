//
//  TimerView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI
import AVFoundation

struct TimerView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var time: Time
    @ObservedObject var settings: Settings
    
    @State private var progress = 0.0
    @State private var timeRemaining = 0
    @State private var stroke = 0.0
    @State private var opacity = 0.0
    @State private var flash = 0.0
    
    let stunGrenade: SystemSoundID = 1112
    let win: SystemSoundID = 1110
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        
    var totalTime: Double {
        Double(time.hr * 60 * 60 + time.min * 60)
    }
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            ZStack {
                Circle()
                    .stroke(lineWidth: stroke)
                    .foregroundStyle(Color.theme.secondary)
                    .opacity(0.2)
                    .animation(.smooth(duration: 1), value: stroke)
                
                Circle()
                    .trim(from: 0.0, to: min(progress, 1.0))
                    .stroke(Color.theme.primary.opacity(opacity), style: StrokeStyle(lineWidth: 30.0, lineCap: .round, lineJoin: .round))
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.easeIn(duration: 3), value: opacity)
                    .animation(.linear(duration: 1), value: progress)
            
                VStack {
                    Text("\(printFormattedTime(timeRemaining))")
                        .foregroundStyle(Color.theme.foreground)
                        .font(.largeTitle)
                        .bold()
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.center)
                        .transition(.slide)
                }
                .onChange(of: timeRemaining, initial: true) { oldValue, newValue in
                    if settings.isSnapBackOn {
                        if Double(newValue) == 0 {
                            snapBack()
                        } else if Double(newValue) == totalTime / 4 || Double(newValue) == totalTime / 2 || Double(newValue) == totalTime / 4 * 3 {
                            snapBack()
                            flashBang()
                        }
                    }
                }
            }
            .padding(80)
            .onAppear {
                if time.hr == 0 && time.min == 0 {
                    time.min = 1
                }
                calculateTimeRemaining(hours: time.hr, minutes: time.min)
                stroke = 40.0
                opacity = 1
            }
            .onReceive(timer) { time in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    progress += 1.0 / totalTime
                } else if timeRemaining == 0 {
                    dismiss()
                }
            }
            Color.theme.secondary
                .ignoresSafeArea()
                .opacity(flash)
                .animation(.easeInOut(duration: 1), value: flash)
        }
        .ignoresSafeArea()
    }
    
    
    func calculateTimeRemaining(hours: Int, minutes: Int) {
        timeRemaining = hours * 60 * 60 + minutes * 60
    }
        
    func formatTime(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func printFormattedTime(_ seconds: Int) -> String {
        let (h, m, s) = formatTime(seconds)
        
        if h > 0 && m < 1 && s < 1 {
            return "\(h) hr"
        } else if h > 0 && m < 1 {
            return """
                    \(h) hr
                    \(s) sec
                    """
        } else if h > 0 && s < 1 {
            return """
                    \(h) hr
                    \(m) min
                    """
        } else if h > 0 {
            return """
                    \(h) hr
                    \(m) min
                    \(s) sec
                    """
        } else if m > 0 && s < 1 {
            return """
                    \(m) min
                    """
        } else if m > 0 {
            return """
                    \(m) min
                    \(s) sec
                    """
        } else {
            return """
                    \(s) sec
                    """
        }
    }
    
    func snapBack() {
        AudioServicesPlaySystemSound(win)
    }
    
    func flashBang() {
        AudioServicesPlaySystemSound(stunGrenade)
        flash = 0.4
        
        withAnimation(.easeOut.delay(1)) {
            flash = 0.0
        }
    }

}
    
#Preview {
    TimerView(time: Time(), settings: Settings())
}
