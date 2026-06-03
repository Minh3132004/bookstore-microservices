# Bookstore Microservices — Tài liệu hoàn thiện dự án (đọc 1 lần → làm hết)

> **Mục đích:** Một file duy nhất — AI đọc **một lần** hiểu **mọi** chức năng, bug, và cách làm đúng. Không đoán, không làm lại sai lệch.  
> **Audit:** 2026-06-03 — 46 file Dart, 7 service Java, gateway, docker-compose.

---

## Cách dùng (one-shot)

```text
Đọc TOÀN BỘ docs/AI_MASTER_PROMPT.md.
Thực hiện Phase 0 → 5 đúng thứ tự. Mỗi module phải đạt đủ 5 mục: Yêu cầu product → Mapping → Implement → Sửa bug → Test tay.
Sau mỗi phase: báo cáo file đã sửa + tick checklist.
Không commit trừ khi tôi yêu cầu.
```

---

## Quy tắc toàn cục (KHẮT KHE)

### A. Phạm vi

| # | Quy tắc |
|---|---------|
| 1 | **Flutter hoàn hảo** — UX + logic + API khớp từng màn |
| 2 | **Backend tối thiểu** — **R1–R4** trước Flutter P0; không refactor kiến trúc |
| 3 | Giữ stack: Spring microservices + GetX + Dio |
| 4 | Không commit/push trừ khi user yêu cầu |

### B. Phân quyền (YÊU CẦU PRODUCT)

| `role` (JWT) | Sau login / mở app | Khu vực |
|--------------|-------------------|---------|
| `ADMIN` | `/admin` | `/admin/*` only |
| Khác | `/home` | Customer flow |

- Hàm chung `AuthController.navigateAfterAuth()` — dùng ở **Login** + **Splash**.
- **Route guard** mọi `/admin/*`: `role != ADMIN` → chặn + redirect.
- **Bug:** `login_screen.dart` luôn `/home`; splash (`main.dart`) đã đúng.

### C. DoD — mọi màn Flutter

- API đúng `api_endpoints.dart`; check `success` trước parse `data`
- Loading + lỗi hiển thị (**cấm** `catch (_) {}` trên luồng chính)
- Empty state có hướng dẫn
- Form khớp DTO; không `TextEditingController` trong `build()` StatelessWidget
- Không `fetch()` trong `build()` — dùng `onInit`/`initState`
- Ảnh: `CachedNetworkImage` + placeholder + errorWidget
- Tiền: `xxxđ`; **cấm** `quantity * 0`

### D. API envelope

```json
{ "success": true, "message": "...", "data": ... }
```

Page: `data.content`, `data.totalPages`, `data.number`.

### E. Backend bắt buộc (Phase 0 — trước Flutter P0)

| ID | Việc | File |
|----|------|------|
| **R1** | Book JSON có `images[]` | `book-service/.../Book.java` hoặc DTO |
| **R2** | Order JSON có `listOrderDetails` + load DB | `Order.java`, `OrderService` |
| **R3** | `createOrder` tính total server-side | `OrderService.createOrder` |
| **R4** | Feign unwrap `ApiResponse<BookDTO>` | `BookClient.java` |

### F. Index module (AI tick khi xong)

| ID | Tên | Phase |
|----|-----|-------|
| INFRA-01 | Splash / routing | 2 |
| INFRA-02 | Dio / token | 5 |
| AUTH-01..04 | Auth | 2 |
| CAT-01..03 | Catalog | 1–2 |
| CART-01 | Giỏ | 1 |
| CHK-01..02 | Checkout | 1 |
| ORD-01..02 | Đơn hàng | 1 |
| PRF-01 | Profile | 2 |
| FAV-01 | Yêu thích | 3 |
| FDB-01 | Feedback | 3 |
| ADM-00..06 | Admin | 4 |
| R1–R4 | Backend | 0 |

---

## Kiến trúc

`Flutter` → `:8080/api/v1` → gateway (JWT, `X-User-Id`) → auth|user|book|order|payment|coupon-feedback → SQL Server.

Flutter web: **port 3000** (CORS). Emulator Android: `10.0.2.2`. Điện thoại thật: set `_hostIp` trong `api_endpoints.dart`.

---

## Mẫu mô tả mỗi module (AI đọc trước khi code)

Mỗi module dưới đây có **đủ 5 phần**:

1. **YÊU CẦU PRODUCT** — user mong đợi gì (ngôn ngữ nghiệp vụ)
2. **Mapping UI ↔ API** — field form ↔ DTO
3. **Cách implement** — bước cụ thể cho AI
4. **Bug hiện tại** — file/dòng/hành vi sai
5. **Test tay** — bước kiểm tra PASS/FAIL

---

# PHASE 0 — BACKEND (R1–R4)

## R1 — Ảnh sách trong API

