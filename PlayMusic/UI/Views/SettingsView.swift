import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager = ThemeManager.shared

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.top, 16)

                VStack(alignment: .leading, spacing: 12) {
                    Text("APPEARANCE")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    HStack(spacing: 12) {
                        ForEach(AppTheme.allCases) { theme in
                            Button(action: {
                                withAnimation(.spring()) {
                                    themeManager.selectedTheme = theme
                                }
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: themeIcon(theme))
                                        .font(.system(size: 22))
                                    Text(theme.rawValue)
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(themeManager.selectedTheme == theme ? Color.blue : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .liquidGlass(cornerRadius: 18, allowsDragPhysics: false)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(themeManager.selectedTheme == theme ? Color.blue : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("SLEEP TIMER")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    if SleepTimerManager.shared.isTimerActive {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(Color.blue)
                            Text("Stopping in \(SleepTimerManager.shared.formattedTime)")
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Button("Cancel") {
                                SleepTimerManager.shared.cancelTimer()
                            }
                            .foregroundColor(.red)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlass(cornerRadius: 16, allowsDragPhysics: false)
                    } else {
                        HStack(spacing: 8) {
                            ForEach([15, 30, 45, 60], id: \.self) { minutes in
                                Button(action: {
                                    SleepTimerManager.shared.startTimer(minutes: minutes)
                                }) {
                                    Text("\(minutes)m")
                                        .font(.system(size: 13, weight: .medium))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .liquidGlass(cornerRadius: 12, allowsDragPhysics: false)
                                }
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("AUDIO QUALITY")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    HStack(spacing: 12) {
                        ForEach(["Low", "Normal", "High"], id: \.self) { quality in
                            let isSelected = (UserDefaults.standard.string(forKey: "audio_quality_preference") ?? "High") == quality
                            Button(action: {
                                UserDefaults.standard.set(quality, forKey: "audio_quality_preference")
                            }) {
                                Text(quality)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(isSelected ? Color.blue : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .liquidGlass(cornerRadius: 14, allowsDragPhysics: false)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("STORAGE & CACHE")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    Button(action: {
                        AudioCacheService.shared.clearCache()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear Audio Cache")
                            Spacer()
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .liquidGlass(cornerRadius: 16, allowsDragPhysics: false)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
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
