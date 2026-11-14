import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    @AppStorage("audio_quality_preference") private var audioQuality: String = "High"

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Pengaturan")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 16)

                    // Appearance Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("TAMPILAN")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)

                        HStack(spacing: 10) {
                            ForEach(AppTheme.allCases) { theme in
                                let isSelected = themeManager.selectedTheme == theme
                                Button(action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        themeManager.selectedTheme = theme
                                    }
                                }) {
                                    VStack(spacing: 6) {
                                        Image(systemName: themeIcon(theme))
                                            .font(.system(size: 20))
                                        Text(theme.rawValue)
                                            .font(.system(size: 13, weight: isSelected ? .bold : .medium, design: .rounded))
                                    }
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                                    )
                                }
                            }
                        }
                    }

                    // Sleep Timer
                    VStack(alignment: .leading, spacing: 10) {
                        Text("SLEEP TIMER")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)

                        if SleepTimerManager.shared.isTimerActive {
                            HStack {
                                Image(systemName: "timer")
                                    .foregroundColor(Color.blue)
                                Text("Musik berhenti dalam \(SleepTimerManager.shared.formattedTime)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                Spacer()
                                Button("Batalkan") {
                                    SleepTimerManager.shared.cancelTimer()
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.red)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                        } else {
                            HStack(spacing: 8) {
                                ForEach([15, 30, 45, 60], id: \.self) { minutes in
                                    Button(action: {
                                        SleepTimerManager.shared.startTimer(minutes: minutes)
                                    }) {
                                        Text("\(minutes)m")
                                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 11)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(Color(UIColor.secondarySystemBackground))
                                            )
                                    }
                                }
                            }
                        }
                    }

                    // Audio Quality
                    VStack(alignment: .leading, spacing: 10) {
                        Text("KUALITAS AUDIO")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)

                        HStack(spacing: 10) {
                            ForEach(["Low", "Normal", "High"], id: \.self) { quality in
                                let isSelected = audioQuality == quality
                                Button(action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        audioQuality = quality
                                    }
                                }) {
                                    Text(quality)
                                        .font(.system(size: 14, weight: isSelected ? .bold : .medium, design: .rounded))
                                        .foregroundColor(isSelected ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                                        )
                                }
                            }
                        }
                    }

                    // Crossfade & Automix Section (Apple Music Style)
                    VStack(alignment: .leading, spacing: 14) {
                        Text("AUDIO PLAYBACK & AUTOMIX")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)

                        VStack(spacing: 16) {
                            // Crossfade Slider
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Crossfade")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(AudioPlayerManager.shared.crossfadeDuration == 0 ? "Mati" : "\(Int(AudioPlayerManager.shared.crossfadeDuration)) dtk")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(AudioPlayerManager.shared.crossfadeDuration > 0 ? .blue : .secondary)
                                }

                                Slider(
                                    value: Binding(
                                        get: { AudioPlayerManager.shared.crossfadeDuration },
                                        set: { AudioPlayerManager.shared.setCrossfade(seconds: $0) }
                                    ),
                                    in: 0...12,
                                    step: 1
                                )
                                .accentColor(.blue)
                            }

                            Divider()

                            // Automix Toggle
                            Toggle(isOn: Binding(
                                get: { AudioPlayerManager.shared.isAutomixEnabled },
                                set: { _ in AudioPlayerManager.shared.toggleAutomix() }
                            )) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Automix Cerdas")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("Menghubungkan outro dan intro lagu tanpa henti layaknya DJ")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(UIColor.secondarySystemBackground))
                        )
                    }

                    // Storage & Cache
                    VStack(alignment: .leading, spacing: 10) {
                        Text("PENYIMPANAN")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(1.2)

                        Button(action: {
                            AudioCacheService.shared.clearCache()
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 15))
                                Text("Hapus Cache Audio Offline")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                Spacer()
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                        }
                    }

                    // App Info
                    VStack(alignment: .center, spacing: 4) {
                        Text("PlayMusic v1.0.0")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                        Text("Pure Swift & Apple Music Native HIG")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 130)
            }
        }
    }

    private func themeIcon(_ theme: AppTheme) -> String {
        switch theme {
        case .system: return "iphone"
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        }
    }
}
