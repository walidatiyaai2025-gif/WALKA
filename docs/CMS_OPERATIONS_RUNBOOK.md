# WALKA CMS Operations Runbook

Tracking: #278 · CMS-052, CMS-053, CMS-054, CMS-055

This runbook covers read-only/controlled operational workflows added after the backend-first mobile CMS foundation. It does not authorize Product Master, ASIN/Pantone, credentials, arbitrary SQL or executable Flutter changes.

## 1. Owner rollback workflow — CMS-052

1. Open `/admin/content`.
2. For any managed entry, choose **History / diff / rollback**.
3. Inspect current revision, published revision and the immutable timeline.
4. Choose the historical revision to recover.
5. Enter a bounded rollback reason and confirm.
6. The selected historical payload is copied into a **new private draft revision**.
7. The live published revision remains unchanged.
8. Review the new draft/diff. Publish separately only after approval.

Every actual restore receipt records the source revision, new draft revision, actor fingerprint and reason in the existing immutable content revision ledger.

## 2. Publication observability — CMS-053

Dashboard:

```text
/admin/content/health
/admin/content/health.json
```

Both routes require a valid dashboard session and `content.view`. The report intentionally excludes draft/published payload bodies and secrets. It includes current/published revision, publication age/freshness class, draft state, schedule state and the same ETag/Cache-Control metadata used by the public delivery controller.

A stale schedule means `schedule_revision` no longer equals the entry's current revision. It is fail-closed and must be reviewed/rescheduled; it will not execute against a changed draft.

## 3. Metadata backup and restore-package validation — CMS-054

Create a private canonical metadata backup:

```bash
cd backend
php artisan walka:cms-backup
```

Or provide an explicit private output path:

```bash
php artisan walka:cms-backup /secure/private/path/walka-cms.json
```

The envelope contains governed CMS/catalog presentation/media metadata, record counts, schema version, UTC generation timestamp and SHA-256 integrity digest. It excludes credentials, sessions, raw media bytes and storage paths. Product/Variant protected identity is represented by comparison hashes so restore validation cannot authorize ASIN/Pantone/Product Master drift.

Validate a candidate package without writing database state:

```bash
php artisan walka:cms-backup-validate /secure/private/path/walka-cms.json
```

Validation fails closed for malformed/unknown sections, digest mismatch, protected identity drift, revision gaps, invalid source revisions and dangling catalog/media references. This command is a **dry run only**; it is not an automatic restore/import command.

## 4. Production smoke matrix — CMS-055

Hermetic deployment-checkout smoke:

```bash
cd backend
php artisan walka:cms-smoke
```

Machine-readable evidence:

```bash
php artisan walka:cms-smoke --json
```

When the API is deployed and reachable, add read-only live HTTP verification:

```bash
php artisan walka:cms-smoke --live-base-url=https://api.walkastore.com --json
```

The live mode performs GET/conditional-GET checks only. It verifies health/catalog availability and, for published governed content, the expected ETag + Cache-Control contract plus HTTP 304 behavior. It does not create drafts, publish content, mutate catalog/media, or change commerce destinations.

The full monorepo mode also checks that Flutter's production API client contains the exact governed endpoint paths and that the bundled storefront still preserves `amazon_redirect`. A backend-only deployment checkout may explicitly use `--no-flutter-source`; that mode does not claim Flutter-source verification.

Any failed smoke check exits non-zero. Treat a PASS receipt as deployment evidence, not as permission to bypass the normal publish/rollback controls.

## 5. Scheduler prerequisite

CMS-050 scheduled publication still requires the Laravel scheduler to be invoked by the production host. For cPanel/cron, run Laravel `schedule:run` every minute using the deployed PHP binary and backend path. The CMS schedule runner itself remains overlap-protected and revision-protected.
