# SIKERA Design System & Direction

## 1. Product

- **Product:** SIKERA (Sistem Informasi Kesehatan Reproduksi Remaja & Edukasi Mahasiswa)
- **Target Audience:** Mahasiswa perguruan tinggi usia 17–24 tahun dan konselor kesehatan kampus.
- **Primary Goals:** Edukasi kesehatan reproduksi, akses informasi yang terpercaya, asesmen/monitoring, dan dukungan konseling kampus.
- **Design Direction:** Modern, clean, approachable, trustworthy, educational, and medically credible.

---

## 2. Brand Personality & Tone

SIKERA should feel:

- **Bersahabat** — tidak terasa seperti aplikasi rumah sakit yang kaku.
- **Edukatif** — informasi disajikan dengan struktur yang mudah dipahami.
- **Empatik** — menggunakan bahasa yang aman dan tidak menghakimi.
- **Terpercaya** — visual dan interaksi harus memberikan kesan kredibel.
- **Modern** — menggunakan layout sederhana, whitespace yang cukup, dan komponen konsisten.
- **Non-judgmental** — hindari bahasa yang menyalahkan atau mempermalukan pengguna.

### UI Writing

Gunakan:

- Kalimat pendek dan langsung.
- Istilah kesehatan yang tepat, tetapi jelaskan istilah teknis jika diperlukan.
- CTA yang jelas: `Mulai Asesmen`, `Baca Materi`, `Konsultasi`, `Lihat Hasil`.
- Pesan error yang menjelaskan masalah dan tindakan berikutnya.

Hindari:

- Bahasa menakut-nakuti.
- Klaim medis tanpa sumber.
- Istilah promosi berlebihan.
- Copy yang menghakimi kondisi atau pilihan pengguna.

---

## 3. Color System

Palet utama diambil dari referensi warna:

| Token | Color | Usage |
|---|---|---|
| `primary-900` | `#03045E` | Primary dark, navbar, heading kuat, footer, high-emphasis UI |
| `primary-700` | `#0077B6` | Primary action, button, link, active state |
| `primary-500` | `#00B4D8` | Accent, icon, highlight, progress, interactive emphasis |
| `primary-200` | `#90E0EF` | Soft accent, selected background, information surface |
| `primary-50` | `#CAF0F8` | Very light background, cards, educational sections |

### Core Palette

```text
#03045E  Deep Navy
#0077B6  Ocean Blue
#00B4D8  Cyan
#90E0EF  Light Cyan
#CAF0F8  Pale Cyan
```

### Semantic Colors

Semantic colors remain separate from the brand palette and should only be used when their meaning is necessary.

| Semantic Token | Color | Usage |
|---|---|---|
| `success` | `#16803C` | Successful action, completed assessment |
| `warning` | `#B7791F` | Warning, incomplete information |
| `error` | `#C53030` | Validation error, failed request |
| `info` | `#0077B6` | Informational state |

Do not use semantic colors as decorative brand colors.

---

## 4. Light Theme

### Background

- **App Background:** `#F7FCFE`
- **Primary Surface:** `#FFFFFF`
- **Soft Surface:** `#CAF0F8`
- **Elevated Surface:** `#FFFFFF`

### Text

- **Text Primary:** `#03045E`
- **Text Secondary:** `#334E68`
- **Text Muted:** `#627D98`
- **Text On Primary:** `#FFFFFF`

### Borders

- **Border:** `#D6EAF0`
- **Strong Border:** `#90E0EF`

### Recommended Usage

The lightest cyan should be used as a supporting surface rather than covering the entire application. Most content areas should remain white to preserve readability.

---

## 5. Dark Theme

Dark mode should preserve the blue/cyan identity without turning the interface into a glowing neon UI.

### Background

- **App Background:** `#071A2B`
- **Primary Surface:** `#0D2638`
- **Elevated Surface:** `#12354A`
- **Soft Accent Surface:** `#123E52`

### Text

- **Text Primary:** `#F1FBFD`
- **Text Secondary:** `#B8D5DE`
- **Text Muted:** `#86AAB7`
- **Text On Primary:** `#FFFFFF`

### Accent

