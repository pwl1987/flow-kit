> 【CLAUDE CODE INSTRUCTION 强制约束】
> 本文件为安全检查清单，定义 B3 Guardrail。
> 使用 YAML 格式存储，支持自动化验证。

# B3: Security Checklist

```yaml
---
title: Security Checklist
version: 1.0
last_updated: 2026-05-06
guardrail: B3

sections:
  authentication:
    name: Authentication & Password
    items:
      - id: AUTH-01
        title: Password Hashing
        description: All passwords hashed with bcrypt (min 12 rounds) or Argon2
        check: false
        required: true
      - id: AUTH-02
        title: Password Storage
        description: No plaintext passwords in DB or logs
        check: false
        required: true
      - id: AUTH-03
        title: Session Management
        description: Secure session tokens with appropriate expiration
        check: false
        required: true
      - id: AUTH-04
        title: MFA Support
        description: MFA/2FA available for sensitive operations
        check: false
        required: false

  authorization:
    name: Authorization & Access Control
    items:
      - id: AUTHZ-01
        title: Role-Based Access
        description: RBAC or ABAC implemented for resource access
        check: false
        required: true
      - id: AUTHZ-02
        title: Privilege Escalation Prevention
        description: No direct admin access from user roles
        check: false
        required: true
      - id: AUTHZ-03
        title: API Authorization
        description: Every API endpoint validates permissions
        check: false
        required: true

  input_validation:
    name: Input Validation
    items:
      - id: INPUT-01
        title: Parameterized Queries
        description: All DB queries use parameterized statements
        check: false
        required: true
      - id: INPUT-02
        title: Input Sanitization
        description: User input sanitized before rendering or storage
        check: false
        required: true
      - id: INPUT-03
        title: File Upload Validation
        description: File uploads validated by type and content
        check: false
        required: true
      - id: INPUT-04
        title: URL Validation
        description: External URLs validated and sanitized
        check: false
        required: false

  secrets_management:
    name: Secrets Management
    items:
      - id: SECRET-01
        title: No Hardcoded Secrets
        description: No API keys, tokens, or passwords in source code
        check: false
        required: true
      - id: SECRET-02
        title: Environment Variables
        description: Secrets loaded from environment variables
        check: false
        required: true
      - id: SECRET-03
        title: Secret Rotation
        description: Process exists for rotating secrets
        check: false
        required: false
      - id: SECRET-04
        title: Secret Storage
        description: Production secrets in vault or secrets manager
        check: false
        required: true

  sql_injection:
    name: SQL Injection Prevention
    items:
      - id: SQL-01
        title: ORM Usage
        description: ORM used for data access (not raw SQL拼接)
        check: false
        required: true
      - id: SQL-02
        title: Query Validation
        description: Dynamic query construction avoided
        check: false
        required: true
      - id: SQL-03
        title: Error Handling
        description: Database errors not exposed to users
        check: false
        required: true

  xss_prevention:
    name: XSS Prevention
    items:
      - id: XSS-01
        title: Output Encoding
        description: All user data encoded before HTML rendering
        check: false
        required: true
      - id: XSS-02
        title: Content Security Policy
        description: CSP headers configured
        check: false
        required: true
      - id: XSS-03
        title: HTTPOnly Cookies
        description: Session cookies use HTTPOnly flag
        check: false
        required: true

  rate_limiting:
    name: Rate Limiting & DoS Protection
    items:
      - id: RATE-01
        title: API Rate Limiting
        description: Rate limiting on API endpoints (suggest 100/min per user)
        check: false
        required: true
      - id: RATE-02
        title: Login Rate Limiting
        description: Login attempts rate limited (suggest 5/min per IP)
        check: false
        required: true
      - id: RATE-03
        title: Input Size Limits
        description: Request body and parameters have size limits
        check: false
        required: true
```

## 验证格式

```bash
# 验证 YAML 格式
python3 -c "import yaml; yaml.safe_load(open('security-checklist.md'))"
```

## 触发条件

- Brownfield 项目检测到
- 新增 API 端点
- 认证/授权逻辑变更
- 数据存储变更

## 输出物

```
Security Checklist Status
==========================
Total Items: [count]
Required Items: [count]
Checked: [count]
Pass Rate: [percentage]

Critical Issues: [list if any]
Recommendations: [list]
```
