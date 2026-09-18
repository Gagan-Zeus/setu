// Render the OTP email for every brand to HTML files you can open in a browser.
//
// The point of this script is that it imports the SAME brands.ts and
// template.ts the deployed function does. A preview that reimplements the
// template is a preview of a different email, and stops being true the first
// time someone edits one and not the other.
//
//   node core/preview_otp_email.mjs && open /tmp/setu-otp/thayi.html
//
// Needs Node 22+ (it strips the TypeScript types on import). Logos resolve
// against the local brand/email/ folder so the preview shows them without the
// bucket existing yet.

import { mkdir, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const fn = resolve(here, "../thayi/supabase/functions/send-email");

const { BRANDS } = await import(pathToFileURL(resolve(fn, "brands.ts")).href);
const { render } = await import(pathToFileURL(resolve(fn, "template.ts")).href);

const out = process.argv[2] ?? "/tmp/setu-otp";
await mkdir(out, { recursive: true });

// Not a real code. Six distinct digits make a wrong letter-spacing or a
// clipped glyph obvious in a way that 000000 would hide.
const CODE = "418273";

for (const [key, brand] of Object.entries(BRANDS)) {
  const logo = pathToFileURL(resolve(here, `../brand/email/${key}.png`)).href;
  const { subject, html, text } = render(brand, CODE, logo);
  await writeFile(`${out}/${key}.html`, html);
  await writeFile(`${out}/${key}.txt`, `Subject: ${subject}\n\n${text}`);
  console.log(`${key.padEnd(6)} ${subject}`);
}

console.log(`\nWritten to ${out}/`);
