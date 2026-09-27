create extension if not exists pgcrypto;

create type public.order_status as enum ('Pending', 'Confirmed', 'Delivered', 'Cancelled');

create table public.customers (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone_number text not null unique,
  shop_name text not null,
  shop_address text not null,
  created_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  price numeric(10, 2) not null check (price >= 0),
  category text not null,
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  image_path text,
  featured boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.offers (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  discount_percentage numeric(5, 2) not null check (discount_percentage between 0 and 100),
  flash_sale boolean not null default false,
  product_id uuid references public.products(id) on delete set null,
  starts_at timestamptz not null default now(),
  expires_at timestamptz,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete restrict,
  status public.order_status not null default 'Pending',
  subtotal numeric(10, 2) not null check (subtotal >= 0),
  delivery_charge numeric(10, 2) not null default 0 check (delivery_charge >= 0),
  total numeric(10, 2) not null check (total >= 0),
  latitude double precision,
  longitude double precision,
  created_at timestamptz not null default now()
);

create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  image_path text,
  unit_price numeric(10, 2) not null check (unit_price >= 0),
  quantity integer not null check (quantity > 0),
  line_total numeric(10, 2) generated always as (unit_price * quantity) stored
);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  customer_id uuid not null references public.customers(id) on delete cascade,
  rating integer not null check (rating between 1 and 5),
  body text not null,
  created_at timestamptz not null default now(),
  unique (product_id, customer_id)
);

create table public.search_history (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references public.customers(id) on delete set null,
  query text not null,
  searched_at timestamptz not null default now()
);

create table public.settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid references auth.users(id) on delete cascade,
  event_type text not null,
  title text not null,
  body text not null default '',
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index orders_customer_created_idx on public.orders(customer_id, created_at desc);
create index orders_status_idx on public.orders(status);
create index order_items_order_idx on public.order_items(order_id);
create index search_history_query_idx on public.search_history(query);
create index reviews_product_idx on public.reviews(product_id);

alter table public.customers enable row level security;
alter table public.products enable row level security;
alter table public.offers enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.reviews enable row level security;
alter table public.search_history enable row level security;
alter table public.settings enable row level security;
alter table public.notifications enable row level security;
create table public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('owner', 'customer'))
);
alter table public.user_roles enable row level security;

create or replace function public.is_shop_owner()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.user_roles
    where user_id = auth.uid() and role = 'owner'
  );
$$;

create policy "Public can view products" on public.products for select using (true);
create policy "Owner manages products" on public.products for all to authenticated using (public.is_shop_owner()) with check (public.is_shop_owner());
create policy "Public can view active offers" on public.offers for select using (active and (expires_at is null or expires_at > now()));
create policy "Owner manages offers" on public.offers for all to authenticated using (public.is_shop_owner()) with check (public.is_shop_owner());
create policy "Customers view their profile" on public.customers for select to authenticated using (id = auth.uid() or public.is_shop_owner());
create policy "Customers insert their profile" on public.customers for insert to authenticated with check (id = auth.uid());
create policy "Customers update their profile" on public.customers for update to authenticated using (id = auth.uid() or public.is_shop_owner()) with check (id = auth.uid() or public.is_shop_owner());
create policy "Customers view their orders" on public.orders for select to authenticated using (customer_id = auth.uid() or public.is_shop_owner());
create policy "Customers create their orders" on public.orders for insert to authenticated with check (customer_id = auth.uid());
create policy "Owner updates orders" on public.orders for update to authenticated using (public.is_shop_owner()) with check (public.is_shop_owner());
create policy "Users view order items for their orders" on public.order_items for select to authenticated using (exists (select 1 from public.orders o where o.id = order_id and (o.customer_id = auth.uid() or public.is_shop_owner())));
create policy "Customers add order items to their orders" on public.order_items for insert to authenticated with check (exists (select 1 from public.orders o where o.id = order_id and o.customer_id = auth.uid()));
create policy "Public can view reviews" on public.reviews for select using (true);
create policy "Customers manage own reviews" on public.reviews for insert to authenticated with check (customer_id = auth.uid());
create policy "Customers view own searches" on public.search_history for select to authenticated using (customer_id = auth.uid() or public.is_shop_owner());
create policy "Customers add searches" on public.search_history for insert to authenticated with check (customer_id is null or customer_id = auth.uid());
create policy "Public can view public settings" on public.settings for select using (key in ('shop_phone', 'whatsapp_number', 'delivery_charge', 'shop_images', 'logo_url', 'banner_images'));
create policy "Owner manages settings" on public.settings for all to authenticated using (public.is_shop_owner()) with check (public.is_shop_owner());
create policy "Users view their notifications" on public.notifications for select to authenticated using (recipient_id = auth.uid() or public.is_shop_owner());
create policy "Users update their notifications" on public.notifications for update to authenticated using (recipient_id = auth.uid() or public.is_shop_owner()) with check (recipient_id = auth.uid() or public.is_shop_owner());
create policy "Owners manage roles" on public.user_roles for all to authenticated using (public.is_shop_owner()) with check (public.is_shop_owner());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('shop-media', 'shop-media', true, 5242880, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do nothing;

create policy "Public can view shop media" on storage.objects for select using (bucket_id = 'shop-media');
create policy "Owner uploads shop media" on storage.objects for insert to authenticated with check (bucket_id = 'shop-media' and public.is_shop_owner());
create policy "Owner updates shop media" on storage.objects for update to authenticated using (bucket_id = 'shop-media' and public.is_shop_owner()) with check (bucket_id = 'shop-media' and public.is_shop_owner());
create policy "Owner deletes shop media" on storage.objects for delete to authenticated using (bucket_id = 'shop-media' and public.is_shop_owner());