import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { supabase } from './supabase'
import type {
  AdminUser, ApiKey, Assignment, AuditRow, District, KmcLookup, Mother, PartnerOrg,
  PhiAccessRow, Phc, Staff, Village,
} from './types'

/// Every read goes through RLS as the signed-in admin. A district_admin asking
/// for "all PHCs" gets their districts and nothing else, because the policy
/// decides — not a filter the UI remembers to add.
async function rows<T>(table: string, build: (q: any) => any = (q) => q): Promise<T[]> {
  const { data, error } = await build(supabase.from(table).select('*'))
  if (error) throw new Error(error.message)
  return (data ?? []) as T[]
}

export const keys = {
  me: ['me'] as const,
  districts: ['districts'] as const,
  phcs: ['phcs'] as const,
  villages: ['villages'] as const,
  staff: ['staff'] as const,
  assignments: ['assignments'] as const,
  mothers: ['mothers'] as const,
  partners: ['partners'] as const,
  apiKeys: ['api_keys'] as const,
  audit: ['audit'] as const,
  phi: ['phi'] as const,
}

export function useMe() {
  return useQuery({
    queryKey: keys.me,
    queryFn: async (): Promise<AdminUser | null> => {
      const { data: session } = await supabase.auth.getUser()
      if (!session.user) return null
      const { data, error } = await supabase
        .from('admin_users')
        .select('*')
        .eq('auth_user_id', session.user.id)
        .maybeSingle()
      if (error) throw new Error(error.message)
      return (data as AdminUser) ?? null
    },
    staleTime: 60_000,
  })
}

export const useDistricts = () =>
  useQuery({ queryKey: keys.districts, queryFn: () => rows<District>('districts', (q) => q.order('name')) })

export const usePhcs = () =>
  useQuery({ queryKey: keys.phcs, queryFn: () => rows<Phc>('health_centres', (q) => q.order('name_en')) })

export const useVillages = () =>
  useQuery({ queryKey: keys.villages, queryFn: () => rows<Village>('villages', (q) => q.order('name')) })

export const useStaff = () =>
  useQuery({ queryKey: keys.staff, queryFn: () => rows<Staff>('staff', (q) => q.order('name')) })

export const useAssignments = () =>
  useQuery({
    queryKey: keys.assignments,
    queryFn: () => rows<Assignment>('asha_assignments', (q) => q.eq('active', true)),
  })

export const useMothers = () =>
  useQuery({
    queryKey: keys.mothers,
    queryFn: () => rows<Mother>('mothers', (q) => q.order('name_en').limit(1000)),
  })

export const usePartners = () =>
  useQuery({
    queryKey: keys.partners,
    queryFn: () => rows<PartnerOrg>('partner_orgs', (q) => q.order('requested_at', { ascending: false })),
  })

export const useApiKeys = () =>
  useQuery({
    queryKey: keys.apiKeys,
    queryFn: async (): Promise<ApiKey[]> => {
      // Explicit column list, never select('*'): key_hash is not granted to
      // `authenticated`, so a wildcard would be refused by Postgres outright.
      const { data, error } = await supabase
        .from('api_keys')
        .select(
          'id,partner_org_id,key_prefix,scopes,environment,rate_limit_per_min,' +
            'created_at,last_used_at,revoked_at,revocation_reason',
        )
        .order('created_at', { ascending: false })
      if (error) throw new Error(error.message)
      return (data ?? []) as unknown as ApiKey[]
    },
  })

export const useAudit = (limit = 300) =>
  useQuery({
    queryKey: [...keys.audit, limit],
    queryFn: () =>
      rows<AuditRow>('admin_audit_log', (q) => q.order('created_at', { ascending: false }).limit(limit)),
  })

export const usePhiAccess = (limit = 300) =>
  useQuery({
    queryKey: [...keys.phi, limit],
    queryFn: () =>
      rows<PhiAccessRow>('phi_access_log', (q) => q.order('accessed_at', { ascending: false }).limit(limit)),
  })

