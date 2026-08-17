<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="color-scheme" content="light">
    <title>@yield('title', 'WALKA Admin')</title>
    <style>
        :root {
            --navy: #003366;
            --navy-2: #082844;
            --gold: #D4AF37;
            --gold-soft: #f7efd2;
            --ink: #102235;
            --muted: #66788a;
            --line: #dfe7ee;
            --surface: #ffffff;
            --canvas: #f3f6f8;
            --success: #157347;
            --danger: #b42318;
            --shadow: 0 20px 55px rgba(12, 42, 66, .10);
        }
        * { box-sizing: border-box; }
        html, body { margin: 0; min-height: 100%; background: var(--canvas); color: var(--ink); }
        body { font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; overflow-x: hidden; }
        button, input, textarea { font: inherit; }
        a { color: inherit; }
        .shell { min-height: 100vh; display: grid; grid-template-columns: 264px minmax(0, 1fr); }
        .sidebar { position: sticky; top: 0; height: 100vh; padding: 28px 20px; color: #fff; background: linear-gradient(180deg, var(--navy), #021f38 70%, #01182b); display: flex; flex-direction: column; gap: 28px; }
        .brand { display: flex; align-items: center; gap: 12px; padding: 0 8px; }
        .brand-mark { width: 42px; height: 42px; border-radius: 14px; display: grid; place-items: center; color: var(--navy); background: linear-gradient(145deg, #f1d778, var(--gold)); box-shadow: 0 12px 28px rgba(212,175,55,.25); font-family: Georgia, serif; font-weight: 800; font-size: 23px; }
        .brand-copy strong { display: block; font-family: Georgia, "Times New Roman", serif; font-size: 21px; letter-spacing: .08em; }
        .brand-copy span { color: #b8c9d8; font-size: 12px; letter-spacing: .08em; text-transform: uppercase; }
        .nav { display: grid; gap: 8px; }
        .nav a { text-decoration: none; padding: 12px 14px; border-radius: 12px; color: #c9d7e3; display: flex; gap: 11px; align-items: center; font-weight: 650; font-size: 14px; transition: background .18s ease, color .18s ease, transform .18s ease; }
        .nav a:hover { background: rgba(255,255,255,.08); color: #fff; transform: translateX(2px); }
        .nav a.active { background: rgba(212,175,55,.16); color: #fff; box-shadow: inset 3px 0 0 var(--gold); }
        .nav-icon { width: 28px; height: 28px; border-radius: 9px; display: grid; place-items: center; background: rgba(255,255,255,.08); font-size: 13px; }
        .sidebar-foot { margin-top: auto; border-top: 1px solid rgba(255,255,255,.12); padding-top: 18px; }
        .sidebar-foot p { margin: 0 0 12px; color: #a8bdcf; font-size: 12px; line-height: 1.55; }
        .role-pill { display: inline-flex; align-items: center; margin-bottom: 12px; padding: 6px 9px; border: 1px solid rgba(212,175,55,.28); border-radius: 999px; color: #f4dda0; background: rgba(212,175,55,.08); font-size: 10px; font-weight: 850; letter-spacing: .06em; text-transform: uppercase; }
        .logout { width: 100%; border: 1px solid rgba(255,255,255,.16); color: white; background: rgba(255,255,255,.05); padding: 10px 12px; border-radius: 10px; cursor: pointer; font-weight: 700; }
        .content { min-width: 0; }
        .topbar { height: 78px; padding: 0 32px; border-bottom: 1px solid var(--line); background: rgba(255,255,255,.86); backdrop-filter: blur(16px); display: flex; align-items: center; justify-content: space-between; gap: 20px; position: sticky; top: 0; z-index: 10; }
        .topbar-title { min-width: 0; }
        .topbar-title strong { display: block; font-family: Georgia, "Times New Roman", serif; color: var(--navy); font-size: 20px; }
        .topbar-title span { display: block; margin-top: 3px; color: var(--muted); font-size: 12px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .live-pill { flex: 0 0 auto; border: 1px solid #c8e7d7; background: #effaf4; color: var(--success); border-radius: 999px; padding: 8px 11px; font-size: 12px; font-weight: 800; display: flex; align-items: center; gap: 7px; }
        .live-dot { width: 8px; height: 8px; border-radius: 50%; background: #20a667; box-shadow: 0 0 0 5px rgba(32,166,103,.10); }
        .page { width: min(1440px, 100%); margin: 0 auto; padding: 32px; }
        .page-head { display: flex; justify-content: space-between; align-items: flex-end; gap: 20px; margin-bottom: 26px; }
        .eyebrow { margin: 0 0 7px; color: #9a7a13; text-transform: uppercase; letter-spacing: .14em; font-size: 11px; font-weight: 850; }
        h1, h2, h3 { margin-top: 0; color: var(--navy); font-family: Georgia, "Times New Roman", serif; }
        h1 { margin-bottom: 7px; font-size: clamp(30px, 3vw, 42px); line-height: 1.05; }
        h2 { margin-bottom: 14px; font-size: 22px; }
        h3 { margin-bottom: 8px; font-size: 17px; }
        .lead { margin: 0; color: var(--muted); line-height: 1.65; max-width: 780px; }
        .grid { display: grid; gap: 18px; }
        .metrics { grid-template-columns: repeat(4, minmax(0, 1fr)); }
        .two { grid-template-columns: minmax(0, 1.3fr) minmax(300px, .7fr); }
        .card { min-width: 0; border: 1px solid var(--line); border-radius: 18px; background: var(--surface); box-shadow: 0 8px 28px rgba(12,42,66,.055); padding: 22px; }
        .metric { position: relative; overflow: hidden; }
        .metric::after { content: ""; position: absolute; width: 90px; height: 90px; right: -30px; top: -35px; border-radius: 50%; background: var(--gold-soft); }
        .metric-label { color: var(--muted); font-size: 12px; font-weight: 750; text-transform: uppercase; letter-spacing: .08em; }
        .metric-value { margin-top: 9px; color: var(--navy); font-family: Georgia, serif; font-size: 32px; font-weight: 800; }
        .metric-note { margin-top: 6px; color: #7c8d9d; font-size: 12px; }
        .status-row { display: flex; align-items: center; justify-content: space-between; gap: 15px; padding: 13px 0; border-bottom: 1px solid #edf1f4; }
        .status-row:last-child { border-bottom: 0; padding-bottom: 0; }
        .status-row:first-child { padding-top: 0; }
        .status-row strong { font-size: 13px; }
        .badge { border-radius: 999px; padding: 6px 9px; font-size: 11px; font-weight: 850; }
        .badge.good { background: #eaf8f1; color: var(--success); }
        .badge.warn { background: #fff5dc; color: #8b6500; }
        .badge.lock { background: #edf3f8; color: #405b72; }
        .flash, .errors { margin-bottom: 20px; padding: 14px 16px; border-radius: 13px; font-size: 13px; line-height: 1.5; }
        .flash { border: 1px solid #c8e7d7; background: #effaf4; color: #11623e; }
        .errors { border: 1px solid #f3c7c3; background: #fff3f2; color: #8f261d; }
        .errors ul { margin: 0; padding-left: 18px; }
        .btn { appearance: none; border: 0; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 8px; min-height: 42px; padding: 10px 15px; border-radius: 11px; cursor: pointer; font-weight: 800; font-size: 13px; }
        .btn.primary { background: var(--gold); color: #182331; box-shadow: 0 9px 22px rgba(212,175,55,.18); }
        .btn.secondary { border: 1px solid var(--line); background: #fff; color: var(--navy); }
        .btn.navy { background: var(--navy); color: #fff; }
        .table-wrap { width: 100%; overflow-x: auto; border: 1px solid var(--line); border-radius: 14px; }
        table { width: 100%; min-width: 720px; border-collapse: collapse; background: white; }
        th, td { padding: 13px 15px; border-bottom: 1px solid #edf1f4; text-align: left; vertical-align: top; font-size: 13px; }
        th { color: #66788a; background: #f8fafb; text-transform: uppercase; font-size: 10px; letter-spacing: .08em; }
        tr:last-child td { border-bottom: 0; }
        code { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 11px; background: #f0f4f7; border-radius: 6px; padding: 3px 6px; color: #294861; }
        .muted { color: var(--muted); }
        .stack { display: grid; gap: 18px; }
        .field { display: grid; gap: 7px; }
        .field label { color: #465d72; font-size: 12px; font-weight: 800; }
        .field input, .field textarea { width: 100%; min-width: 0; border: 1px solid #ccd8e1; border-radius: 11px; background: #fff; color: var(--ink); padding: 11px 12px; outline: none; transition: border .18s ease, box-shadow .18s ease; }
        .field textarea { min-height: 118px; resize: vertical; line-height: 1.55; }
        .field input:focus, .field textarea:focus { border-color: #9e8427; box-shadow: 0 0 0 4px rgba(212,175,55,.13); }
        .locked { border: 1px dashed #d4dde5; background: #f8fafb; border-radius: 12px; padding: 12px; }
        .locked-grid { display: grid; grid-template-columns: repeat(3, minmax(0,1fr)); gap: 10px; }
        .locked small { color: var(--muted); display: block; margin-bottom: 4px; }
        .locked strong { color: #365068; font-size: 12px; overflow-wrap: anywhere; }
        .section-space { margin-top: 22px; }
        .actions { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; }
        .json-editor { min-height: 360px !important; font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; font-size: 13px; tab-size: 2; }
        .preview-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px; }
        .preview-label { margin-bottom: 8px; color: var(--muted); font-size: 11px; font-weight: 850; letter-spacing: .08em; }
        .json-preview { margin: 0; min-height: 180px; max-height: 460px; overflow: auto; border: 1px solid #d9e3ea; border-radius: 13px; background: #f7f9fb; padding: 16px; color: #24435c; font: 12px/1.55 ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; white-space: pre-wrap; overflow-wrap: anywhere; }
        @media (max-width: 1080px) {
            .metrics { grid-template-columns: repeat(2, minmax(0,1fr)); }
            .two { grid-template-columns: 1fr; }
            .locked-grid { grid-template-columns: repeat(2, minmax(0,1fr)); }
        }
        @media (max-width: 760px) {
            .shell { display: block; }
            .sidebar { position: relative; height: auto; padding: 18px; gap: 16px; }
            .nav { grid-template-columns: repeat(2, minmax(0,1fr)); }
            .nav a { justify-content: center; padding: 10px 8px; font-size: 12px; }
            .nav-icon { display: none; }
            .sidebar-foot { display: none; }
            .topbar { height: 68px; padding: 0 18px; }
            .topbar-title span { max-width: 230px; }
            .page { padding: 22px 16px 34px; }
            .page-head { align-items: flex-start; flex-direction: column; }
            .metrics { grid-template-columns: 1fr 1fr; gap: 12px; }
            .card { border-radius: 15px; padding: 17px; }
            .locked-grid { grid-template-columns: 1fr; }
            .preview-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 430px) {
            .metrics { grid-template-columns: 1fr; }
            .topbar-title span { display: none; }
            .live-pill { padding: 7px 9px; }
        }
    </style>
</head>
<body>
@php
    $dashboardRole = \App\Enums\DashboardRole::tryFrom(trim((string) config('walka_dashboard.role', '')));
    $can = static fn (\App\Enums\DashboardCapability $capability): bool => $dashboardRole?->allows($capability) ?? false;
@endphp
<div class="shell">
    <aside class="sidebar">
        <div class="brand">
            <div class="brand-mark">W</div>
            <div class="brand-copy"><strong>WALKA</strong><span>Control Center</span></div>
        </div>
        <nav class="nav" aria-label="Admin navigation">
            @if ($can(\App\Enums\DashboardCapability::DashboardView))
                <a href="{{ route('admin.dashboard') }}" class="{{ request()->routeIs('admin.dashboard') ? 'active' : '' }}"><span class="nav-icon">01</span>Overview</a>
            @endif
            @if ($can(\App\Enums\DashboardCapability::CatalogView))
                <a href="{{ route('admin.catalog') }}" class="{{ request()->routeIs('admin.catalog*') ? 'active' : '' }}"><span class="nav-icon">02</span>Catalog</a>
            @endif
            @if ($can(\App\Enums\DashboardCapability::ContentView))
                <a href="{{ route('admin.content.index') }}" class="{{ request()->routeIs('admin.content*') ? 'active' : '' }}"><span class="nav-icon">03</span>Content</a>
            @endif
            @if ($can(\App\Enums\DashboardCapability::MediaView))
                <a href="{{ route('admin.media.index') }}" class="{{ request()->routeIs('admin.media*') ? 'active' : '' }}"><span class="nav-icon">04</span>Media</a>
            @endif
            @if ($can(\App\Enums\DashboardCapability::AuditsView))
                <a href="{{ route('admin.audits') }}" class="{{ request()->routeIs('admin.audits') ? 'active' : '' }}"><span class="nav-icon">05</span>Audit log</a>
            @endif
        </nav>
        <div class="sidebar-foot">
            @if ($dashboardRole !== null)
                <div class="role-pill">{{ str_replace('_', ' ', $dashboardRole->value) }}</div>
            @endif
            <p>Protected server-side dashboard. Navigation reflects the current compiled capability policy.</p>
            <form method="post" action="{{ route('admin.logout') }}">
                @csrf
                <button class="logout" type="submit">Sign out</button>
            </form>
        </div>
    </aside>
    <div class="content">
        <header class="topbar">
            <div class="topbar-title">
                <strong>@yield('topbar', 'WALKA Admin')</strong>
                <span>Laravel control plane · Flutter remains on public API v1</span>
            </div>
            <div class="live-pill"><span class="live-dot"></span>Backend Live</div>
        </header>
        <main class="page">
            @if (session('status'))
                <div class="flash" role="status">{{ session('status') }}</div>
            @endif
            @if ($errors->any())
                <div class="errors" role="alert">
                    <ul>
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif
            @yield('content')
        </main>
    </div>
</div>
</body>
</html>
