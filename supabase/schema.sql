-- QuickDash Supabase schema
-- Run this in Supabase SQL Editor after creating a new project.

create extension if not exists pgcrypto;

create table if not exists companies (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'QuickDash',
  tagline text default 'Run your restaurant faster',
  phone text,
  email text,
  address text,
  about text,
  accent text default '#F26722',
  logo_url text,
  cover_url text,
  gallery_urls text[] default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists menu_categories (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  name text not null,
  color text default '#F26722',
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  unique(company_id, name)
);

create table if not exists menu_items (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  category_id uuid references menu_categories(id) on delete set null,
  name text not null,
  price integer not null check (price >= 0),
  image_url text,
  sold_out boolean not null default false,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists staff (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  name text not null,
  role text not null default 'Cashier',
  color text default '#1E9E6A',
  pin text not null,
  active boolean not null default true,
  permissions text[] not null default array['pos','orders'],
  created_at timestamptz not null default now()
);

create table if not exists orders (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  order_no text not null,
  order_type text not null default 'Phone menu',
  cashier_id uuid references staff(id) on delete set null,
  cashier_name text default 'Phone menu',
  payment_method text default 'Not paid',
  payment_status text not null default 'pending',
  progress text not null default 'taken' check (progress in ('taken','preparing','ready')),
  subtotal integer not null default 0,
  vat integer not null default 0,
  total integer not null default 0,
  created_at timestamptz not null default now(),
  paid_at timestamptz,
  progress_updated_at timestamptz not null default now(),
  unique(company_id, order_no)
);

create table if not exists order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references orders(id) on delete cascade,
  menu_item_id uuid references menu_items(id) on delete set null,
  name text not null,
  category text,
  section text not null default 'Food',
  qty integer not null check (qty > 0),
  unit_price integer not null check (unit_price >= 0),
  line_total integer not null check (line_total >= 0)
);

create table if not exists cashier_shifts (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  staff_id uuid references staff(id) on delete set null,
  staff_name text not null,
  role text,
  opened_at timestamptz not null default now(),
  closed_at timestamptz,
  orders_count integer not null default 0,
  total integer not null default 0
);

create table if not exists app_snapshots (
  database_code text primary key,
  company_id uuid references companies(id) on delete set null,
  payload jsonb not null default '{}',
  updated_at timestamptz not null default now()
);

create or replace function touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists companies_touch_updated_at on companies;
create trigger companies_touch_updated_at
before update on companies
for each row execute function touch_updated_at();

drop trigger if exists menu_items_touch_updated_at on menu_items;
create trigger menu_items_touch_updated_at
before update on menu_items
for each row execute function touch_updated_at();

alter table companies enable row level security;
alter table menu_categories enable row level security;
alter table menu_items enable row level security;
alter table staff enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;
alter table cashier_shifts enable row level security;
alter table app_snapshots enable row level security;

-- Prototype policies:
-- These let the static prototype read menu data and create customer orders.
-- Tighten these when we add real Supabase Auth/accounts.
drop policy if exists "public read companies" on companies;
create policy "public read companies" on companies for select using (true);

drop policy if exists "public read menu categories" on menu_categories;
create policy "public read menu categories" on menu_categories for select using (true);

drop policy if exists "public read menu items" on menu_items;
create policy "public read menu items" on menu_items for select using (true);

drop policy if exists "public create orders" on orders;
create policy "public create orders" on orders for insert with check (true);

drop policy if exists "public read own/order tracker prototype" on orders;
create policy "public read own/order tracker prototype" on orders for select using (true);

drop policy if exists "public create order items" on order_items;
create policy "public create order items" on order_items for insert with check (true);

drop policy if exists "public read order items" on order_items;
create policy "public read order items" on order_items for select using (true);

-- Temporary staff/admin prototype policies.
drop policy if exists "prototype staff all" on staff;
create policy "prototype staff all" on staff for all using (true) with check (true);

drop policy if exists "prototype order update" on orders;
create policy "prototype order update" on orders for update using (true) with check (true);

drop policy if exists "prototype categories all" on menu_categories;
create policy "prototype categories all" on menu_categories for all using (true) with check (true);

drop policy if exists "prototype menu all" on menu_items;
create policy "prototype menu all" on menu_items for all using (true) with check (true);

drop policy if exists "prototype shifts all" on cashier_shifts;
create policy "prototype shifts all" on cashier_shifts for all using (true) with check (true);

drop policy if exists "prototype app snapshot read" on app_snapshots;
create policy "prototype app snapshot read" on app_snapshots for select using (true);

drop policy if exists "prototype app snapshot write" on app_snapshots;
create policy "prototype app snapshot write" on app_snapshots for insert with check (true);

drop policy if exists "prototype app snapshot update" on app_snapshots;
create policy "prototype app snapshot update" on app_snapshots for update using (true) with check (true);
