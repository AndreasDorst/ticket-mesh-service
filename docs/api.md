# 📘 API-документация

## 🧑 Main API (http://localhost:3002)

### Регистрация пользователя

```bash
curl -X POST http://localhost:3002/auth/register \
    -H "Content-Type: application/json" \
    -d '{
    "full_name": "Alice Smith",
    "age": 30,
    "document_type": "passport",
    "document_number": "AB123456unique",
    "password": "secret123",
    "password_confirmation": "secret123"
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
  "errors": ["Document number has already been taken"]
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

## 🎟️ Ticket API (http://localhost:3001)

### Покупка билета

```bash
curl -X POST http://localhost:3001/api/ticket/purchase  \
    -H "Content-Type: application/json" \
    -d '{
    "reservation_id": 1,
    "user_id": 2
  }'
```

🟢 **Успех:**
```json
{
    "ticket_id":10,
    "price":"1600.0"
}
```

🔴 **Ошибка (400):**
```json
{
    "error":"Ticket has already been purchased"
}
```
🔴 **Ошибка (404):**
```json
{
    "error":"User not found"
}
```

---

## 🚪 Access Control API (http://localhost:3000)

### Вход на мероприятие

```bash
curl -X POST http://localhost:3000/access_logs \
  -H "Content-Type: application/json" \
  -d '{
    "external_id": 1005,
    "document_number": "AB123456",
    "status": "entry"
  }'
```

🟢 **Успех:**
```json
{
  "message": "Access granted",
  "check_time": "2025-04-14T19:03:00Z"
}
```

🔴 **Ошибка:**
```json
{
  "error": "Ticket not found or already entered"
}
```

---

### Выход с мероприятия

```bash
curl -X POST http://localhost:3000/access_logs \
  -H "Content-Type: application/json" \
  -d '{
    "external_id": 1005,
    "document_number": "AB123456",
    "status": "exit"
  }'
```

🟢 **Успех:**
```json
{
  "message": "Exit logged",
  "check_time": "2025-04-14T20:15:00Z"
}
```

🔴 **Ошибка:**
```json
{
  "error": "Entry must be logged before exit"
}
```