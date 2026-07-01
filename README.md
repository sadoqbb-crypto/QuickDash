# QuickDash

**Run your restaurant faster.**

QuickDash is a simple, all‑in‑one point‑of‑sale and management tool for restaurants, coffee shops and cafés. It runs entirely in the browser — no install, no backend — so it opens instantly on any laptop.

This repository holds the working UI/UX prototype: a single self‑contained `index.html` you can open, click through, and deploy to GitHub Pages in a couple of minutes.

---

## What's inside

Everything is one screen away from the sidebar:

- **Dashboard** — sales today, orders, pending, average order, a weekly activity chart, a daily‑goal ring, a live‑orders queue, a calendar and who's on shift.
- **Point of sale** — tap items to build an order, pick Dine‑in / Takeaway, choose Cash / Card / Mobile Money, and charge. VAT (18%) is calculated automatically and each sale is stamped with the staff member serving.
- **Orders** — filter All / Pending / Paid, mark orders paid, reprint receipts.
- **Menu builder** — add your own categories and items, set prices, and toggle availability. Changes appear on the POS instantly.
- **Staff** — manage cashiers, managers and owners with roles and PINs. Switch who's serving from the top bar.
- **Reports** — sales by category, payment‑method breakdown, and Excel / PDF export.
- **Brand & look** — upload your logo, set your name and tagline, and pick your brand colour. **The whole app re‑themes live**, and every receipt follows your brand.

> This is a front‑end prototype. Data lives in the page for the session and resets on refresh — see the roadmap for persistence.

---

## Run it locally

No build step. Either:

- **Double‑click** `index.html`, or
- serve it (recommended, avoids browser file restrictions):

```bash
# Python 3
python3 -m http.server 8000
# then open http://localhost:8000
```

---

## Deploy to GitHub Pages

1. Push this repo to GitHub (see below).
2. On GitHub: **Settings → Pages**.
3. Under **Build and deployment**, set **Source: Deploy from a branch**.
4. Choose branch **`main`** and folder **`/ (root)`**, then **Save**.
5. Wait ~1 minute. Your app is live at:

```
https://sadoq-crypto.github.io/quickdash/
```

---

## Push this repo to GitHub

From inside the `quickdash` folder:

```bash
git init
git add .
git commit -m "Initial commit: QuickDash POS prototype"
git branch -M main
git remote add origin https://github.com/sadoq-crypto/quickdash.git
git push -u origin main
```

Create the empty `quickdash` repository on GitHub first (without a README, so the push isn't rejected).

---

## Brand

| Token            | Value       |
|------------------|-------------|
| Accent (orange)  | `#F26722`   |
| Ink (navy‑black) | `#171C24`   |
| Paper (warm bg)  | `#F4F1EA`   |
| Success (green)  | `#1E9E6A`   |

Fonts: **Bricolage Grotesque** (headings), **Inter** (UI), **Space Mono** (money / receipts). The accent colour is a single CSS variable — change it in Brand & look and everything follows.

---

## Roadmap

- [ ] Save data locally (localStorage) so it survives a refresh
- [ ] Staff PIN‑lock / sign‑in screen
- [ ] Customer QR self‑order menu
- [ ] Printed‑receipt layout
- [ ] Split into modular files (HTML / CSS / JS) for the production build

---

## Licence

MIT — see [LICENSE](LICENSE).