**YÊU CẦU PRODUCT:** Mọi màn có sách hiển thị được ảnh Cloudinary (list, detail, giỏ, đơn, yêu thích).

**Bug:** `Book.images` `@JsonIgnore` → Flutter `thumbnailUrl` luôn null.

**Cách implement:**
1. Tạo `BookResponse` DTO: scalar fields + `List<ImageDto>` (`idImage`, `urlImage`, `thumbnail`).
2. Map trong `BookService` get/search/getById/create/update.
3. Hoặc bỏ `@JsonIgnore` trên `images` và `@JsonIgnore` trên `Image.book` để tránh vòng JSON.

**Test:** `GET /api/v1/books/1` → `data.images` là mảng có `urlImage`.

---

## R2 — Chi tiết đơn trong API

**YÊU CẦU PRODUCT:** Màn chi tiết đơn (KH + admin) thấy từng sản phẩm: tên, SL, giá.

**Bug:** `Order.listOrderDetails` `@JsonIgnore`; service không `findByOrder`.

**Cách implement:**
1. DTO `OrderResponse` + `OrderDetailDto` (`idOrderDetail`, `bookId`, `quantity`, `price`, `reviewed`).
2. `getOrderById`, `getOrdersByUser`, `createOrder` return: load `orderDetailRepository.findByOrder(order)`.
3. (Tuỳ chọn) Feign batch get book names — hoặc để Flutter gọi `GET /books/{id}` per line.

**Test:** `GET /orders/{id}` → `data.listOrderDetails` không rỗng sau khi đặt hàng.

---

## R3 — Tính tiền đơn trên server

**YÊU CẦU PRODUCT:** Tổng đơn trên DB đúng, không phụ thuộc client gửi 0đ.

**Bug:** `OrderService` lưu `request.getTotalPrice()` / `totalPriceProduct` từ client; Flutter gửi 0.

**Cách implement:**
1. Với mỗi line: `price = book.sellPrice` (sau R4), `lineTotal = price * qty`.
2. `totalPriceProduct = sum(lineTotal)`.
3. `feeDelivery` từ `Delivery` id=1 (giữ logic hiện tại).
4. `totalPrice = totalPriceProduct - couponDiscount + feeDelivery` (coupon optional phase sau).
5. Bỏ tin client totals hoặc chỉ dùng để validate chênh lệch nhỏ.

**Test:** POST order → `totalPrice > 0` khớp tổng line + ship.

---

## R4 — Feign BookClient unwrap

**YÊU CẦU PRODUCT:** Đặt hàng kiểm tra tồn kho đúng, line price đúng.

**Bug:** Feign `BookDTO` map từ envelope → fields = 0/null.

**Cách implement (chọn 1):**
- `BookClient` return `ApiResponse<BookDTO>` + decode `data` trong service, hoặc
- Custom Feign `Decoder` unwrap `data`, hoặc
- `Map` raw rồi parse `data` manually.

**Test:** Đặt hàng sách còn hàng → success; hết hàng → message tên sách.

---

# PHASE 1–4 — FLUTTER CHI TIẾT

---

## INFRA-01 — Splash & routing (`main.dart`)

| | |
|--|--|
| **Files** | `bookstore-flutter/lib/main.dart` |
| **Route** | `home:` `_SplashRouter` |

### YÊU CẦU PRODUCT

- Mở app: có token hợp lệ → vào đúng khu (admin/customer); không token → login.
- Không flash sai màn (admin thấy home 1 giây).

### Cách implement

1. `_checkAuth`: đọc token → nếu có gọi `navigateAfterAuth()` (cùng login).
2. Trong lúc check: `CircularProgressIndicator`.
3. `initialBinding`: `Get.put(AuthController())` — các màn khác `Get.find`, không `put` trùng.

### Bug hiện tại

| Bug | File |
|-----|------|
| Splash đúng role nhưng login sai | `login_screen.dart` |
| Không xử lý lỗi storage | `main.dart` |

### Test tay

1. Token ADMIN → mở app → `/admin`.
2. Token USER → `/home`.
3. Không token → `/login`.

---

## INFRA-02 — Dio & token (`dio_client.dart`, `token_storage.dart`)

### YÊU CẦU PRODUCT

- Mọi request (trừ public) có Bearer JWT.
- Hết hạn (401) → đăng xuất, về login, không loop lỗi.

### Cách implement

- Giữ interceptor; có thể log `debugPrint` URL + status khi debug.
- Document `_hostIp` trong README.

### Test tay

1. Gọi API sau login → 200.
2. Xóa token server-side / token hết hạn → 401 → về login.

---

## AUTH-01 — Login (`/login`)

| | |
|--|--|
| **Files** | `features/auth/screens/login_screen.dart`, `features/auth/controllers/auth_controller.dart` |
| **API** | `POST /auth/login` `{username, password}` → `data.token` |

