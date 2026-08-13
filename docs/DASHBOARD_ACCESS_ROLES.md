# WALKA Dashboard Access Roles

CMS-004 uses a compiled, allowlisted role/capability model for the server-rendered `/admin` control plane. Permissions are not authored from the database and are never accepted from the browser or mobile client.

## Configuration

Set the backend-only environment value:

```dotenv
WALKA_ADMIN_DASHBOARD_ROLE=owner
```

Allowed values are exactly:

- `owner`
- `content_editor`
- `media_editor`
- `viewer`

The default is `owner` for backward compatibility with the existing single configured dashboard account. Any unknown role fails closed on capability-protected routes and causes `php artisan walka:production-check` to fail.

## Capability boundaries

`owner` retains all current dashboard behavior.

`content_editor` can view Dashboard, Catalog, Content, Media and Audits; it can edit, publish and restore governed Content. It cannot mutate Catalog or Media assignments/uploads/replacements.

`media_editor` can view Dashboard, Catalog, Media and Audits; it can upload, assign and replace governed Media. It cannot mutate Catalog or Content.

`viewer` has read-only access to Dashboard, Catalog, Content, Media and Audits. All governed mutation routes return HTTP 403.

## Security model

Authentication remains the existing server-side dashboard session. The configured role is resolved server-side on each protected request, and capabilities are derived only from the compiled application enum. The session does not carry a client-authored capability list.

Route middleware is the authorization boundary. Hiding or showing navigation controls is only a user-experience concern and must never be treated as authorization.

The machine Admin API bearer token remains a separate security boundary and is unaffected by dashboard roles.

## Operational check

Before exposing `/admin` in production, run:

```bash
php artisan walka:production-check
```

A valid allowlisted dashboard role is part of the production readiness result.
