# 🔥 Backend Immediate Fix Checklist (≤ 2 hours)

## 1. Enforce JWT verification (ApplicationController)
- [X] Update `authenticate_request` to:
  - [X] Extract Bearer token properly
  - [X] Use `JWT.decode` with `true` verification and `{ algorithm: "HS256", verify_expiration: true }`
  - [X] Rescue `JWT::ExpiredSignature` → return `{ error: "token expired" }` (401)
  - [X] Rescue `JWT::DecodeError` → return `{ error: "unauthorized" }` (401)
- [X] Test with:
  - [X] Valid token → 200 OK
  - [X] Garbled token → 401 unauthorized
  - [X] Expired token → 401 token expired
- [X] Commit: `auth: verify JWT signature and exp; standardized 401 JSON`

---

## 2. Harden `users#index` (no sensitive fields)
- [ ] Change `users#index` to use either:
  - [ ] `User.select(:id, :username, :first_name, :last_name)` OR
  - [ ] `UserBlueprint.render(users, view: :normal)`
- [ ] Confirm `password_digest` and other internals are NOT in response
- [ ] Commit: `users: safe index response (no sensitive fields)`

---

## 3. Robust `profiles#show` (404 + eager load)
- [ ] Modify to `User.includes(:profile, :location).find_by(username: params[:username])`
- [ ] Return `{ error: "profile not found" }` (404) if:
  - [ ] User doesn’t exist OR
  - [ ] Profile doesn’t exist
- [ ] Keep returning `ProfileBlueprint.render(profile, view: :normal)` on success
- [ ] Test:
  - [ ] Existing profile → 200 OK JSON
  - [ ] Missing user/profile → 404 error JSON
- [ ] Commit: `profiles: 404 on missing user/profile; eager load associations`

---

## 4. Clean `LocationBlueprint`
- [ ] Remove non-existent fields (`zip_code`, `city`, `state`, `country`)
- [ ] Keep only `id` + `address`
- [ ] Confirm response payloads no longer show nulls
- [ ] Commit: `blueprints: LocationBlueprint only exposes real columns`

---

## 5. Fix outdated routes & specs (profiles)
- [ ] Update tests to use `GET /profiles/:username`
- [ ] Add spec for missing user → expect 404 JSON
- [ ] Search frontend for `/profiles/show` and replace with `/profiles/${username}`
- [ ] Run request specs to confirm green
- [ ] Commit: `tests: update profiles route to /profiles/:username and add 404 case`

---

## Final Smoke Test
- [ ] Valid token → 200 on `/users`
- [ ] Bad/expired token → 401 JSON
- [ ] `/users` index returns safe fields only
- [ ] `/profiles/:username` → 200 if exists, 404 if missing
- [ ] Location shows only `id` + `address`
- [ ] No frontend/tests use `/profiles/show`
