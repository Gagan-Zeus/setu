import { z } from 'zod'

/// One definition per shape, shared with the Node service. The server
/// re-validates with the same schema regardless of what the client sent — a
/// browser is not a trust boundary.

export const phone = z
  .string()
  .trim()
  .regex(/^\+?[0-9 ]{10,16}$/, 'Enter a phone number, e.g. +91 98450 11223')

export const email = z.string().trim().toLowerCase().email('Enter a valid email address')

export const phcSchema = z.object({
  name_en: z.string().trim().min(3, 'Name is required'),
  name_kn: z.string().trim().optional().or(z.literal('')),
  phone,
  district_id: z.string().uuid('Choose a district'),
  contact_name: z.string().trim().optional().or(z.literal('')),
  address: z.string().trim().optional().or(z.literal('')),
  latitude: z.coerce.number().min(-90).max(90).optional(),
  longitude: z.coerce.number().min(-180).max(180).optional(),
})
export type PhcInput = z.infer<typeof phcSchema>

/// As printed on the certificate. Upper-cased because a registration number is
/// not case sensitive and the uniqueness index compares it that way.
export const kmcNumber = z
  .string()
  .trim()
  .toUpperCase()
  .min(5, 'Enter the KMC registration number')
  .regex(/^[A-Z0-9-]+$/, 'A registration number is letters, digits and hyphens only')

export const staffSchema = z.object({
  name: z.string().trim().min(3, 'Name is required'),
  email,
  phone,
  employee_code: z.string().trim().min(2, 'Employee code is required'),
  phc_id: z.string().uuid('Choose a PHC'),
  role: z.enum(['doctor', 'asha']),
  // Doctor only. An ASHA worker is not registered with a medical council.
  kmc_registration_number: kmcNumber.optional(),
  // ASHA only.
  villages: z.array(z.string().uuid()).default([]),
  medical_officer_id: z.string().uuid().optional(),
})
export type StaffInput = z.infer<typeof staffSchema>

export const partnerRequestSchema = z.object({
  legal_name: z.string().trim().min(3, 'Legal name is required'),
  type: z.enum(['private_hospital', 'lab', 'ngo']),
  registration_number: z.string().trim().min(3, 'Registration number is required'),
  contact_name: z.string().trim().min(3, 'Contact name is required'),
  contact_email: email,
  contact_phone: phone,
  address: z.string().trim().min(5, 'Address is required'),
  district_id: z.string().uuid().optional(),
  intended_use: z
    .string()
    .trim()
    .min(40, 'Describe the intended use in a sentence or two — at least 40 characters'),
})
export type PartnerRequestInput = z.infer<typeof partnerRequestSchema>

export const rejectionSchema = z.object({
  rejection_reason: z.string().trim().min(10, 'Give a reason the applicant can act on'),
})

/// A CSV row for the bulk ASHA import. Everything arrives as a string and is
/// coerced here, so the dry run reports the same errors the write would hit.
export const ashaCsvRow = z.object({
  name: z.string().trim().min(3),
  email,
  phone,
  employee_code: z.string().trim().min(2),
  villages: z.string().trim().optional().default(''),
})
export type AshaCsvRow = z.infer<typeof ashaCsvRow>
