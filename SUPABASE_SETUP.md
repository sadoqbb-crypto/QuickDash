# QuickDash Supabase Setup

QuickDash can use Supabase as the real shared database for:

- company profiles and branding
- menu categories and items
- customer phone-menu orders
- order tracking: taken, preparing, ready
- POS orders and payment status
- cashier shifts
- sales ledger exports

## 1. Open the Supabase project

The organization link is not enough for the app connection:

```text
https://supabase.com/dashboard/org/qwokyjkreypigaxqeekf
```

Open the actual project inside that organization. The app needs the project API settings.

## 2. Run the SQL

Run:

```sql
-- paste the contents of supabase/schema.sql
```

For the internal QuickDash owner/support platform, also run:

```sql
-- paste the contents of supabase/platform_admin.sql
```

## 3. Add the browser keys

From Supabase project settings, copy:

- Project URL
- Publishable / anon key

Put them in:

```text
assets/supabase-config.js
```

Example:

```js
window.QUICKDASH_SUPABASE = {
  url: "https://YOUR_PROJECT_REF.supabase.co",
  anonKey: "YOUR_PUBLIC_ANON_KEY",
  databaseCode: "QD-DEMO-0001"
};
```

Do not put the service-role key in the frontend.

## 4. What changes in QuickDash

Current prototype:

```text
localStorage -> only this browser/computer sees the data
```

Supabase version:

```text
Supabase Postgres -> customer phones, cashier screens, reports, and printer screens all share the same orders
```

The first production bridge uses:

- `app_snapshots`

That table stores the current app database by `database_code`. This lets the static app share real data quickly while we continue moving features into relational tables.

The customer menu will insert rows into:

- `orders`
- `order_items`

The staff Orders screen will update:

- `orders.progress`
- `orders.payment_status`

The customer tracker will read the same order and update when progress changes.

## 5. Next implementation step

After the URL and anon key are available, test:

- `index.html`
- `menu.html`
- `admin.html`

The app should keep `localStorage` as an offline fallback, but Supabase becomes the source of truth when configured.

## 6. Production hardening

Before real customers use it:

- replace prototype RLS policies with company-based policies
- move staff PIN/login to Supabase Auth
- store orders in the relational `orders` and `order_items` tables
- store menu items in `menu_items`
- add payment provider webhooks for subscriptions
- keep service-role keys only on a backend/serverless function