### YÊU CẦU PRODUCT

- Đăng nhập thành công → **ADMIN vào `/admin`**, **khách vào `/home`**.
- Sai mật khẩu → message đỏ rõ.
- Có link đăng ký, quên mật khẩu.

### Mapping UI ↔ API

| UI | JSON field |
|----|------------|
| Tên đăng nhập | `username` |
| Mật khẩu | `password` |

JWT decode: `id` (num→int), `role` (string), lưu `TokenStorage`.

### Cách implement

1. `AuthController.login`: sau save token → **không** navigate trong controller (để screen gọi).
2. `login_screen._onLogin`: `success` → `await authController.navigateAfterAuth()`.
3. `navigateAfterAuth()`: `Get.offAllNamed(role == 'ADMIN' ? '/admin' : '/home')`.
4. Validator: `v == null || v.isEmpty` — không `v!`.
5. `(payload['id'] as num).toInt()`.

### Bug hiện tại

| Bug | Chi tiết |
|-----|----------|
| Admin vào customer | `Get.offAllNamed('/home')` line ~101 |
| JWT cast | `as int` có thể crash |

### Test tay

1. USER → home có nút sách/giỏ.
2. ADMIN → dashboard 6 mục, **không** home.
3. Sai pass → lỗi hiện.

---

## AUTH-02 — Register (`/register`)

| | |
|--|--|
| **API** | `POST /auth/register` |

### YÊU CẦU PRODUCT

- Đăng ký → thông báo gửi OTP email → chuyển màn kích hoạt với email điền sẵn.

### Mapping UI ↔ API

| UI | Field |
|----|-------|
| Họ đệm | `firstName` |
| Tên | `lastName` |
| Email | `email` |
| Tên đăng nhập | `username` |
| Mật khẩu | `password` (client min 6 — khớp backend nếu có rule) |

### Cách implement

- Validate email (`contains('@')` tối thiểu; tốt hơn: regex).
- Success → snackbar + `Get.toNamed('/active-account', arguments: {'email': email})`.
- Hiển thị `errorMessage` từ controller.

### Bug hiện tại

- Email validator yếu; không hiện rule password backend.

### Test tay

1. Register user mới → màn activate có email.
2. Trùng username → lỗi backend hiện.

---

## AUTH-03 — Forgot password (`/forgot-password`)

| | |
|--|--|
| **API** | `PUT /auth/forgot-password` `{email}` |

### YÊU CẦU PRODUCT

- Nhập email → gửi mật khẩu tạm qua email → báo thành công hoặc **lỗi rõ** (email không tồn tại).

### Cách implement

1. `Form` + validator email.
2. `AuthController.forgotPassword`: set `errorMessage` on fail (hiện **silent**).
3. UI: snackbar success **và** snackbar/error text khi fail.
4. Empty email → snackbar "Nhập email".

### Bug hiện tại

| Bug | File |
|-----|------|
| Fail im lặng | `auth_controller.dart` `catch` return false |
| Empty email return sớm không báo | `forgot_password_screen.dart` ~49 |

### Test tay

1. Email hợp lệ → success message → login.
2. Email sai → **phải** thấy lỗi.

---

## AUTH-04 — Activate (`/active-account`)

| | |
|--|--|
| **API** | `GET /auth/activate?email=&code=` |

### YÊU CẦU PRODUCT

- Nhập OTP (và email nếu chưa có) → kích hoạt → về login.

### Mapping

| UI | Query |
|----|-------|
| Email | `email` |
| Mã OTP | `code` |

### Cách implement

- `StatefulWidget` + Form validators.
- Prefill email từ `Get.arguments['email']`.
- Success → snackbar + `Get.offAllNamed('/login')`.
- Link từ register (đã có).

### Bug hiện tại

- Dùng Dio trực tiếp (OK); không validator; không resend OTP (backend chưa có thì bỏ qua).

### Test tay

1. Register → nhập OTP mail → activate → login được.

---

## CAT-01 — Home (`/home`)

| | |
|--|--|
| **Files** | `features/home/screens/home_screen.dart`, `BookController` |
| **API** | `GET /books/search?page=0&size=10`; `GET /genres` |

### YÊU CẦU PRODUCT

- Trang chủ khách: lối vào "Xem tất cả sách", **sách bán chạy thật** (sort `soldQuantity`), có **ảnh + giá**, nút giỏ & tài khoản.

### Cách implement

1. Load bestseller: `GET /books/search?sort=soldQuantity&size=5` **hoặc** `GET /books?sort=soldQuantity&size=5` (dùng endpoint `books` nếu cần).
2. Mỗi tile: `CachedNetworkImage(thumbnailUrl)`, tên, giá, "Đã bán: n".
3. Tap → `/book-detail` với `idBook`.
4. AppBar: cart → `/cart`, person → `/profile`.