- **Primary Action:** `#00B4D8`
- **Secondary Action:** `#0077B6`
- **Soft Accent:** `#90E0EF`

### Dark Mode Rule

Avoid using `#03045E` as a large full-screen background in dark mode. It is better suited to high-emphasis elements such as navigation, headers, or selected states.

---

## 6. Color Hierarchy

Use the palette according to visual importance:

```text
#03045E
    ↓
Highest emphasis
Navigation / headings / strong branding

#0077B6
    ↓
Primary interaction
Buttons / links / active states

#00B4D8
    ↓
Accent
Icons / progress / highlights / focus

#90E0EF
    ↓
Supporting UI
Selected surfaces / information blocks

#CAF0F8
    ↓
Soft background
Cards / educational sections / subtle highlights
```

### Color Ratio

Recommended approximate distribution:

- **60%** — White / neutral surfaces
- **20%** — `#CAF0F8` / `#F7FCFE`
- **10%** — `#0077B6`
- **7%** — `#00B4D8` / `#90E0EF`
- **3%** — `#03045E` high-emphasis branding

The exact ratio may vary by page, but dark blue and cyan should not dominate every component simultaneously.

---

## 7. Typography

### Font

Use a clean sans-serif:

1. **Inter** — preferred for web/mobile if available.
2. **Roboto** — acceptable alternative.
3. **System Sans / Cupertino** — fallback.

### Type Scale

| Style | Size | Weight | Usage |
|---|---:|---:|---|
| Display | 32–40px | 700 | Hero / major page title |
| H1 | 28–32px | 700 | Main page heading |
| H2 | 22–26px | 700 | Section heading |
| H3 | 18–20px | 600 | Card/subsection heading |
| Body | 14–16px | 400 | Main content |
| Body Strong | 14–16px | 600 | Emphasis |
| Caption | 12–13px | 400 | Metadata / helper text |
| Button | 14–16px | 600 | CTA |

### Typography Rules

- Body line-height: approximately `1.5`.
- Heading line-height: approximately `1.2`.
- Do not use excessive font weights.
- Avoid ALL CAPS for long text.
- Maintain sufficient contrast between primary and secondary text.

---

## 8. Layout & Spacing

Use an 8px spacing system:

```text
4px   — XS
8px   — SM
16px  — MD
24px  — LG
32px  — XL
48px  — 2XL
64px  — Section
```

### Layout

- Desktop content max-width: `1200–1280px`.
- Mobile horizontal padding: `16px`.
- Tablet horizontal padding: `24px`.
- Desktop horizontal padding: `32px`.
- Use generous whitespace around educational content.
- Avoid dense dashboards with too many cards competing for attention.

---

## 9. Border Radius

Recommended radius system:

```text
8px   — Small controls
12px  — Inputs / compact cards
16px  — Standard cards
20px  — Feature cards
24px  — Hero / prominent surfaces
999px — Pills / badges
```

Use rounded corners consistently. Do not mix many unrelated radius values.

---

## 10. Elevation & Shadow

The interface should feel lightweight.

### Default Card

```css
box-shadow: 0 2px 8px rgba(3, 4, 94, 0.06);
```

### Elevated Card

```css
box-shadow: 0 8px 24px rgba(3, 4, 94, 0.10);
```

Avoid large blurred shadows, glassmorphism, excessive glow, and neon effects.

---

## 11. Buttons

### Primary Button

- Background: `#0077B6`
- Text: `#FFFFFF`
- Hover: darker variant of `#0077B6`
- Active: `#03045E`
- Radius: `12px`
- Minimum height: `44px`

### Secondary Button

- Background: `#CAF0F8`
- Text: `#03045E`
- Border: `#90E0EF`

### Outline Button

- Background: transparent
- Border: `#0077B6`
- Text: `#0077B6`

### Destructive Button

Use semantic `error` only for destructive actions such as deletion or irreversible operations.

---

## 12. Cards

Cards are the primary content container for:

- Educational materials.
- Assessment modules.
- Health information.
- Consultation summaries.
- Statistics.
- Notifications.
- Recommendations.

### Card Anatomy

