# Scope safety

This change intentionally does not touch Home, Discovery, PDP, Favorites, Account/About presentation code or protected `Images/` masters. It only adds release governance around the canonical asset paths already owned by the production media resolver, so it can merge independently of active UI PRs #223, #226 and #227 and asset-documentation PRs #208, #212 and #228.
