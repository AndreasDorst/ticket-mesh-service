# README

```
curl -X POST \
  http://localhost:4567/api/v1/access_logs \
  -H 'Content-Type: application/json' \
  -d '{
    "ticket_id": 123,
    "event_id": 456,
    "full_name": "Иван Петров",
    "document_number": "AB123456",
    "status": "approved",
    "category": "VIP"
  }'
```