```text
┌─────────────────────────────────┐
│ Icon / Category                 │
│                                 │
│ Card Title                      │
│ Supporting description          │
│                                 │
│ Metadata / Status               │
│                                 │
│ Primary Action →                │
└─────────────────────────────────┘
```

### Card Rules

- White background in light mode.
- Use `#CAF0F8` selectively for informational cards.
- Do not make every card a different color.
- Maintain consistent padding, generally `16–24px`.

---

## 13. Navigation

### Desktop

Recommended structure:

```text
SIKERA
────────────────────────────
Dashboard
Edukasi
Asesmen
Konseling
Riwayat
Profil
────────────────────────────
Pengaturan
```

### Mobile

Use:

- Bottom navigation for primary destinations.
- Maximum 4–5 primary items.
- Secondary actions inside menus or profile/settings.

### Navigation Colors

- Active: `#0077B6`
- Active background: `#CAF0F8`
- Inactive: `#627D98`
- Strong navigation/header: `#03045E`

---

## 14. Forms & Inputs

Inputs should prioritize clarity because SIKERA handles health-related information.

### Input

- Background: `#FFFFFF`
- Border: `#D6EAF0`
- Focus border: `#0077B6`
- Radius: `12px`
- Minimum height: `44px`

### Validation

Every input must support:

```text
Default
Focus
Filled
Error
Disabled
Loading
```

Error messages must appear close to the related field and explain how to fix the issue.

Example:

> Email belum valid. Gunakan format nama@domain.com.

Avoid vague messages such as:

> Something went wrong.

---

## 15. Data-Driven UX

Every data-driven component must have three explicit states:

### Loading

Use:

- Skeleton loaders.
- Progress indicators for longer operations.

Avoid blocking the entire screen when only one module is loading.

### Empty

Explain why the area is empty and provide a useful next action.

Example:

> Belum ada riwayat asesmen. Mulai asesmen pertama untuk melihat hasil di sini.

### Error

Explain the problem and provide retry/recovery.

Example:

> Data belum dapat dimuat. Periksa koneksi internet lalu coba lagi.

CTA:

`Coba Lagi`

---

## 16. Dashboard Direction

The dashboard should prioritize actionable information.

### Recommended Hierarchy

```text
Welcome / Context
        ↓
Important status or action
        ↓
Quick Actions
        ↓
Assessment / Health Summary
        ↓
Educational Recommendations
        ↓
Recent Activity
```

Do not fill the dashboard with decorative charts that do not support a decision.

---

## 17. Educational Content

Educational pages should prioritize reading comfort.

### Structure

```text
Category
    ↓
Title
    ↓
Short introduction
    ↓
Key information
    ↓
Illustration / supporting visual
    ↓
Detailed explanation
    ↓
Sources / references
    ↓
Related materials
```

### Content Design

- Use short paragraphs.
- Prefer bullets for lists.
- Highlight important facts using subtle cyan surfaces.
- Use `#03045E` for headings.
- Use `#0077B6` for links and actions.
- Do not use decorative gradients behind long-form text.

---

## 18. Status & Badges

Use compact badges with clear semantic meaning.

Examples:

```text
Selesai
Dalam Proses
Belum Dimulai
Perlu Perhatian
Tersedia
```

Recommended visual treatment:

- Neutral: soft grey/blue surface.
- Information: `#CAF0F8` + `#0077B6`.
- Success: light green + `#16803C`.
- Warning: light amber + `#B7791F`.
- Error: light red + `#C53030`.

Do not use badges purely for decoration.

---

## 19. Accessibility

Minimum requirements:

- Tap/click target: **44×44px** minimum.
- Keyboard navigable.
- Visible focus state.
- Sufficient text/background contrast.
- Do not communicate information using color alone.
- Form fields require visible labels.
- Icons should have accessible labels when interactive.
- Support responsive layouts from mobile to desktop.
- No horizontal overflow on standard viewport sizes.

---

## 20. Responsive Breakpoints

Recommended:

```text
Mobile:  < 640px
Tablet:  640–1023px
Desktop: ≥ 1024px
Wide:    ≥ 1280px
```

### Mobile Priority

On mobile:

1. Primary action
2. Important status
3. Core content
4. Secondary information
5. Optional actions

