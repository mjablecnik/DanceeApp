/**
 * Sets up Directus collections for profile-page features:
 *   - legal_pages + legal_pages_translations (Terms of Use, Privacy Policy)
 *   - contact_messages
 *   - Extended custom fields on directus_users
 *
 * Usage:
 *   bun run scripts/setup-profile-collections.ts
 */

import * as dotenv from "dotenv";

dotenv.config();

const DIRECTUS_BASE_URL = process.env.DIRECTUS_BASE_URL ?? "";
const DIRECTUS_ACCESS_TOKEN = process.env.DIRECTUS_ACCESS_TOKEN ?? "";

function authHeaders(): Record<string, string> {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${DIRECTUS_ACCESS_TOKEN}`,
  };
}

async function directusGet(path: string): Promise<unknown> {
  const response = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    headers: authHeaders(),
    signal: AbortSignal.timeout(30000),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`GET ${path} failed ${response.status}: ${text}`);
  }
  return response.json();
}

async function directusPost(path: string, body: unknown): Promise<unknown> {
  const response = await fetch(`${DIRECTUS_BASE_URL}${path}`, {
    method: "POST",
    headers: authHeaders(),
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(30000),
  });
  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`POST ${path} failed ${response.status}: ${text}`);
  }
  return response.json();
}

async function collectionExists(name: string): Promise<boolean> {
  try {
    const data = await directusGet(`/collections/${name}`) as { data?: unknown };
    return !!data?.data;
  } catch {
    return false;
  }
}

async function fieldExists(collection: string, field: string): Promise<boolean> {
  try {
    const data = await directusGet(`/fields/${collection}/${field}`) as { data?: unknown };
    return !!data?.data;
  } catch {
    return false;
  }
}

async function createCollectionIfNotExists(
  name: string,
  meta: Record<string, unknown> = {},
  schema: Record<string, unknown> | null = {},
): Promise<void> {
  if (await collectionExists(name)) {
    return;
  }
  await directusPost("/collections", { collection: name, meta, schema });
  console.log(`Created collection "${name}".`);
}

async function createFieldIfNotExists(
  collection: string,
  field: string,
  type: string,
  meta: Record<string, unknown> = {},
  schema: Record<string, unknown> | null = {},
): Promise<void> {
  if (await fieldExists(collection, field)) {
    return;
  }
  await directusPost(`/fields/${collection}`, { field, type, meta, schema });
  console.log(`Created field "${collection}.${field}".`);
}

// ---- legal_pages collection ----

async function setupLegalPagesCollection(): Promise<void> {
  await createCollectionIfNotExists("legal_pages", { singleton: false });

  await createFieldIfNotExists("legal_pages", "slug", "string", {
    interface: "input",
    required: true,
    unique: true,
    note: "URL slug: terms-of-use | privacy-policy",
  }, { is_nullable: false, max_length: 100, is_unique: true });

  await createFieldIfNotExists("legal_pages", "status", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "published", text: "Published" },
        { value: "draft", text: "Draft" },
      ],
    },
    default_value: "published",
  }, { is_nullable: false, max_length: 50, default_value: "published" });
}

// ---- legal_pages_translations collection ----

async function setupLegalPagesTranslationsCollection(): Promise<void> {
  await createCollectionIfNotExists("legal_pages_translations", { singleton: false });

  await createFieldIfNotExists("legal_pages_translations", "legal_pages_id", "integer", {
    interface: "select-dropdown-m2o",
    hidden: true,
  }, { is_nullable: true });

  await createFieldIfNotExists("legal_pages_translations", "languages_code", "string", {
    interface: "select-dropdown-m2o",
    hidden: true,
  }, { is_nullable: true, max_length: 10 });

  await createFieldIfNotExists("legal_pages_translations", "title", "string", {
    interface: "input",
    required: true,
  }, { is_nullable: false, max_length: 255 });

  await createFieldIfNotExists("legal_pages_translations", "content", "text", {
    interface: "input-rich-text-md",
    note: "Markdown content for this legal page",
  }, { is_nullable: true });
}

// ---- legal_pages <-> legal_pages_translations relation ----

async function setupLegalPagesTranslationsRelation(): Promise<void> {
  try {
    const data = await directusGet("/relations/legal_pages/translations") as { data?: unknown };
    if (data?.data) {
      return;
    }
  } catch {
    // Not found, proceed to create
  }

  await createFieldIfNotExists("legal_pages", "translations", "alias", {
    interface: "list-o2m",
    options: {
      template: "{{languages_code}} — {{title}}",
      enableCreate: false,
      enableSelect: false,
    },
    display: "related-values",
    display_options: {
      template: "{{languages_code}} — {{title}}",
    },
    special: ["translations"],
  }, null);

  try {
    await directusPost("/relations", {
      collection: "legal_pages_translations",
      field: "legal_pages_id",
      related_collection: "legal_pages",
      meta: {
        one_collection: "legal_pages",
        many_collection: "legal_pages_translations",
        many_field: "legal_pages_id",
        one_field: "translations",
        one_collection_field: null,
        one_allowed_collections: null,
        junction_field: "languages_code",
        sort_field: null,
      },
      schema: {
        on_delete: "CASCADE",
      },
    });
    console.log(`Created relation legal_pages <-> legal_pages_translations.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }

  try {
    await directusPost("/relations", {
      collection: "legal_pages_translations",
      field: "languages_code",
      related_collection: "languages",
      meta: {
        one_collection: "languages",
        many_collection: "legal_pages_translations",
        many_field: "languages_code",
        one_field: null,
      },
      schema: {},
    });
    console.log(`Created relation legal_pages_translations <-> languages.`);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (msg.includes("already exists") || msg.includes("409") || msg.includes("already has an associated relationship")) {
      // already exists, skip silently
    } else {
      throw err;
    }
  }
}

