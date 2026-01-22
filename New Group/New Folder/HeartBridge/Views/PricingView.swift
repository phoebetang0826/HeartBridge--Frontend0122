//
//  PricingView.swift
//  HeartBridge
//
//  Created by Phoebe Tang on 1/21/26.
//

import SwiftUI

struct PricingView: View {
    let role: UserRole
    let onSelect: (SubscriptionTier) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var activeTab: String
    
    init(role: UserRole, onSelect: @escaping (SubscriptionTier) -> Void) {
        self.role = role
        self.onSelect = onSelect
        _activeTab = State(initialValue: role == .expert ? "Clinicians" : "Parents")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                headerSection
                    .padding(.horizontal, 32)
                    .padding(.top, 32)
                    .padding(.bottom, 40)
                
                // Tab selector
                tabSelector
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                
                // Plans
                if activeTab == "Parents" {
                    parentPlansView
                        .padding(.horizontal, 32)
                } else {
                    expertPlansView
                        .padding(.horizontal, 32)
                }
                
                // Footer
                footerText
                    .padding(.horizontal, 32)
                    .padding(.top, 48)
                    .padding(.bottom, 80)
            }
        }
        .background(Color.white)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("Revenue Stream: B2C/2B Subscription Fees")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.primary.opacity(0.9))
                .tracking(-1)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 6) {
            ForEach(["Parents", "Clinicians"], id: \.self) { tab in
                Button(action: { activeTab = tab }) {
                    Text(tab)
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(activeTab == tab ? .white : .gray)
                        .textCase(.uppercase)
                        .tracking(2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(activeTab == tab ? Color.primary : Color.clear)
                                .shadow(color: activeTab == tab ? Color.primary.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.1))
        )
        .frame(maxWidth: 300)
    }
    
    // MARK: - Parent Plans
    
    private var parentPlansView: some View {
        VStack(spacing: 24) {
            ForEach(parentPlans) { plan in
                parentPlanCard(plan)
            }
        }
    }
    
    private func parentPlanCard(_ plan: ParentPlan) -> some View {
        Button(action: {
            if let tier = SubscriptionTier(rawValue: plan.id) {
                onSelect(tier)
                dismiss()
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Popular badge
                if plan.popular {
                    Text("Most Popular")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .tracking(2)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.primary)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                        .offset(y: -20)
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(plan.name)
                                    .font(.system(size: 20, weight: .black, design: .rounded))
                                    .foregroundColor(.primary.opacity(0.9))
                                
                                Text("(Subscription)")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            
                            Text(plan.price)
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.primary)
                                .tracking(-1)
                        }
                        
                        Spacer()
                        
                        if plan.id != "free" {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "applewatch")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.primary)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                    
                    // Features
                    VStack(spacing: 16) {
                        ForEach(plan.features) { feature in
                            featureRow(feature)
                        }
                    }
                    
                    // Core plan special button
                    if plan.id == "core" {
                        Text("Select Core Plan + Free Wearable")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .textCase(.uppercase)
                            .tracking(2)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.primary)
                                    .shadow(color: .primary.opacity(0.3), radius: 20, x: 0, y: 10)
                            )
                    }
                }
                .padding(32)
            }
            .background(
                RoundedRectangle(cornerRadius: 44)
                    .fill(plan.popular ? Color.primary.opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 44)
                            .stroke(plan.popular ? Color.primary : Color.gray.opacity(0.2), lineWidth: 4)
                    )
                    .shadow(
                        color: plan.popular ? Color.primary.opacity(0.3) : Color.black.opacity(0.1),
                        radius: plan.popular ? 20 : 10,
                        x: 0,
                        y: plan.popular ? 10 : 5
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func featureRow(_ feature: PlanFeature) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Status icon
            RoundedRectangle(cornerRadius: 8)
                .fill(feature.status == .full ? Color.green : feature.status == .partial ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
                .frame(width: 24, height: 24)
                .overlay(
                    Image(systemName: feature.status == .none ? "xmark" : "checkmark")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(feature.status == .full ? .white : feature.status == .partial ? .orange : .gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.label)
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                Text(feature.desc)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .opacity(0.8)
            }
        }
    }
    
    // MARK: - Expert Plans
    
    private var expertPlansView: some View {
        VStack(spacing: 24) {
            ForEach(expertPlans) { plan in
                expertPlanCard(plan)
            }
        }
    }
    
    private func expertPlanCard(_ plan: ExpertPlan) -> some View {
        Button(action: {
            if let tier = SubscriptionTier(rawValue: plan.id) {
                onSelect(tier)
                dismiss()
            }
        }) {
            VStack(alignment: .leading, spacing: 16) {
                Text(plan.name)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.primary.opacity(0.9))
                
                Text(plan.price)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(plan.id == "free" ? .gray : .primary)
                    .tracking(-1)
                
                Text(plan.description)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                    .tracking(2)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 44)
                    .fill(plan.id == "individual" ? Color.primary.opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 44)
                            .stroke(plan.id == "individual" ? Color.primary : Color.gray.opacity(0.2), lineWidth: 4)
                    )
                    .shadow(
                        color: plan.id == "individual" ? Color.primary.opacity(0.3) : Color.black.opacity(0.1),
                        radius: plan.id == "individual" ? 20 : 10,
                        x: 0,
                        y: plan.id == "individual" ? 10 : 5
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Footer
    
    private var footerText: some View {
        Text("All plans include secure data encryption & HIPAA compliance. Wearable device ships in 3-5 business days.")
            .font(.system(size: 9, weight: .black, design: .rounded))
            .foregroundColor(.gray)
            .textCase(.uppercase)
            .tracking(2)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
    }
    
    // MARK: - Data Models
    
    private enum FeatureStatus {
        case full
        case partial
        case none
    }
    
    private struct PlanFeature: Identifiable {
        let id = UUID()
        let label: String
        let status: FeatureStatus
        let desc: String
    }
    
    private struct ParentPlan: Identifiable {
        let id: String
        let name: String
        let price: String
        let popular: Bool
        let features: [PlanFeature]
    }
    
    private struct ExpertPlan: Identifiable {
        let id: String
        let name: String
        let price: String
        let description: String
    }
    
    private var parentPlans: [ParentPlan] {
        [
            ParentPlan(
                id: "free",
                name: "Free",
                price: "$0",
                popular: false,
                features: [
                    PlanFeature(label: "Wearable & Context", status: .none, desc: "No accurate data"),
                    PlanFeature(label: "Predictive Score", status: .partial, desc: "Behavior-based only"),
                    PlanFeature(label: "Recording", status: .partial, desc: "Real-time only (no history)"),
                    PlanFeature(label: "BCBA Access", status: .partial, desc: "Up to 5 therapists"),
                    PlanFeature(label: "Community", status: .partial, desc: "Limited access")
                ]
            ),
            ParentPlan(
                id: "core",
                name: "Core",
                price: "$29/mo",
                popular: true,
                features: [
                    PlanFeature(label: "Wearable & Context", status: .full, desc: "Accurate wearable data"),
                    PlanFeature(label: "Predictive Score", status: .full, desc: "ML-driven risk prediction"),
                    PlanFeature(label: "Recording", status: .full, desc: "Saved history"),
                    PlanFeature(label: "BCBA Access", status: .full, desc: "Unlimited"),
                    PlanFeature(label: "Community", status: .full, desc: "Full access")
                ]
            ),
            ParentPlan(
                id: "plus",
                name: "Plus",
                price: "$49/mo",
                popular: false,
                features: [
                    PlanFeature(label: "Wearable & Context", status: .full, desc: "Wearable + Peer benchmark"),
                    PlanFeature(label: "Predictive Score", status: .full, desc: "ML prediction + peer-adjusted"),
                    PlanFeature(label: "Recording", status: .full, desc: "Saved + peer comparison"),
                    PlanFeature(label: "BCBA Access", status: .full, desc: "Unlimited + priority"),
                    PlanFeature(label: "Community", status: .full, desc: "Full + priority responses")
                ]
            )
        ]
    }
    
    private var expertPlans: [ExpertPlan] {
        [
            ExpertPlan(
                id: "free",
                name: "Free",
                price: "$0",
                description: "Baseline features for new practitioners"
            ),
            ExpertPlan(
                id: "individual",
                name: "Individual",
                price: "$79/mo • $799/yr",
                description: "Full toolkit for solo clinicians"
            ),
            ExpertPlan(
                id: "bundle",
                name: "Clinic Bundle",
                price: "($69/seat • $699/yr for 10+ seats)",
                description: "Enterprise solutions for large clinics"
            )
        ]
    }
}

#Preview {
    PricingView(role: .parent) { _ in }
}