### Bug hiện tại

| Bug | Chi tiết |
|-----|----------|
| Không phải bán chạy | `controller.books.take(5)` từ search mặc định |
| Không ảnh | ListTile icon only |
| Genres fetch không dùng | `BookController.fetchGenres` |

### Test tay

1. Home hiện ảnh sách (sau R1).
2. Sách nhiều `soldQuantity` lên đầu.

---

## CAT-02 — Products (`/products`)

| | |
|--|--|
| **API** | `GET /books/search` — `name?`, `genreId?`, `page`, `size=10` |

### YÊU CẦU PRODUCT

- Tìm kiếm mượt (gõ là lọc), lọc thể loại, phân trang, lưới 2 cột có ảnh giá.

### Cách implement

1. `TextField` `onChanged` debounce 300ms → `controller.search(name, genreId: ...)`.
2. Hàng `FilterChip` từ `controller.genres` → set `selectedGenreId`, `fetchBooks(reset: true)`.
3. Dùng `BookCard` shared widget.
4. `_Pagination` giữ nguyên.
5. States: loading | empty "Không tìm thấy" | error "Lỗi tải" + nút Thử lại.

### Bug hiện tại

| Bug | Chi tiết |
|-----|----------|
| Chỉ search onSubmitted | Không debounce |
| Không UI genre | `selectedGenreId` không bind |
| Duplicate widget | `_BookCard` local |

### Test tay

1. Gõ tên sách → list lọc.
2. Chọn thể loại → list lọc.
3. Next/prev trang.

---

## CAT-03 — Book detail (`/book-detail`)

| | |
|--|--|
| **Arguments** | `int idBook` |
| **API** | `GET /books/{id}`, `GET /reviews/book/{id}`, `POST /cart/items`, favorites POST/DELETE |

### YÊU CẦU PRODUCT

- Xem đủ: ảnh (gallery nếu nhiều), giá gạch ngang nếu giảm, rating, tồn kho, mô tả, đánh giá, thêm giỏ, yêu thích.

### Cách implement

1. PageView ảnh nếu `images.length > 1`.
2. `quantity` stepper max = `book.quantity`; nút mua disabled khi 0.
3. `addItem(bookId, quantity)`.
4. Favorite toggle realtime `Obx`.
5. Reviews: format ngày; hiển thị sao + content (userId → "Người dùng #id" tạm cho đến khi có tên).

### Bug hiện tại

- Không gallery; review avatar = userId; hero image thiếu error placeholder.

### Test tay

1. Ảnh load; hết hàng → không mua được.
2. Thêm giỏ → snackbar + giỏ có item.

---

## `BookController` (shared)

### YÊU CẦU PRODUCT

- Customer: search + genres + pagination.
- Admin: **không** dùng chung list 10 item — tách method admin.

### Cách implement

- `fetchBooksForAdmin({page, size: 20})` dùng `GET /books` hoặc search size lớn + pagination.
- `fetchGenres`: snackbar on error.
- `getBookById`: return null + message on fail.

### Bug

- `fetchGenres` `catch (_) {}`; admin book list = customer search page 0 size 10.

---

## CART-01 — Giỏ hàng (`/cart`)

| | |
|--|--|
| **API** | `GET /cart/{userId}`, `POST /cart/items`, `PUT /cart/items/{id}`, `DELETE /cart/items/{id}` |

### YÊU CẦU PRODUCT

- Giỏ như app thương mại: **ảnh, tên sách, đơn giá, SL, thành tiền từng dòng, tổng cộng**, tăng/giảm/xóa, nút thanh toán.

### Mapping

| Cart API | Ghi chú |
|----------|---------|
| `bookId`, `quantity` | Cần join `GET /books/{id}` lấy `nameBook`, `sellPrice`, `thumbnailUrl` |

### Cách implement

1. Model mở rộng `CartLineView` (cart item + `BookModel?`) hoặc map trong controller.
2. `fetchCart`: GET cart → loop unique bookIds → parallel GET books → merge.
3. `totalPrice` = Σ `sellPrice * quantity`.
4. UI `ListTile` hoặc Card: leading image, title, subtitle giá, trailing +/- và delete.
5. Bottom bar: "Tổng: Xđ" + "Đặt hàng" → `/checkout` (cần login — cart đã cần userId).
6. `updateQuantity`/`removeItem`: snackbar on error; cap qty ≤ stock.

### Bug hiện tại

| Bug | File |
|-----|------|
| Tổng = 0 | `cart_controller.dart:14` `* 0` |
| Chỉ Sách ID | `cart_screen.dart` |
| Silent errors | `catch (_) {}` |

### Test tay