// ---- Seed legal_pages records ----

async function seedLegalPages(): Promise<void> {
  const pages = [
    { slug: "terms-of-use", status: "published" },
    { slug: "privacy-policy", status: "published" },
  ];

  for (const page of pages) {
    const filter = encodeURIComponent(JSON.stringify({ slug: { _eq: page.slug } }));
    try {
      const existing = await directusGet(
        `/items/legal_pages?filter=${filter}&fields=id&limit=1`,
      ) as { data?: unknown[] };
      if (existing?.data && existing.data.length > 0) {
        continue;
      }
    } catch {
      // Not found, create it
    }
    try {
      await directusPost("/items/legal_pages", page);
      console.log(`Seeded legal_pages "${page.slug}".`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      if (msg.includes("already exists") || msg.includes("409") || msg.includes("unique")) {
        // already exists, skip silently
      } else {
        throw err;
      }
    }
  }
}

// ---- Seed legal_pages_translations records ----

const LEGAL_PAGES_SEED: Array<{
  slug: string;
  languages_code: string;
  title: string;
  content: string;
}> = [
  // Terms of Use — en
  {
    slug: "terms-of-use",
    languages_code: "en",
    title: "Terms of Use",
    content: `# Terms of Use

Welcome to Dancee. By using this application you agree to the following terms.

## 1. Acceptance of Terms

By accessing or using Dancee, you agree to be bound by these Terms of Use.

## 2. Use of the Service

You may use Dancee for personal, non-commercial purposes only.

## 3. User Content

You are responsible for any content you submit through the application.

## 4. Limitation of Liability

Dancee is provided "as is" without any warranties. We are not liable for any damages arising from your use of the service.

## 5. Changes to Terms

We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of updated terms.

## 6. Contact

If you have questions, please use the contact form in the app.
`,
  },
  // Terms of Use — cs
  {
    slug: "terms-of-use",
    languages_code: "cs",
    title: "Podmínky použití",
    content: `# Podmínky použití

Vítejte v aplikaci Dancee. Používáním této aplikace souhlasíte s následujícími podmínkami.

## 1. Přijetí podmínek

Přístupem k aplikaci Dancee nebo jejím používáním souhlasíte s těmito podmínkami použití.

## 2. Používání služby

Aplikaci Dancee můžete používat pouze pro osobní, nekomerční účely.

## 3. Obsah uživatele

Jste zodpovědní za veškerý obsah, který prostřednictvím aplikace odešlete.

## 4. Omezení odpovědnosti

Dancee je poskytována „tak jak je" bez jakýchkoli záruk. Neneseme odpovědnost za žádné škody vzniklé v důsledku vašeho používání služby.

## 5. Změny podmínek

Vyhrazujeme si právo tyto podmínky kdykoli upravit. Pokračující používání aplikace představuje přijetí aktualizovaných podmínek.

## 6. Kontakt

Máte-li otázky, použijte prosím kontaktní formulář v aplikaci.
`,
  },
  // Terms of Use — es
  {
    slug: "terms-of-use",
    languages_code: "es",
    title: "Términos de uso",
    content: `# Términos de uso

Bienvenido a Dancee. Al usar esta aplicación, aceptas los siguientes términos.

## 1. Aceptación de los términos

Al acceder o usar Dancee, aceptas estar sujeto a estos Términos de uso.

## 2. Uso del servicio

Puedes usar Dancee únicamente para fines personales y no comerciales.

## 3. Contenido del usuario

Eres responsable de cualquier contenido que envíes a través de la aplicación.

## 4. Limitación de responsabilidad

Dancee se proporciona "tal cual" sin ninguna garantía. No somos responsables de ningún daño derivado del uso del servicio.

## 5. Cambios en los términos

Nos reservamos el derecho de modificar estos términos en cualquier momento. El uso continuado de la aplicación constituye la aceptación de los términos actualizados.

## 6. Contacto

Si tienes preguntas, utiliza el formulario de contacto en la aplicación.
`,
  },
  // Privacy Policy — en
  {
    slug: "privacy-policy",
    languages_code: "en",
    title: "Privacy Policy",
    content: `# Privacy Policy

Your privacy is important to us. This policy explains how we collect and use your data.

## 1. Data We Collect

We collect the information you provide when registering: name, email address, and optional profile details (phone, city, bio, dance preferences).

## 2. How We Use Your Data

We use your data to provide and improve the Dancee service, including personalizing your experience.

## 3. Data Storage

Your data is stored securely in our backend systems. We do not sell your data to third parties.

## 4. Your Rights

You may request access to, correction of, or deletion of your personal data at any time by contacting us via the contact form.

## 5. Cookies

Dancee may use session tokens to maintain your login state. No advertising cookies are used.

## 6. Changes to This Policy

We may update this policy periodically. We will notify you of significant changes through the app.
`,
  },
  // Privacy Policy — cs
  {
    slug: "privacy-policy",
    languages_code: "cs",
    title: "Zásady ochrany osobních údajů",
    content: `# Zásady ochrany osobních údajů

Vaše soukromí je pro nás důležité. Tyto zásady vysvětlují, jak shromažďujeme a používáme vaše data.

## 1. Data, která shromažďujeme

Shromažďujeme informace, které poskytnete při registraci: jméno, e-mailovou adresu a volitelné údaje profilu (telefon, město, bio, taneční preference).

## 2. Jak vaše data používáme

Vaše data používáme k poskytování a zlepšování služby Dancee, včetně personalizace vašeho zážitku.

## 3. Ukládání dat

Vaše data jsou bezpečně uložena v našich backendových systémech. Vaše data neprodáváme třetím stranám.

## 4. Vaše práva

Kdykoli můžete požádat o přístup k vašim osobním údajům, jejich opravu nebo výmaz prostřednictvím kontaktního formuláře.

## 5. Cookies

Dancee může používat session tokeny k zachování vašeho přihlášení. Reklamní cookies nepoužíváme.

## 6. Změny těchto zásad

Tyto zásady můžeme pravidelně aktualizovat. O významných změnách vás budeme informovat prostřednictvím aplikace.
`,
  },
  // Privacy Policy — es
  {
    slug: "privacy-policy",
    languages_code: "es",
    title: "Política de privacidad",
    content: `# Política de privacidad

Tu privacidad es importante para nosotros. Esta política explica cómo recopilamos y usamos tus datos.

## 1. Datos que recopilamos

Recopilamos la información que proporcionas al registrarte: nombre, dirección de correo electrónico y detalles opcionales del perfil (teléfono, ciudad, bio, preferencias de baile).

## 2. Cómo usamos tus datos

Usamos tus datos para proporcionar y mejorar el servicio de Dancee, incluida la personalización de tu experiencia.

## 3. Almacenamiento de datos

Tus datos se almacenan de forma segura en nuestros sistemas backend. No vendemos tus datos a terceros.

## 4. Tus derechos

Puedes solicitar el acceso, la corrección o la eliminación de tus datos personales en cualquier momento a través del formulario de contacto.

## 5. Cookies

Dancee puede usar tokens de sesión para mantener tu estado de inicio de sesión. No se usan cookies de publicidad.

## 6. Cambios en esta política

Podemos actualizar esta política periódicamente. Te notificaremos sobre cambios significativos a través de la aplicación.
`,
  },
];

async function seedLegalPagesTranslations(): Promise<void> {
  // Fetch legal pages to map slug -> id
  const pagesRes = await directusGet("/items/legal_pages?fields=id,slug&limit=-1") as {
    data?: Array<{ id: number; slug: string }>;
  };
  const pages = pagesRes?.data ?? [];
  const slugToId: Record<string, number> = {};
  for (const p of pages) {
    slugToId[p.slug] = p.id;
  }

  for (const seed of LEGAL_PAGES_SEED) {
    const legalPageId = slugToId[seed.slug];
    if (!legalPageId) {
      console.warn(`Legal page "${seed.slug}" not found — skipping translation seed.`);
      continue;
    }

    const filter = encodeURIComponent(
      JSON.stringify({
        _and: [
          { legal_pages_id: { _eq: legalPageId } },
          { languages_code: { _eq: seed.languages_code } },
        ],
      }),
    );

    try {
      const existing = await directusGet(
        `/items/legal_pages_translations?filter=${filter}&fields=id&limit=1`,
      ) as { data?: unknown[] };
      if (existing?.data && existing.data.length > 0) {
        continue;
      }
    } catch {
      // Not found, create it
    }

    try {
      await directusPost("/items/legal_pages_translations", {
        legal_pages_id: legalPageId,
        languages_code: seed.languages_code,
        title: seed.title,
        content: seed.content,
      });
      console.log(`Seeded legal_pages_translations "${seed.slug}" (${seed.languages_code}).`);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      if (msg.includes("already exists") || msg.includes("409") || msg.includes("unique")) {
        // already exists, skip silently
      } else {
        throw err;
      }
    }
  }
}

// ---- contact_messages collection ----

async function setupContactMessagesCollection(): Promise<void> {
  await createCollectionIfNotExists("contact_messages", {
    singleton: false,
    sort_field: null,
  });

  await createFieldIfNotExists("contact_messages", "type", "string", {
    interface: "select-dropdown",
    required: true,
    options: {
      choices: [
        { value: "bug", text: "Bug Report" },
        { value: "feature", text: "Feature Request" },
        { value: "feedback", text: "Feedback" },
        { value: "other", text: "Other" },
      ],
    },
  }, { is_nullable: false, max_length: 50 });

  await createFieldIfNotExists("contact_messages", "title", "string", {
    interface: "input",
    required: true,
  }, { is_nullable: false, max_length: 512 });

  await createFieldIfNotExists("contact_messages", "message", "text", {
    interface: "input-multiline",
    required: true,
  }, { is_nullable: false });

  await createFieldIfNotExists("contact_messages", "reply_email", "string", {
    interface: "input",
    required: true,
    options: { type: "email" },
  }, { is_nullable: false, max_length: 255 });

  await createFieldIfNotExists("contact_messages", "phone", "string", {
    interface: "input",
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("contact_messages", "device_info", "json", {
    interface: "input-code",
    options: { language: "json" },
    note: "JSON: { app_version, device_model, os_version, firebase_uid }",
  }, { is_nullable: true });

  await createFieldIfNotExists("contact_messages", "date_created", "dateTime", {
    interface: "datetime",
    readonly: true,
    special: ["date-created"],
    display: "datetime",
  }, { is_nullable: true });
}

// ---- Extend directus_users with custom profile fields ----

async function setupDirectusUserProfileFields(): Promise<void> {
  // firebase_uid — set by the Firebase auth extension; ensure it exists
  await createFieldIfNotExists("directus_users", "firebase_uid", "string", {
    interface: "input",
    note: "Firebase UID from the Firebase Auth extension",
  }, { is_nullable: true, max_length: 128 });

  await createFieldIfNotExists("directus_users", "phone", "string", {
    interface: "input",
    note: "User's phone number",
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("directus_users", "city", "string", {
    interface: "input",
    note: "User's city",
  }, { is_nullable: true, max_length: 255 });

  await createFieldIfNotExists("directus_users", "bio", "text", {
    interface: "input-multiline",
    note: "User bio / short description",
  }, { is_nullable: true });

  await createFieldIfNotExists("directus_users", "dance_tags", "json", {
    interface: "input-code",
    options: { language: "json" },
    note: "Array of dance style codes, e.g. [\"salsa\", \"bachata\"]",
  }, { is_nullable: true });

  await createFieldIfNotExists("directus_users", "experience_level", "string", {
    interface: "select-dropdown",
    options: {
      choices: [
        { value: "beginner", text: "Beginner" },
        { value: "intermediate", text: "Intermediate" },
        { value: "advanced", text: "Advanced" },
        { value: "expert", text: "Expert" },
      ],
    },
    note: "User's dance experience level",
  }, { is_nullable: true, max_length: 50 });

  await createFieldIfNotExists("directus_users", "notification_preferences", "json", {
    interface: "input-code",
    options: { language: "json" },
    note: "Notification preferences, e.g. {\"new_events\": true, \"event_reminders\": true, \"marketing\": false}",
  }, { is_nullable: true });
}

// ---- Main ----

async function main(): Promise<void> {
  if (!DIRECTUS_BASE_URL || !DIRECTUS_ACCESS_TOKEN) {
    throw new Error("DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN must be set in .env");
  }

  console.log("Setting up profile-page Directus collections...\n");

  await setupLegalPagesCollection();
  await setupLegalPagesTranslationsCollection();
  await setupLegalPagesTranslationsRelation();
  await seedLegalPages();
  await seedLegalPagesTranslations();

  await setupContactMessagesCollection();

  await setupDirectusUserProfileFields();

  console.log("\nProfile collections setup complete.");
}

export const ready = main().catch((err) => {
  console.error("Setup failed:", err);
  process.exit(1);
});
