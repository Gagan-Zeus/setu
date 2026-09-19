export type AdminRole = 'super_admin' | 'district_admin' | 'viewer'

export interface AdminUser {
  id: string
  auth_user_id: string | null
  full_name: string
  email: string
  role: AdminRole
  active: boolean
}

export interface District { id: string; name: string; state: string }

export interface Phc {
  id: string
  name_en: string
  name_kn: string | null
  phone: string
  district_id: string | null
  contact_name: string | null
  address: string | null
  // What every ASHA posted here inherits as her location until she pins her
  // own sub-centre, and so what decides which worker a mother is shown first.
  latitude: number | null
  longitude: number | null
  active: boolean
}

export interface Village {
  id: string; name: string; phc_id: string | null; district_id: string | null
  population_estimate: number | null; active: boolean
}

export interface Staff {
  id: string
  auth_user_id: string | null
  name: string
  email: string | null
  phone: string | null
  role: 'asha' | 'doctor'
  phc_id: string | null
  district_id: string | null
  employee_code: string | null
  kmc_registration_number: string | null
  active: boolean
}

export interface Assignment {
  id: string
  asha_id: string
  medical_officer_id: string
  phc_id: string
  villages: string[]
  assigned_at: string
  active: boolean
}

export interface Mother {
  id: string
  thayi_card_number: string
  name_en: string
  village_en: string | null
  sub_centre: string | null
  risk_level: 'green' | 'amber' | 'red'
  phc_id: string | null
  asha_worker_id: string | null
  active: boolean
  is_sandbox: boolean
  last_visit_date: string | null
}

export type PartnerStatus = 'pending' | 'approved' | 'rejected' | 'suspended'

export interface PartnerOrg {
  id: string
  legal_name: string
  type: 'private_hospital' | 'lab' | 'ngo'
  registration_number: string
  /// Nullable since 0009. A request now carries the KMC registration of the
  /// doctor behind it and the contact comes from the register, so these three
  /// are filled only on the rows that predate that. Typed as `string` they
  /// rendered as the literal "null · null · null" on every newer request.
  contact_name: string | null
  contact_email: string | null
  contact_phone: string | null
  /// The named, registered doctor accountable for the request. A hospital is
  /// not a person and cannot be struck off.
  kmc_registration_number: string | null
  /// What the register said at the moment access was granted. The register is
  /// live and a doctor may lapse afterwards; this is the question an audit
  /// asks.
  kmc_verified_at: string | null
  kmc_status_at_request: string | null
  address: string
  district_id: string | null
  intended_use: string
  status: PartnerStatus
  requested_at: string
  reviewed_at: string | null
  rejection_reason: string | null
  live_access_granted_at: string | null
}

export interface ApiKey {
  id: string
  partner_org_id: string
  key_prefix: string
  scopes: string[]
  environment: 'sandbox' | 'live'
  rate_limit_per_min: number
  created_at: string
  last_used_at: string | null
  revoked_at: string | null
  revocation_reason: string | null
  // key_hash is deliberately absent: it is not granted to `authenticated`, so
  // selecting it would be refused by Postgres, not merely hidden here.
}

export interface AuditRow {
  id: number
  actor_email: string | null
  action: 'insert' | 'update' | 'delete'
  entity_type: string
  entity_id: string | null
  before: unknown
  after: unknown
  created_at: string
}

export interface PhiAccessRow {
  id: number
  partner_org_id: string | null
  mother_id: string | null
  endpoint: string
  qr_token_jti: string | null
  ip_address: string | null
  response_status: number
  failure_reason: string | null
  accessed_at: string
}

export interface KmcDoctor {
  registration_number: string
  full_name: string
  father_name: string | null
  gender: string | null
  date_of_birth: string | null
  qualification: string
  university: string
  year_of_passing: number | null
  registration_date: string
  state_medical_council: string
  status: 'active' | 'renewed' | 'expired' | 'suspended'
  renewal_due: string | null
  address: string | null
  phone: string | null
  email: string | null
}

export interface KmcLookup {
  found: boolean
  reason?: 'empty' | 'not_in_registry'
  is_demo?: boolean
  in_good_standing?: boolean
  already_registered?: boolean
  existing_staff?: { id: string; name: string; email: string | null; phc_id: string | null }
  doctor?: KmcDoctor
}