Do not simply shrink the desktop layout. Reflow content based on priority.

---

## 21. Motion

**Dials: ENERGY 2 / RHYTHM 2 / MOTION 1**

Motion should be subtle and functional.

Use:

- 150–250ms transitions.
- Small opacity/position changes.
- Button feedback.
- Skeleton loading.
- Simple page transitions.

Avoid:

- Excessive bouncing.
- Large animated backgrounds.
- Continuous decorative animations.
- Parallax-heavy layouts.
- Animation that delays access to content.

---

## 22. Illustration & Iconography

### Direction

Use:

- Simple line icons.
- Rounded geometry.
- Medical/educational visual language.
- Consistent stroke weight.
- Minimal decorative elements.

Preferred icon color hierarchy:

```text
Primary: #0077B6
Accent:  #00B4D8
Strong:  #03045E
Soft:    #90E0EF
```

Avoid mixing multiple unrelated icon styles.

---

## 23. Gradient Usage

Gradients are allowed only as a restrained brand accent.

Recommended:

```css
background: linear-gradient(
  135deg,
  #03045E 0%,
  #0077B6 55%,
  #00B4D8 100%
);
```

Use gradients for:

- Hero headers.
- Brand banners.
- Login/landing-page accents.
- Selected visual highlights.

Do **not** use gradients for every card, button, background, or section.

### Anti-Slop Rule

No generic:

- Blue-to-purple AI glow.
- Rainbow gradients.
- Neon cyberpunk UI.
- Excessive glassmorphism.
- Decorative glowing blobs without functional purpose.

The SIKERA visual identity should remain **medical, educational, clean, and human**.

---

## 24. Component Design Tokens

Suggested CSS variables:

```css
:root {
  --color-primary-900: #03045E;
  --color-primary-700: #0077B6;
  --color-primary-500: #00B4D8;
  --color-primary-200: #90E0EF;
  --color-primary-50: #CAF0F8;

  --color-background: #F7FCFE;
  --color-surface: #FFFFFF;

  --color-text-primary: #03045E;
  --color-text-secondary: #334E68;
  --color-text-muted: #627D98;

  --color-border: #D6EAF0;

  --color-success: #16803C;
  --color-warning: #B7791F;
  --color-error: #C53030;

  --radius-sm: 8px;
  --radius-md: 12px;
  --radius-lg: 16px;
  --radius-xl: 20px;
  --radius-2xl: 24px;
  --radius-pill: 999px;

  --spacing-1: 4px;
  --spacing-2: 8px;
  --spacing-3: 12px;
  --spacing-4: 16px;
  --spacing-5: 20px;
  --spacing-6: 24px;
  --spacing-8: 32px;
  --spacing-12: 48px;
  --spacing-16: 64px;
}
```

---

## 25. Anti-Slop Adherence

The implementation must follow these rules:

1. No generic AI-themed visual language.
2. No unnecessary gradients.
3. No fake testimonials.
4. No fabricated statistics.
5. No fabricated medical claims.
6. No meaningless dashboard charts.
7. No excessive rounded cards without hierarchy.
8. No excessive shadows or glow.
9. No horizontal scrolling on responsive layouts.
10. Minimum 44px interactive targets.
11. Every data-driven module has Loading, Empty, and Error states.
12. Forms include validation and recovery states.
13. API-dependent features must handle loading, timeout, failure, and retry.
14. Medical/educational content should provide appropriate sources or references.
15. Accessibility must be considered from the component level.
16. Real API integrations must be represented accurately; do not use fake success states in production.
17. Preserve a clear distinction between educational information and personalized medical advice.
18. Visual hierarchy must prioritize user tasks over decoration.

---

## 26. Overall Visual Direction

The final SIKERA interface should visually communicate:

> **Trusted health information, presented simply for students.**

The dominant visual language is:

```text
Deep Navy
   ↓
Trust / Authority

Ocean Blue
   ↓
Interaction / Action

Cyan
   ↓
Energy / Accessibility

Light Cyan
   ↓
Education / Information

White
   ↓
Clarity / Reading Comfort
```

The result should feel like a **modern university health platform**, not a generic medical dashboard and not an AI-generated template.
