<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="color-scheme" content="light">
    <title>WALKA Admin · Sign in</title>
    <style>
        :root { --navy:#003366; --gold:#D4AF37; --ink:#132536; --muted:#6d7d8c; --line:#dbe4ea; }
        * { box-sizing: border-box; }
        html, body { min-height:100%; margin:0; }
        body { min-height:100vh; display:grid; place-items:center; padding:24px; overflow-x:hidden; color:var(--ink); font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif; background: radial-gradient(circle at 15% 20%, rgba(212,175,55,.16), transparent 26%), radial-gradient(circle at 86% 10%, rgba(0,51,102,.15), transparent 28%), linear-gradient(145deg,#f7f9fa,#edf2f5); }
        .frame { width:min(1020px,100%); min-height:610px; display:grid; grid-template-columns:minmax(0,1.08fr) minmax(360px,.92fr); background:white; border:1px solid rgba(0,51,102,.10); border-radius:28px; overflow:hidden; box-shadow:0 35px 90px rgba(5,38,64,.16); }
        .story { position:relative; isolation:isolate; padding:54px; color:white; background:linear-gradient(155deg,#003366 0%,#052b49 58%,#071f34 100%); display:flex; flex-direction:column; justify-content:space-between; overflow:hidden; }
        .story::before { content:""; position:absolute; z-index:-1; width:360px; height:360px; right:-170px; top:-130px; border-radius:50%; border:1px solid rgba(212,175,55,.25); box-shadow:0 0 0 50px rgba(212,175,55,.04),0 0 0 100px rgba(212,175,55,.025); }
        .brand { display:flex; align-items:center; gap:13px; }
        .mark { width:48px; height:48px; display:grid; place-items:center; border-radius:15px; color:#0a2b45; background:linear-gradient(145deg,#efd879,var(--gold)); font:800 26px Georgia,serif; box-shadow:0 14px 30px rgba(212,175,55,.24); }
        .brand strong { font:700 24px Georgia,serif; letter-spacing:.09em; }
        .story-main { max-width:520px; }
        .eyebrow { color:#e5c75c; font-size:11px; font-weight:900; letter-spacing:.16em; text-transform:uppercase; }
        h1 { margin:12px 0 16px; font:700 clamp(36px,5vw,58px)/1.02 Georgia,"Times New Roman",serif; }
        .story p { margin:0; max-width:480px; color:#c4d3df; line-height:1.75; font-size:15px; }
        .trust { display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:10px; }
        .trust div { padding:13px; border:1px solid rgba(255,255,255,.10); background:rgba(255,255,255,.05); border-radius:13px; }
        .trust strong { display:block; color:#fff; font-size:12px; }
        .trust span { display:block; margin-top:4px; color:#9fb5c6; font-size:10px; line-height:1.4; }
        .panel { padding:54px 48px; display:flex; align-items:center; }
        .form-wrap { width:100%; max-width:390px; margin:auto; }
        .form-wrap h2 { margin:0 0 8px; color:var(--navy); font:700 32px Georgia,serif; }
        .intro { margin:0 0 28px; color:var(--muted); line-height:1.6; font-size:14px; }
        .field { display:grid; gap:8px; margin-bottom:17px; }
        label { color:#465b6d; font-size:12px; font-weight:800; }
        input { width:100%; min-height:47px; border:1px solid #cdd8e0; border-radius:12px; padding:11px 13px; outline:none; font:inherit; color:var(--ink); transition:.18s ease; }
        input:focus { border-color:#9f8427; box-shadow:0 0 0 4px rgba(212,175,55,.13); }
        button { width:100%; min-height:48px; border:0; border-radius:12px; cursor:pointer; background:var(--gold); color:#172635; font-weight:900; box-shadow:0 12px 26px rgba(212,175,55,.23); }
        .error { margin:0 0 18px; padding:12px 13px; border:1px solid #f0c9c5; border-radius:11px; background:#fff3f2; color:#922c23; font-size:12px; line-height:1.5; }
        .notice { margin-top:20px; padding-top:18px; border-top:1px solid var(--line); color:#82909c; font-size:11px; line-height:1.6; }
        .not-configured { color:#8d6300; background:#fff7df; border:1px solid #efdb9f; padding:11px 12px; border-radius:11px; margin-bottom:18px; font-size:12px; line-height:1.5; }
        @media(max-width:820px){ .frame{grid-template-columns:1fr; min-height:0;} .story{padding:32px; gap:44px;} .trust{display:none;} .panel{padding:38px 28px;} }
        @media(max-width:430px){ body{padding:0;background:white;} .frame{border:0;border-radius:0;box-shadow:none;min-height:100vh;} .story{padding:24px;min-height:260px;} .panel{padding:30px 22px;} }
    </style>
</head>
<body>
<div class="frame">
    <section class="story">
        <div class="brand"><div class="mark">W</div><strong>WALKA</strong></div>
        <div class="story-main">
            <div class="eyebrow">Private control center</div>
            <h1>Manage the storefront with confidence.</h1>
            <p>Author customer-facing catalog copy, verify API readiness, and inspect every catalog change from one protected backend surface.</p>
        </div>
        <div class="trust">
            <div><strong>Server session</strong><span>No dashboard password is shipped to Flutter.</span></div>
            <div><strong>Revision safe</strong><span>Optimistic locking prevents silent overwrites.</span></div>
            <div><strong>Audited</strong><span>Effective catalog edits remain traceable.</span></div>
        </div>
    </section>
    <section class="panel">
        <div class="form-wrap">
            <h2>Admin sign in</h2>
            <p class="intro">Use the credentials configured on the WALKA backend host.</p>
            @if (! $configured)
                <div class="not-configured">Dashboard login is not configured yet. Set <code>WALKA_ADMIN_DASHBOARD_PASSWORD</code> to a unique password of at least 12 characters.</div>
            @endif
            @if ($errors->any())
                <div class="error" role="alert">{{ $errors->first() }}</div>
            @endif
            <form method="post" action="{{ route('admin.authenticate') }}">
                @csrf
                <div class="field">
                    <label for="username">Username</label>
                    <input id="username" name="username" value="{{ old('username', 'admin') }}" autocomplete="username" required autofocus>
                </div>
                <div class="field">
                    <label for="password">Password</label>
                    <input id="password" name="password" type="password" autocomplete="current-password" required>
                </div>
                <button type="submit">Enter WALKA Admin</button>
            </form>
            <div class="notice">Protected web surface only. The public mobile API and Amazon purchase flow remain separate from dashboard authentication.</div>
        </div>
    </section>
</div>
</body>
</html>
