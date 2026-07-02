-- QuickDash internal platform/admin schema
-- Run this after schema.sql when you are ready to build the owner/support platform.

alter table companies add column if not exists database_code text unique;
alter table companies add column if not exists account_status text not null default 'trial'
  check (account_status in ('trial','active','past_due','suspended'));
alter table companies add column if not exists plan_name text not null default 'Starter';

create table if not exists platform_users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  full_name text not null,
  role text not null default 'support'
    check (role in ('owner','admin','support','billing')),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists subscription_plans (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  monthly_price integer not null default 0,
  staff_limit integer not null default 3,
  branch_limit integer not null default 1,
  monthly_order_limit integer not null default 500,
  features text[] not null default '{}',
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists company_subscriptions (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  plan_id uuid references subscription_plans(id) on delete set null,
  status text not null default 'trial'
    check (status in ('trial','active','past_due','cancelled','suspended')),
  current_period_start timestamptz default now(),
  current_period_end timestamptz,
  payment_provider text,
  provider_customer_id text,
  provider_subscription_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists database_health_checks (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references companies(id) on delete cascade,
  database_code text not null,
  status text not null default 'healthy'
    check (status in ('healthy','warning','critical')),
  checks jsonb not null default '{}',
  checked_by uuid references platform_users(id) on delete set null,
  checked_at timestamptz not null default now()
);

create table if not exists support_issues (
  id uuid primary key default gen_random_uuid(),
  company_id uuid references companies(id) on delete set null,
  database_code text,
  title text not null,
  priority text not null default 'medium'
    check (priority in ('low','medium','high','urgent')),
  status text not null default 'open'
    check (status in ('open','investigating','resolved','closed')),
  notes text,
  assigned_to uuid references platform_users(id) on delete set null,
  created_by uuid references platform_users(id) on delete set null,
  created_at timestamptz not null default now(),
  resolved_at timestamptz
);

insert into subscription_plans (name, monthly_price, staff_limit, branch_limit, monthly_order_limit, features)
values
  ('Starter', 15000, 3, 1, 500, array['pos','orders','phone-menu','basic-ledger']),
  ('Business', 30000, 12, 2, 2500, array['pos','orders','phone-menu','reports','promos','excel-ledger']),
  ('Premium', 60000, 50, 8, 10000, array['multi-branch','advanced-reports','priority-support','printer-support','api-access'])
on conflict (name) do update set
  monthly_price=excluded.monthly_price,
  staff_limit=excluded.staff_limit,
  branch_limit=excluded.branch_limit,
  monthly_order_limit=excluded.monthly_order_limit,
  features=excluded.features;

drop trigger if exists company_subscriptions_touch_updated_at on company_subscriptions;
create trigger company_subscriptions_touch_updated_at
before update on company_subscriptions
for each row execute function touch_updated_at();

alter table platform_users enable row level security;
alter table subscription_plans enable row level security;
alter table company_subscriptions enable row level security;
alter table database_health_checks enable row level security;
alter table support_issues enable row level security;

-- Keep these policies strict when real auth is connected.
-- Only platform employees should be able to use these tables.