1. Thêm 2 sách → giỏ hiện tên ảnh giá đúng.
2. Tổng = sum đúng.
3. Đổi SL → tổng cập nhật.

---

## CHK-01 — Checkout (`/checkout`)

| | |
|--|--|
| **API** | `GET /payments`, `GET /coupons/validate?code=`, `POST /orders`, `PUT /coupons/use?code=` |

### YÊU CẦU PRODUCT

**A. Thông tin giao hàng (giống user đã nói):**
- Vào checkout → **tự điền** họ tên, SĐT, địa chỉ từ profile.
- User **được sửa** trước khi đặt.
- Chỉ **bắt buộc nhập** ô nào profile **chưa có**.
- Loading "Đang tải thông tin giao hàng…".
- Thiếu SĐT/địa chỉ lâu dài → gợi ý link `/profile`.

**B. Tiền:**
- Tạm tính = Σ(giá × SL) từ cart enriched.
- Dòng phí ship (số tiền = backend delivery id=1 — đọc từ config/constants document trong code).
- Mã giảm: nhập → validate → hiện % và số tiền trừ.
- Tổng = tạm tính - giảm + ship.

**C. Thanh toán:**
- Chọn phương thức từ `GET /payments`.
- **Flow A (mặc định nếu không làm PayOS):** COD/PENDING — đặt hàng POST → success.
- **Flow B:** PayOS create link → mở browser → về app (chỉ nếu làm webhook).

### Mapping UI ↔ `CreateOrderRequest`

| UI | Field |
|----|-------|
| Họ và tên | `fullName` |
| SĐT | `phoneNumber` |
| Địa chỉ | `deliveryAddress` |
| Ghi chú | `note` |
| (tính toán) | `totalPriceProduct`, `totalPrice` |
| Radio payment | `paymentId` |
| — | `paymentStatus` ('PENDING' hoặc 'PAID') |
| Từ giỏ | `orderItems: [{bookId, quantity}]` |

### Cách implement

1. `initState`: `await profileController.fetchProfile()` → fill controllers.
2. Hoặc `ever(user, (_) => fill)` nếu đã có instance.
3. `_calcSubtotal` từ cart enriched books — **xóa * 0**.
4. Hiển thị breakdown UI.
5. `_onPlaceOrder`: validate form (chỉ field trống bắt buộc).
6. `createOrder` → success → `couponUse` with error snackbar → `Get.offNamed('/payment-success', arguments: {orderId, total})`.
7. `_loadPaymentMethods`: catch → snackbar "Không tải phương thức thanh toán".

### Bug hiện tại

| Bug | Chi tiết |
|-----|----------|
| Prefill race | `_prefillProfile()` sync khi user null |
| Subtotal 0 | `_calcSubtotal` * 0 |
| Ship fee ẩn | User không thấy phí ship |
| PayOS không dùng | Endpoint thừa |
| couponUse silent | `catch (_) {}` |

### Test tay

1. Profile có SĐT+địa chỉ → checkout **điền sẵn**.
2. Profile thiếu địa chỉ → ô trống, submit bắt nhập.
3. Tổng hiển thị khớp sau đặt (sau R3).
4. Coupon 10% → tổng giảm đúng.

---

## CHK-02 — Payment success (`/payment-success`)

### YÊU CẦU PRODUCT

- Xác nhận đã đặt: **mã đơn**, **số tiền**, nút xem đơn / về home.

### Cách implement

- Nhận `Get.arguments` `orderId`, `totalPrice`.
- Hiển thị Text rõ.
- Nút → `/order-detail` với id; `/home` offAll.

### Bug hiện tại

- Không arguments — chỉ text chung chung.

### Test tay

1. Sau đặt hàng thấy #đơn và tổng đúng.

---

## ORD-01 — Danh sách đơn (`/orders`)

| | |
|--|--|
| **API** | `GET /orders/user/{userId}` |

### YÊU CẦU PRODUCT

- Danh sách đơn: mã, ngày, tổng, trạng thái màu, thanh toán; kéo refresh; tap chi tiết.

### Cách implement

1. `OrderController.onInit` → `fetchMyOrders` (**không** gọi trong `build`).
2. `Obx` hiển thị `errorMessage` nếu có.
3. `RefreshIndicator` (đã có — giữ).
4. Empty: "Chưa có đơn" + nút "Mua sách" → `/products`.

### Bug hiện tại

| Bug | Chi tiết |
|-----|----------|
| fetch trong build | `orders_screen.dart` ~12 |
| errorMessage không UI | controller có, screen không |

### Test tay

1. Có đơn → list; pull refresh.
2. Lỗi mạng → thấy lỗi.

---

## ORD-02 — Chi tiết đơn (`/order-detail`)

| | |
|--|--|
| **Arguments** | `int orderId` |
| **API** | `GET /orders/{id}`, `PUT /orders/{id}/cancel`, `POST /reviews` |

