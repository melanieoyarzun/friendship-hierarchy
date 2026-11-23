#!/usr/bin/env python3
"""Stage the companion website and redirect its earlier /analysis/ URLs."""

import html
import json
import posixpath
from pathlib import Path
import shutil


def main():
    root = Path(__file__).resolve().parent.parent
    source = root / "notebooks" / "_site"
    output = root / "website" / "_site"
    if not (source / "index.html").is_file():
        raise SystemExit("Run 'quarto render notebooks' before staging the site.")
    if output.exists():
        shutil.rmtree(output)
    shutil.copytree(source, output)

    # Publish the latest reproduced assembly in the Figure 3 overview.
    for suffix in (".pdf", ".png"):
        name = "figure3_assembled_20261121" + suffix
        figure = root / "output" / "figures" / name
        if figure.is_file():
            shutil.copy2(figure, output / "main" / name)

    # Keep existing page links working after moving the sidebar site to the root.
    pages = sorted(source.rglob("*.html"))
    base_url = "https://melanieoyarzun.github.io/friendship-hierarchy/"
    for page in pages:
        relative = page.relative_to(source)
        legacy = Path("analysis") / relative
        target = posixpath.relpath(relative.as_posix(), legacy.parent.as_posix())
        canonical = relative.as_posix()
        if relative.name == "index.html":
            target = target.removesuffix("index.html")
            canonical = canonical.removesuffix("index.html")
        destination = output / legacy
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(
            '<!doctype html>\n<html lang="en"><head>\n'
            '<meta charset="utf-8">\n'
            '<title>Replication companion website</title>\n'
            f'<link rel="canonical" href="{html.escape(base_url + canonical)}">\n'
            f'<meta http-equiv="refresh" content="0; url={html.escape(target)}">\n'
            '<script>window.location.replace('
            f'{json.dumps(target)} + window.location.search + window.location.hash);</script>\n'
            '</head><body>\n'
            f'<p><a href="{html.escape(target)}">Continue to the replication companion website.</a></p>\n'
            '</body></html>\n'
        )
    print(f"Staged {len(pages)} pages and redirects for their earlier /analysis/ URLs.")


if __name__ == "__main__":
    main()