/// Reassignment is one RPC, not two writes. Closing the old row and opening the
/// new one from the browser would leave an ASHA reporting to nobody if the
/// connection dropped between them — which is the error state the dashboard
/// exists to shout about.
export function useReassignAsha() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (v: { ashaId: string; medicalOfficerId: string; reason?: string }) => {
      const { error } = await supabase.rpc('admin_reassign_asha', {
        p_asha_id: v.ashaId,
        p_medical_officer_id: v.medicalOfficerId,
        p_reason: v.reason ?? null,
      })
      if (error) throw new Error(error.message)
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: keys.assignments })
      qc.invalidateQueries({ queryKey: keys.audit })
    },
  })
}

export function useCaseloadSize(ashaId: string | null) {
  return useQuery({
    queryKey: ['caseload', ashaId],
    enabled: !!ashaId,
    queryFn: async () => {
      const { data, error } = await supabase.rpc('asha_caseload_size', { p_asha_id: ashaId })
      if (error) throw new Error(error.message)
      return (data as number) ?? 0
    },
  })
}

export function useReassignMother() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (v: { motherId: string; ashaWorkerId: string }) => {
      const { error } = await supabase.rpc('admin_reassign_mother', {
        p_mother_id: v.motherId,
        p_asha_worker_id: v.ashaWorkerId,
      })
      if (error) throw new Error(error.message)
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.mothers }),
  })
}

export function useSetMotherActive() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (v: { motherId: string; active: boolean }) => {
      const { error } = await supabase.rpc('admin_set_mother_active', {
        p_mother_id: v.motherId,
        p_active: v.active,
      })
      if (error) throw new Error(error.message)
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: keys.mothers }),
  })
}

export function useUpsert<T extends object>(table: string, invalidate: readonly unknown[]) {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: async (row: T) => {
      const { error } = await supabase.from(table).upsert(row as any)
      if (error) throw new Error(error.message)
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: invalidate })
      qc.invalidateQueries({ queryKey: keys.audit })
    },
  })
}

/// Looks a registration number up in the council registry.
///
/// A mutation rather than a query: it runs when the administrator asks, not
/// when a component renders, and a half-typed number must not fire a lookup on
/// every keystroke.
export function useKmcLookup() {
  return useMutation({
    mutationFn: async (registrationNumber: string): Promise<KmcLookup> => {
      const { data, error } = await supabase.rpc('kmc_lookup', {
        p_registration_number: registrationNumber,
      })
      if (error) throw new Error(error.message)
      return data as KmcLookup
    },
  })
}

/// The same registry read, as a query rather than a mutation: the review
/// dialog needs the doctor behind a request the moment it opens, and it has
/// only the registration number — since 0009 the contact details live in the
/// register rather than on the request. Enabled only when there is a number,
/// so a request that predates that fires nothing.
export function useKmcRecord(registrationNumber: string | null) {
  return useQuery({
    queryKey: ['kmc', registrationNumber] as const,
    enabled: !!registrationNumber,
    queryFn: async (): Promise<KmcLookup> => {
      const { data, error } = await supabase.rpc('kmc_lookup', {
        p_registration_number: registrationNumber,
      })
      if (error) throw new Error(error.message)
      return data as KmcLookup
    },
  })
}

export interface KmcPublicCheck {
  valid: boolean
  reason?: 'empty' | 'not_in_registry' | 'not_in_good_standing'
  status?: string
  is_demo?: boolean
  registration_number?: string
  full_name?: string
  qualification?: string
  state_medical_council?: string
  email?: string
  phone?: string
}

/// The anonymous half of the registry. It answers only whether a registration
/// is real and in good standing, and gives back the name and contact — never
/// the date of birth, the address or the father's name. A public endpoint
/// returning those would be a directory of doctors' personal details.
export function useKmcVerifyPublic() {
  return useMutation({
    mutationFn: async (registrationNumber: string): Promise<KmcPublicCheck> => {
      const { data, error } = await supabase.rpc('kmc_verify_public', {
        p_registration_number: registrationNumber,
      })
      if (error) throw new Error(error.message)
      return data as KmcPublicCheck
    },
  })
}
