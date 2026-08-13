# CMS-032 PR summary

Implements issue #329 on top of merged CMS-030/CMS-031.

Primary behavior:

- durable product/variant media galleries with foreign-key integrity;
- atomic replace/reorder with bounded size, unique positions/assets and optimistic revision protection;
- assignable media restricted to admitted product-purpose assets with canonical derivatives;
- protected admin gallery editor;
- allowlisted public metadata API with deterministic product fallback for variants without explicit assignments;
- archive invalidation and no private storage-path leakage;
- regression coverage for authentication, eligibility, duplicates, max size, stale writes, fallback, override and public allowlisting.

No binary media processing, Product Master mutation, protected Images changes, Flutter remote binary delivery or #230 closure is claimed.