### YÊU CẦU PRODUCT

- Chi tiết đầy đủ: người nhận, địa chỉ, trạng thái, **từng sách (tên ảnh SL giá)**, phí ship, tổng.
- Hủy đơn khi chưa giao xong.
- Đánh giá từng sách khi trạng thái **"Hoàn thành"** và chưa `reviewed`.

### Mapping review

| UI | `ReviewRequest` |
|----|-----------------|
| Sao | `ratingPoint` |
| Nội dung | `content` |
| — | `bookId`, `orderDetailId` |

### Cách implement

1. Sau R2: parse `listOrderDetails`; optional batch load book info cho tên+ảnh.
2. Nút Hủy: confirm dialog; `cancelOrder` → reload.
3. Nút Đánh giá: dialog; POST review → reload order.
4. Status tiếng Việt khớp backend.

### Bug hiện tại

| Bug | Chi tiết |
|-----|----------|
| Line items rỗng | JsonIgnore |
| UI Sách ID | `order_detail_screen.dart` |
| Không refresh sau review | |

### Test tay

1. Chi tiết có ≥1 dòng sách tên+giá.
2. Hủy đơn "Đang xử lý" → OK.
3. Đơn "Hoàn thành" → gửi review → không gửi trùng.

---

## `OrderController`

| Method | Yêu cầu |
|--------|---------|
| `fetchMyOrders` | Set errorMessage; loading |
| `createOrder` | Map body đủ; không silent |
| `cancelOrder` | Snackbar lỗi |
| `getOrderById` | Parse `OrderModel` + details |

---

## PRF-01 — Profile (`/profile`)

| | |
|--|--|
| **API** | `GET /users/{id}`, `PUT /users/{id}/profile`, `PUT /users/{id}/avatar` |

### YÊU CẦU PRODUCT

- Xem & sửa đầy đủ thông tin: họ tên, email (read-only), SĐT, địa chỉ, **ngày sinh**, **giới tính**, avatar.
- Đổi avatar từ gallery.
- Shortcut: đơn hàng, yêu thích, feedback.

### Mapping UI ↔ `UpdateProfileRequest`

| UI | Field | Ghi chú |
|----|-------|---------|
| Họ đệm | `firstName` | |
| Tên | `lastName` | |
| SĐT | `phoneNumber` | |
| Địa chỉ | `deliveryAddress` | |
| Ngày sinh | `dateOfBirth` | `yyyy-MM-dd` hoặc ISO — khớp backend `java.sql.Date` |
| Giới tính | `gender` | Backend `Character` — gửi `"M"`/`"F"` hoặc `"Nam"`/`"Nữ"` thống nhất 1 ký tự |

### Cách implement

1. Dialog edit: thêm `DatePicker`, `DropdownButton` gender.
2. `updateProfile` gửi đủ field.
3. Avatar: detect mime png/jpeg trong base64 prefix.
4. Load fail: Center Text `errorMessage` + nút Thử lại.
5. Hiển thị ngày sinh/giới tính trên profile (không "Chưa cập nhật" nếu có data).

### Bug hiện tại

| Bug | Chi tiết |
|-----|----------|
| Thiếu 2 field form | `profile_screen.dart` dialog 4 field |
| Avatar luôn jpeg | `changeAvatar` |
| errorMessage không UI | user null chỉ text chung |

### Test tay

1. Sửa ngày sinh + giới tính → lưu → hiện lại.
2. Đổi avatar → hiện ảnh mới.
3. Checkout sau đó thấy địa chỉ mới (sau fix prefill).

---

## FAV-01 — Yêu thích (`/favorites`)

| | |
|--|--|
| **API** | `GET /favorites/user/{userId}`, `DELETE ...`, `POST /favorites` |

### YÊU CẦU PRODUCT

- List sách yêu thích có ảnh tên giá; xóa; tap vào detail; load nhanh (không N+1 chậm).

### Cách implement

1. `fetchFavorites` → collect bookIds → `Future.wait` GET books **hoặc** 1 search batch nếu có.
2. UI giống product card nhỏ.
3. `removeFavorite` snackbar on error.

### Bug hiện tại

- Mỗi tile `_FavoriteTile` 1 GET book (N+1).
- Không ảnh — icon only.

### Test tay

1. 3 favorites → load < 2s cảm nhận.
2. Remove → biến mất + snackbar.

---

## FDB-01 — Feedback (`/feedback`)

| | |
|--|--|
| **API** | `POST /feedbacks` `{content}` |

### YÊU CẦU PRODUCT

- Gửi góp ý dài; validate độ dài; loading; thành công quay lại hoặc clear form.

### Cách implement

1. Đổi sang `StatefulWidget`; controller trong `State`.
2. Min 10, max 1000 ký tự.
3. `FeedbackController.sendFeedback` — message lỗi rõ.

