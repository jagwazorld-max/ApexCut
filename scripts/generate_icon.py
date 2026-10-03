#!/usr/bin/env python3
"""Write a 1024x1024 ApexCut launcher icon (no third-party deps)."""
from __future__ import annotations

import pathlib
import struct
import zlib


def chunk(tag: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


def color(x: int, y: int, w: int, h: int) -> tuple[int, int, int]:
    # Near-black field
    r, g, b = 10, 10, 12
    cx, cy = w / 2, h / 2
    dx, dy = x - cx, y - cy
    dist = (dx * dx + dy * dy) ** 0.5
    # Soft vignette
    vig = max(0.0, 1.0 - dist / (w * 0.72))
    r = int(r + 18 * vig)
    g = int(g + 18 * vig)
    b = int(b + 22 * vig)

    # Rounded square frame
    m = int(w * 0.14)
    inner = int(w * 0.18)
    if m <= x < w - m and m <= y < h - m:
        if x < inner or x >= w - inner or y < inner or y >= h - inner:
            r, g, b = 198, 202, 210  # cool silver frame

    # Play-blade triangle, centered
    t_left = int(w * 0.40)
    t_right = int(w * 0.66)
    t_top = int(h * 0.34)
    t_bot = int(h * 0.66)
    if t_top <= y <= t_bot and t_left <= x <= t_right:
        rel = (y - t_top) / max(1, t_bot - t_top)
        max_x = t_left + int((t_right - t_left) * (1 - abs(rel * 2 - 1)))
        # left-pointing? no — standard play: left base, point right
        half = (t_bot - t_top) / 2
        yy = abs(y - cy)
        edge = t_left + int((t_right - t_left) * (1 - yy / half)) if half else t_left
        if yy <= half and x <= edge:
            r, g, b = 110, 231, 215  # teal playhead

    return r, g, b


def write_png(path: pathlib.Path, size: int = 1024) -> None:
    raw = bytearray()
    for y in range(size):
        raw.append(0)
        for x in range(size):
            raw.extend(color(x, y, size, size))
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(png)


def main() -> None:
    root = pathlib.Path(__file__).resolve().parents[1]
    dest = root / "assets" / "icons" / "app_icon.png"
    write_png(dest, 1024)
    print(f"wrote {dest} ({dest.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
