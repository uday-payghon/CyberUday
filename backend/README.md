# Cyber Uday KYC Verification Service

Spring Boot REST service for secure bank account and PAN verification.

## Endpoint

`POST /api/v1/verify/bank-pan`

Headers:

- `Content-Type: application/json`
- `X-CyberUday-Api-Key: <issued-api-key>`

Body:

```json
{
  "user_id": "user-123",
  "account_number": "12345678901",
  "ifsc_code": "HDFC0001234",
  "pan_number": "ABCDE1234A",
  "full_name": "Uday Payghon"
}
```

## Required Secrets

```bash
export CYBER_UDAY_ADMIN_SECRET="replace-with-strong-random-admin-secret"
export CYBER_UDAY_AES_256_KEY="$(openssl rand -base64 32)"
export DIGITAL_BODYGUARD_BOT_KEY="replace-with-llm-provider-key"
```

Production should enable TLS at the service or terminate TLS at a trusted gateway that forwards
`X-Forwarded-Proto: https`. The security filter requires HTTPS for the verification endpoint.

## API Key Issuance

`POST /api/v1/admin/api-keys`

Headers:

- `Content-Type: application/json`
- `X-CyberUday-Admin-Secret: <configured-admin-secret>`

Body:

```json
{
  "owner_name": "Cyber Uday Mobile App",
  "organization_type": "INTERNAL",
  "expires_at": "2027-06-20T00:00:00Z"
}
```

The response includes `api_key` exactly once. Only the SHA-256 hash and lookup prefix are stored.

Revoke a key with `POST /api/v1/admin/api-keys/{id}/revoke`.

## Cyber News Feed

`GET /api/v1/news/cyber-india`

Returns a Flutter-friendly newspaper feed:

```json
{
  "generated_at": "2026-06-20T08:00:00Z",
  "country": "IN",
  "edition": "Cyber Uday India Cyber Watch",
  "count": 4,
  "items": []
}
```

## PostgreSQL Schema

Run `src/main/resources/schema.sql` before starting with `spring.jpa.hibernate.ddl-auto=validate`.

The schema creates the verification audit trail, issued API-key metadata, and mock cyber-news tables.

## Support Chatbot

`POST /api/v1/support/chat`

Body:

```json
{
  "session_id": "landing-page-session-123",
  "message": "Is my data secure?"
}
```

The endpoint enforces HTTPS and limits each client IP address to 5 requests per minute.
The LLM provider key is read from `DIGITAL_BODYGUARD_BOT_KEY`; no bot key is hardcoded.
Optional provider settings:

```bash
export DIGITAL_BODYGUARD_BOT_ENDPOINT="https://api.openai.com/v1/responses"
export DIGITAL_BODYGUARD_BOT_MODEL="gpt-4o-mini"
export DIGITAL_BODYGUARD_BOT_TIMEOUT_SECONDS="20"
```