### Bug hiện tại

- Stateless + controller trong build (anti-pattern) — **không** mất text nếu không rebuild nhưng vi phạm convention.

### Test tay

1. Gửi ngắn <10 → lỗi.
2. Gửi hợp lệ → success.

---

## ADMIN — chung

### ADM-GUARD — Route guard (mọi admin screen)

**YÊU CẦU PRODUCT:** Customer không vào được admin kể cả gõ URL / deep link.

**Cách implement:**

```dart
// admin_route_guard.dart hoặc mixin
Future<void> ensureAdmin() async {
  final role = await TokenStorage.getUserRole();
  if (role != 'ADMIN') {
    Get.snackbar('Từ chối', 'Bạn không có quyền truy cập');
    Get.offAllNamed('/home');
  }
}
```

Gọi `ensureAdmin()` trong `initState` mỗi admin screen hoặc middleware GetX.

---

## ADM-00 — Dashboard (`/admin`)

### YÊU CẦU PRODUCT

- Menu 6 mục; badge phản hồi chưa đọc; logout.

### Cách implement

- `onInit`: `fetchFeedbacks` hoặc chỉ `GET unread-count` → badge trên tile Phản hồi.
- Logout → `AuthController.logout`.

### Test tay

1. Badge đúng số unread.
2. Tap từng menu mở đúng màn.

---

## ADM-01 — Users (`/admin/users`)

| | |
|--|--|
| **API** | `GET /users`, `PATCH /users/{id}` |

### YÊU CẦU PRODUCT

- List user: id, tên, email, SĐT; sửa họ tên SĐT địa chỉ; lỗi hiện rõ.

### Mapping PATCH

| UI | Map key |
|----|---------|
| Họ đệm | `firstName` |
| Tên | `lastName` |
| SĐT | `phoneNumber` |
| Địa chỉ | `deliveryAddress` (thêm vào dialog — **hiện thiếu**) |

### Bug

- Dialog thiếu `deliveryAddress`; không list role; silent PATCH fail.

### Test tay

1. Sửa user → refresh list đúng.

---

## ADM-02 — Books (`/admin/books` + `BookFormScreen`)

### YÊU CẦU PRODUCT

- Admin xem **hết** sách (phân trang), thêm/sửa/xóa, upload nhiều ảnh, chọn thể loại, **sửa ảnh cũ** (giữ/xóa).

### Multipart

| Part | Nội dung |
|------|----------|
| `data` | JSON `CreateBookRequest` |
| `images` / `newImages` | files |
| query `keepImageIds` | khi edit — ids ảnh giữ lại |

### Cách implement

1. List: `fetchBooksForAdmin` page/size, UI pagination.
2. Edit: load book → hiển thị ảnh network + checkbox/xóa → build `keepImageIds`.
3. `Get.put(AdminController())` trước `Get.to(BookFormScreen)`.
4. Delete confirm dialog.

### Bug

| Bug | Chi tiết |
|-----|----------|
| List 10 | BookController search page 0 |
| Không ảnh cũ khi edit | Form chỉ `_newImages` |
| keepImageIds không gửi | PUT thiếu query |

### Test tay

1. DB 15 sách → admin xem trang 2.
2. Sửa sách xóa 1 ảnh cũ → lưu → ảnh mất trên detail.

---

## ADM-03 — Genres (`/admin/genres`)

### YÊU CẦU PRODUCT

- CRUD thể loại; confirm xóa; không xóa nếu backend báo lỗi (sách đang dùng).

### Test tay

1. Thêm "Kinh tế" → list có.
2. Xóa → confirm → mất hoặc lỗi hiện.

---

## ADM-04 — Orders (`/admin/orders`)

### YÊU CẦU PRODUCT

- Xem tất cả đơn; đổi trạng thái dropdown; **xem chi tiết** đơn (line items).

### Cách implement

1. Tap card → dialog/page `GET /orders/{id}` full detail.
2. Dropdown đổi status → snackbar success/fail (không silent).

### Bug

- Không detail view; `updateOrderStatus` fail silent.

### Test tay

1. Đổi "Đang xử lý" → "Đang giao" → khách thấy cập nhật.

---

## ADM-05 — Coupons (`/admin/coupons`)

### YÊU CẦU PRODUCT

- Tạo batch mã; list phân trang; bật/tắt; xóa; thấy code, %, HSD, đã dùng.

### Mapping batch

| UI | API |
|----|-----|
| Số lượng | query `quantity` |
| % giảm | `discountPercent` |
| HSD | `expiryDate` `yyyy-MM-dd` |

### Cách implement

- `currentPage` + `fetchCoupons(page)`; nút load more.
- Dùng `CouponModel.fromJson` thay raw map.

### Bug

