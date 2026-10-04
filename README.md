# Malik Adrees Sweets Shop & U.S Dealer

A mobile-first bilingual (English/Urdu) storefront for the shop at Clock Tower, Chakki Bazar, Samundri, Pakistan. Built with React and Vite.

## Run locally

```sh
npm install
npm run dev
```

The first visit plays a three-second welcome animation and opens the account-type selector. Browse as a guest, create a demo customer account, or use the owner demo credentials shown on the owner sign-in form (`Ayan` / `000467`). The demo account, products, reviews, cart, orders, settings, and search history are stored in this browser's local storage. Clearing browser storage resets the demo.

The owner demo credentials are intentionally client-side and are **not secure authentication**. Do not expose private customer data or use this demo login for a live store.

## Supabase project setup

1. Create a Supabase project and open its SQL Editor.
2. Run [`supabase/schema.sql`](supabase/schema.sql). It creates the requested relational tables, foreign keys, order status enum, indexes, RLS policies, a `user_roles` table, and the public `shop-media` image bucket.
3. Create the owner account in Supabase Auth. Insert its user UUID into `public.user_roles` with role `owner` using the SQL Editor. Keep the service-role key private; never put it in a `VITE_` variable or browser code.
4. Configure public project URL and anon key in `.env.local` using [`.env.example`](.env.example). When these values are present, product reads, creates, edits, deletes, and image uploads use Supabase.
5. Create customer Auth accounts and matching `customers` rows only after the app is updated to use Supabase Auth. Configure phone/SMS verification if using phone auth.
6. Product images are uploaded from the owner dashboard to the `shop-media` bucket using Camera Capture or Gallery Upload. The public object URL is stored through `products.image_path`.
7. Deploy the Vite `dist` directory to a static host and configure SPA fallback to `index.html` after completing and testing the live backend workflows.

## Current integration boundary

The interface remains usable as a local interactive demo when Supabase variables are absent, with browser geolocation requested at checkout and local persistence across refreshes. With Supabase variables present, the customer catalog reads current rows from the database and owner product mutations use the RLS-protected products table and Storage bucket. The existing demo owner login is still client-side; use Supabase Auth and the owner role before taking real orders.

In particular, never ship the requested fixed owner password as an authorization mechanism. Provision the owner in Supabase Auth, assign the owner role in `user_roles`, and verify the role server-side/RLS before enabling dashboard mutations. Customer passwords must only be handled by Supabase Auth, never stored in `customers` or local storage.

## Features in this build

- Responsive storefront with product categories, search, offers, shop story, location section, and customer quotes.
- English and Urdu interface switch, with RTL layout in Urdu.
- Local demo registration, owner workspace, product management, orders/statuses, offers/settings, reviews, and search counts.
- Persistent cart, quantity controls, checkout confirmation, and optional geolocation capture.
- First-visit intro, animated sections, reduced-motion support, and WhatsApp contact link.

## Commands

```sh
npm run dev
npm run lint
npm run build
npm run preview
```