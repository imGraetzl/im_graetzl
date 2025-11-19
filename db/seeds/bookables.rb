# frozen_string_literal: true

require Rails.root.join("app/models/bookables/cancellation_policy")

SEED_CANCELLATION_POLICIES = [
  {
    key: "service_low",
    name: "Service – Low",
    description: "Immer kostenlos stornierbar.",
    refund_tiers: [
      { before_hours: 0, refund_percent: 100 }
    ],
    provider_rules: [
      { on: "provider_cancel", fee_percent: 5 }
    ],
    customer_rules: [
      { after_deadline: false, fee_percent: 5 }
    ]
  },
  {
    key: "service_medium",
    name: "Service – Medium",
    description: "Bis 24h kostenlos, danach 80 % Refund.",
    refund_tiers: [
      { before_hours: 24, refund_percent: 100 },
      { before_hours: 0, refund_percent: 80 }
    ],
    provider_rules: [
      { on: "provider_cancel", fee_percent: 5 }
    ],
    customer_rules: [
      { after_deadline: true, fee_percent: 5 }
    ]
  },
  {
    key: "service_high",
    name: "Service – High",
    description: "Bis 48h kostenlos, danach 80 % Refund.",
    refund_tiers: [
      { before_hours: 48, refund_percent: 100 },
      { before_hours: 0, refund_percent: 80 }
    ],
    provider_rules: [
      { on: "provider_cancel", fee_percent: 5 }
    ],
    customer_rules: [
      { after_deadline: true, fee_percent: 5 }
    ]
  },
  {
    key: "event_low",
    name: "Event – Low",
    description: "Immer kostenlos stornierbar.",
    refund_tiers: [
      { before_hours: 0, refund_percent: 100 }
    ],
    provider_rules: [
      { on: "provider_cancel", fee_percent: 5 }
    ],
    customer_rules: [
      { after_deadline: false, fee_percent: 5 }
    ]
  },
  {
    key: "event_medium",
    name: "Event – Medium",
    description: "Bis 24h kostenlos, danach 80 % Refund.",
    refund_tiers: [
      { before_hours: 24, refund_percent: 100 },
      { before_hours: 0, refund_percent: 80 }
    ],
    provider_rules: [
      { on: "provider_cancel", fee_percent: 5 }
    ],
    customer_rules: [
      { after_deadline: true, fee_percent: 5 }
    ]
  },
  {
    key: "event_high",
    name: "Event – High",
    description: "Bis 48h kostenlos, danach 80 % Refund.",
    refund_tiers: [
      { before_hours: 48, refund_percent: 100 },
      { before_hours: 0, refund_percent: 80 }
    ],
    provider_rules: [
      { on: "provider_cancel", fee_percent: 5 }
    ],
    customer_rules: [
      { after_deadline: true, fee_percent: 5 }
    ]
  },
  {
    key: "room_low",
    name: "Room – Low",
    description: "Immer kostenlos stornierbar.",
    refund_tiers: [
      { before_hours: 0, refund_percent: 100 }
    ],
    provider_rules: [
      { on: "provider_cancel", fee_percent: 5 }
    ],
    customer_rules: [
      { after_deadline: false, fee_percent: 5 }
    ]
  },
  {
    key: "room_medium",
    name: "Room – Medium",
    description: "Bis 24h kostenlos, danach kein Refund.",
    refund_tiers: [
      { before_hours: 24, refund_percent: 100 },
      { before_hours: 0, refund_percent: 0 }
    ],
    provider_rules: [
      { on: "provider_cancel", fee_percent: 5 }
    ],
    customer_rules: [
      { after_deadline: true, fee_percent: 5 }
    ]
  },
  {
    key: "room_high",
    name: "Room – High",
    description: "Bis 72h kostenlos, danach kein Refund.",
    refund_tiers: [
      { before_hours: 72, refund_percent: 100 },
      { before_hours: 0, refund_percent: 0 }
    ],
    provider_rules: [
      { on: "provider_cancel", fee_percent: 5 }
    ],
    customer_rules: [
      { after_deadline: true, fee_percent: 5 }
    ]
  }
].freeze

SEED_CANCELLATION_POLICIES.each do |policy|
record = Bookables::CancellationPolicy.find_or_initialize_by(key: policy[:key])
  record.assign_attributes(
    name: policy[:name],
    description: policy[:description],
    rules: {
      refund_tiers: policy[:refund_tiers],
      provider_rules: policy[:provider_rules],
      customer_rules: policy[:customer_rules]
    }
  )
  record.save!
end