- Chỉ `data.content` page 0; `CouponModel` dead code.

### Test tay

1. Tạo 5 mã → list ≥5.
2. Toggle active → đổi trạng thái.

---

## ADM-06 — Feedbacks (`/admin/feedbacks`)

### YÊU CẦU PRODUCT

- Đọc phản hồi KH; đánh dấu đã đọc; xóa; phân trang.

### Cách implement

- Pagination giống coupon.
- JSON field `read` (boolean) — không nhầm `isRead`.
- Sau mark read → refresh unread badge dashboard.

### Bug

- Page 0 only; silent errors.

### Test tay

1. Gửi feedback KH → admin thấy + unread tăng.
2. Mark read → badge giảm.

---

## `AdminController` — refactor bắt buộc

**YÊU CẦU:** Mọi method trả `String? error` hoặc `ApiResult` — UI luôn snackbar.

Thay:

```dart
} catch (_) {}
```

bằng log + message từ `e.response?.data?['message']`.

---

# THỨ TỰ PHASE (dependency)

```
Phase 0: R1 → R2 → R3 → R4 (test Postman)
Phase 1: CAT ảnh → CART → CHK (prefill+totals) → CHK-02 → ORD
Phase 2: INFRA + AUTH (navigateAfterAuth) → CAT home/products → PRF full
Phase 3: FAV → FDB → ORD review polish
Phase 4: ADM-GUARD → ADM-00..06
Phase 5: Dead code, README _hostIp, master checklist
```

---

# CHECKLIST NGHIỆM THU (tick từng dòng)

## Phase 0 — Backend
- [ ] R1 images in GET book
- [ ] R2 order details in GET order
- [ ] R3 order totals server-side > 0
- [ ] R4 Feign stock check works

## AUTH
- [ ] AUTH-01 ADMIN/USER routing
- [ ] AUTH-02 register → activate
- [ ] AUTH-03 forgot shows errors
- [ ] AUTH-04 activate OK

## Catalog
- [ ] CAT-01 bestseller + images
- [ ] CAT-02 search debounce + genre + pagination
- [ ] CAT-03 detail gallery stock cart fav

## Commerce
- [ ] CART-01 enriched lines + total
- [ ] CHK-01 prefill profile + totals + ship + coupon
- [ ] CHK-02 success shows orderId
- [ ] ORD-01 list + error + refresh
- [ ] ORD-02 lines + cancel + review

## Profile & misc
- [ ] PRF-01 all fields + avatar
- [ ] FAV-01 batch + images
- [ ] FDB-01 StatefulWidget validate

## Admin
- [ ] ADM-GUARD blocks customer
- [ ] ADM-02 books pagination + edit images
- [ ] ADM-04 order detail
- [ ] ADM-05 coupon pagination
- [ ] ADM-06 feedback pagination + badge

## Kỹ thuật
- [ ] No `* 0` in lib
- [ ] No silent catch main flows
- [ ] CORS / port 3000 OK

---

# PROMPT COPY (gửi AI)

### --- BẮT ĐẦU COPY ---

Đọc **toàn bộ** `docs/AI_MASTER_PROMPT.md` (mọi module có đủ: Yêu cầu product, Mapping, Implement, Bug, Test).

Thực hiện **Phase 0 → 5** đúng thứ tự. Mỗi module AUTH/CAT/CART/CHK/ORD/PRF/FAV/FDB/ADM phải đạt tiêu chí như **CHK-01 prefill profile** (chi tiết, không bỏ sót).

Backend: **R1–R4** trước Flutter P0.  
Flutter: ADMIN→`/admin`, customer→`/home`, guard admin routes.

Báo cáo sau mỗi phase: files changed + tick checklist. Không commit.

Bắt đầu Phase 0.

### --- KẾT THÚC COPY ---

---

## Phụ lục — Bảng bug theo file

| File | Bug |
|------|-----|
| `login_screen.dart` | Always `/home` |
| `checkout_screen.dart` | prefill race, subtotal *0 |
| `cart_controller.dart` | total *0 |
| `cart_screen.dart` | bookId only UI |
| `profile_screen.dart` | missing DOB/gender |
| `orders_screen.dart` | fetch in build, no error UI |
| `order_detail_screen.dart` | empty details |
| `book/Book.java` | images JsonIgnore |
| `order/Order.java` | listOrderDetails JsonIgnore |
| `BookClient.java` | no ApiResponse unwrap |
| `OrderService.java` | client totals trusted |
| `admin/*` | no guard, pagination, silent catch |
| `book_management_screen.dart` | no keepImageIds UI |
| `forgot_password_screen.dart` | no error on fail |
| `payment_success_screen.dart` | no order id/amount |

---

*Single source of truth. Mỗi module phải chi tiết như CHK-01 (prefill profile). AI không được rút gọn khi implement.*
