# 📘 API-документация

## 🧑 Main API (http://localhost:3002)

### Регистрация пользователя

```bash
curl -X POST http://localhost:3002/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "full_name": "Иван Иванов",
      "age": 30,
      "document_type": "passport",
      "document_number": "AB123456",
      "password": "secret123",
      "password_confirmation": "secret123"
    }
  }'
```

🟢 **Успех (201):**
```json
{
    "user_id":7
}
```

🔴 **Ошибка (422):**
```json
{
  "errors": ["Password can't be blank", "Document number has already been taken"]
}
```

---

### Аутентификация

```bash
curl -X POST http://localhost:3002/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "document_number": "AB123456",
    "password": "secret123"
  }'
```

🟢 **Успех (200):**
```json
{
    "success":true
}
```

🔴 **Ошибка (401):**
```json
{
    "errors":["Неверный номер документа или пароль"]
}
```

---

### Выход

```bash
curl -X POST http://localhost:3002/auth/logout
```

🟢 **Успех (200):**
```json
{
  "success": true
}
```

---

### Получить пользователя по ID

```bash
curl -X GET http://localhost:3002/users/1
```

🟢 **Успех (200):**
```json
{
  "full_name": "Иван Иванов",
  "document_number": "AB123456"
}
```

🔴 **Ошибка (404):**
```json
{
  "error": "Пользователь не найден"
}
```

---

### Создание мероприятия

```bash
curl -X POST http://localhost:3000/events \
  -H "Content-Type: application/json" \
  -d '{
    "event": {
      "event_name": "Tech Conference 2025",
      "event_date": "2025-05-01",
      "base_tickets_amount": 100,
      "vip_tickets_amount": 20,
      "base_ticket_price": 1000,
      "vip_ticket_price": 3000
    }
  }'
```

🟢 **Успех (200):**
```json
{
  "success": true,
  "event_id": 42
}
```

🔴 **Ошибка:**
```json
{
  "error": "Service unavailable"
}
```

🔴 **Ошибка:**
```json
{
  "error": "Failed to create event (Ticket Service Error)"
}
```

🔴 **Ошибка:**
```json
{
  "error": "Unexpected error"
}
```

---

## 🎟️ Ticket API (http://localhost:3001)

### Забронировать билет

```bash
curl -X POST http://localhost:3001/api/ticket/book \
  -H "Content-Type: application/json" \
  -d '{
    "event_id": 1,
    "category": "base"
  }'
```

🟢 **Успех:**
```json
{
  "reservation_id": 15,
  "price": 1000.0,
  "expires_at":"2025-04-15T19:18:14Z"
}
```

🔴 **Ошибка:**
```json
{
  "error": "Unknown category"
}
```

🔴 **Ошибка (404):**
```json
{
  "error": "No available tickets"
}
```

🔴 **Ошибка (404):**
```json
{
  "error": "Ticket was already booked"
}
```

---

### Получить информацию о билете

```bash
curl http://localhost:3001/api/ticket/info/101
```

🟢 **Успех:**
```json
{
  "document_number": "AB123456",
  "event_id": 1,
  "full_name": "Иван Иванов",
  "category": "base",
  "status": "sold"
}
```

🔴 **Ошибка:**
```json
{
  "error": "Ticket not found"
}
```

---

### Отменить бронь

```bash
curl -X DELETE http://localhost:3001/api/ticket/book/15
```

🟢 **Успех:**
```json
{
  "status": "cancelled"
}
```

🔴 **Ошибка:**
```json
{
  "error": "Booking not found"
}
```

🔴 **Ошибка:**
```json
{
  "error": "Booking already expired"
}
```

🔴 **Ошибка:**
```json
{
  "error": "Ticket has already been purchased and cannot be cancelled"
}
```

---

### Заблокировать билет за нарушение

```bash
curl -X POST http://localhost:3001/api/ticket/block \
  -H "Content-Type: application/json" \
  -d '{
    "ticket_id": 101,
    "document_number": "AB123456"
  }'
```

🟢 **Успех:**
```json
{
  "blocked": true
}
```

🔴 **Ошибка:**
```json
{
  "error": "Document does not match ticket holder"
}
```

---

### Получить цену билета

```bash
curl "http://localhost:3001/api/ticket/price?event_id=1&category=vip"
```

🟢 **Успех:**
```json
{ "category": "vip", "price": 3000.0 }
```

🔴 **Ошибка:**
```json
{ "error": "Unknown category: student" }
```

---

### Создать пачку билетов

```bash
curl -X POST http://localhost:3001/api/ticket/bulk_create \
  -H "Content-Type: application/json" \
  -d '{
    "event_id": 42,
    "base_tickets_count": 100,
    "vip_tickets_count": 10,
    "base_price": 1000.0,
    "vip_price": 2500.0
  }'
```

🟢 **Успех:**
```json
{
  "created": {
    "base": 100,
    "vip": 10
  }
}
```

🔴 **Ошибка:**
```json
{
  "error": "Event creation failed: Validation failed: ..."
}
```

---

### Приобрести билет

```bash
curl -X POST http://localhost:3001/api/ticket/purchase \
  -H "Content-Type: application/json" \
  -d '{
    "reservation_id": 15,
    "user_id": 1
  }'
```

🟢 **Успех:**
```json
{
  "ticket_id": 101,
  "price": 1000.0
}
```

🔴 **Ошибка:**
```json
{ "error": "Booking has expired" }
```

🔴 **Ошибка:**
```json
{ "error": "Ticket has already been purchased" }
```

🔴 **Ошибка:**
```json
{ "error": "Failed to save user locally", "details": "..." }
```

---

## 🚪 Access Control API (http://localhost:3000)

---

### Вход на мероприятие

```bash
curl -X POST http://localhost:3000/access/entry \
  -H "Content-Type: application/json" \
  -d '{
    "ticket_id": 1005,
    "document_number": "AB123456"
  }'
```

🟢 **Успех:**
```json
{
  "access_granted": true,
  "log_id": 1
}
```

🔴 **Ошибка:**
```json
{
  "error": "Already inside"
}
```

🔴 **Ошибка:**
```json
{
  "error": "Invalid credentials"
}
```

---

### Выход с мероприятия

```bash
curl -X POST http://localhost:3000/access/exit \
  -H "Content-Type: application/json" \
  -d '{
    "ticket_id": 1005
  }'
```

🟢 **Успех:**
```json
{
  "exit_registered": true,
  "log_id": 2
}
```

🔴 **Ошибка:**
```json
{
  "error": "Not inside"
}
```

🔴 **Ошибка:**
```json
{
  "error": "Ticket not found"
}
```

---

### Получение журналов доступа

```bash
curl -X GET http://localhost:3000/access_logs \
  -H "Content-Type: application/json" \
  -d '{
    "type": "entry",
    "status": "entry",
    "date": "2025-04-14"
  }'
```

🟢 **Успех:**
```json
[
  {
    "id": 1,
    "ticket_id": 1005,
    "status": "entry",
    "check_time": "2025-04-14T19:03:00Z"
  },
  {
    "id": 2,
    "ticket_id": 1006,
    "status": "entry",
    "check_time": "2025-04-14T19:15:00Z"
  }
]
```

🔴 **Ошибка:**
```json
{
  "error": "No access logs found"
}
```