//
//  ProfileView.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI

struct ProfileView: View {
    let childProfile: ChildProfile?
    let appointments: [Appointment]
    let onLogout: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private let clinicalArchives: [ClinicalArchive] = [
        ClinicalArchive(
            id: "1",
            title: "Weekly ABA Progress",
            type: "Lesson Log",
            date: "Oct 20, 2024",
            icon: "book.fill"
        ),
        ClinicalArchive(
            id: "2",
            title: "Physician Feedback",
            type: "Clinical Note",
            date: "Oct 15, 2024",
            icon: "note.text"
        ),
        ClinicalArchive(
            id: "3",
            title: "Q3 Assessment Report",
            type: "Diagnostic",
            date: "Sep 30, 2024",
            icon: "chart.bar.fill"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header spacing
                Color.clear
                    .frame(height: 96)
                
                // Profile header
                profileHeader
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                
                // Content sections
                VStack(spacing: 40) {
                    // Clinical Data Layer
                    clinicalDataSection
                        .padding(.horizontal, 24)
                    
                    // Child Personalization
                    personalizationSection
                        .padding(.horizontal, 24)
                    
                    // Upcoming Sessions
                    sessionsSection
                        .padding(.horizontal, 24)
                    
                    // Logout button
                    logoutSection
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                        .padding(.bottom, 48)
                }
            }
        }
        .background(Color.white)
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 24) {
            // Avatar section
            ZStack(alignment: .bottomTrailing) {
                // Parent avatar
                AsyncImage(url: parentAvatarURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 128, height: 128)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 4)
                )
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.white, lineWidth: 8)
                )
                
                // Child avatar
                AsyncImage(url: childAvatarURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 4)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .offset(x: -8, y: -8)
            }
            
            // Name and subtitle
            VStack(spacing: 8) {
                Text(childProfile?.parentName ?? "Parent Name")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                    .tracking(-1)
                
                Text("Personalizing Support for \(childProfile?.name ?? "Child")")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .tracking(2)
            }
            
            // Reward points
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("\(childProfile?.points ?? 0) Reward Points")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
                    .tracking(2)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.primary.opacity(0.05))
                    .overlay(
                        Capsule()
                            .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Clinical Data Section
    
    private var clinicalDataSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Clinical Data Layer")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
                .padding(.leading, 8)
            
            VStack(spacing: 16) {
                ForEach(clinicalArchives) { archive in
                    clinicalArchiveCard(archive)
                }
            }
        }
    }
    
    private func clinicalArchiveCard(_ archive: ClinicalArchive) -> some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: archive.icon)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(archive.title)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.primary.opacity(0.9))
                    
                    Text(archive.type)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                        .textCase(.uppercase)
                        .tracking(2)
                }
                
                Spacer()
                
                Text(archive.date)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Personalization Section
    
    private var personalizationSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Child Personalization")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
                .padding(.leading, 8)
            
            VStack(spacing: 24) {
                HStack {
                    Text("Support Level")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.gray)
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    Text(childProfile?.severity ?? "N/A")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.red)
                }
                .padding(.bottom, 16)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(height: 1)
                        .offset(y: 16)
                )
                
                HStack(alignment: .top) {
                    Text("Primary Goals")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundColor(.gray)
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    Text(childProfile?.goals?.joined(separator: ", ") ?? "N/A")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 44)
                    .fill(Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 44)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Sessions Section
    
    private var sessionsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Upcoming Sessions")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
                .padding(.leading, 8)
            
            if appointments.isEmpty {
                emptySessionsView
            } else {
                VStack(spacing: 12) {
                    ForEach(appointments) { appointment in
                        appointmentCard(appointment)
                    }
                }
            }
        }
    }
    
    private var emptySessionsView: some View {
        VStack(spacing: 16) {
            Text("No Active Sessions")
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 48)
                .fill(Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 48)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                        .foregroundColor(.gray.opacity(0.2))
                )
        )
    }
    
    private func appointmentCard(_ appointment: Appointment) -> some View {
        HStack(spacing: 16) {
            if let expertImg = appointment.expertImg, !expertImg.isEmpty {
                AsyncImage(url: URL(string: expertImg)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 44, height: 44)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.expertName ?? "Expert")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                Text("\(appointment.date) • \(appointment.time)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .textCase(.uppercase)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Logout Section
    
    private var logoutSection: some View {
        VStack(spacing: 32) {
            Button(action: {
                onLogout()
                dismiss()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.red)
                    
                    Text("Sign Out")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.red)
                        .textCase(.uppercase)
                        .tracking(2)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.red.opacity(0.1))
                )
            }
            .buttonStyle(ScaleButtonStyle())
            
            Text("Version 2.5.0 • Encrypted HIPAA Compliant")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(2)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Helper Properties
    
    private var parentAvatarURL: URL? {
        let name = childProfile?.parentName ?? "Parent"
        return URL(string: "https://api.dicebear.com/7.x/avataaars/svg?seed=\(name)")
    }
    
    private var childAvatarURL: URL? {
        let name = childProfile?.name ?? "Child"
        return URL(string: "https://api.dicebear.com/7.x/avataaars/svg?seed=\(name)")
    }
}

// MARK: - Supporting Types

private struct ClinicalArchive: Identifiable {
    let id: String
    let title: String
    let type: String
    let date: String
    let icon: String
}

#Preview {
    ProfileView(
        childProfile: ChildProfile(
            name: "Andy",
            parentName: "Alex Rivera",
            role: .parent,
            points: 150,
            severity: "Moderate",
            goals: ["Emotional Regulation", "Social Skills"]
        ),
        appointments: [
            Appointment(
                id: "1",
                expertName: "Dr. Sarah",
                expertImg: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=200&h=200&auto=format&fit=crop",
                date: "Oct 28",
                time: "10:00 AM"
            )
        ],
        onLogout: {}
    )
}
