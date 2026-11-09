# Bound Photos image loading and release inactive photo views

Photos currently loads images for whole nearby months and decodes four full-size neighbours when a photo opens. Hovering a tile can also decode its large image. Once opened, the Photos screen stays mounted when another section is selected, retaining image references. Background preparation also processes unopened photos after sync.

Load grid images only near the viewport and share a conservative 32 MiB budget of requested decoded pixels, with a maximum 512-pixel long edge. Remove sources outside the viewport and unmount the photo tree when its section or window is hidden. Preserve the lightweight view choice and explicitly lock Hidden in the backend on teardown. Remove hover and neighbouring-photo predecodes, bound explicit in-flight warmups and URL bookkeeping, cap concurrent resizing at two jobs, and limit glibc arenas in the Flatpak environment.

Whole-library background prefetch becomes opt-in through `SKYKEEP_PREFETCH_PHOTOS=1`; on-demand loading and the existing disk cache remain available. Reopening Photos rebuilds the image tree, so scroll position, selection and album navigation are reset. Large grid cells can use softer thumbnails. The 32 MiB figure bounds requested grid pixels, not total WebKit or process memory.

Validation against v0.1.12:

- TypeScript production build and Rust formatting checks pass.
- Existing Photos, shared album, shared library switcher, Hidden locking and 20,000-photo navigation suites pass in Chromium.
- New 1,800-photo test loads 42 nearby thumbnail sources, approximately 2.6 MiB of requested pixels at 1280×800, and checks the budget, no large hover/adjacent requests, offscreen source removal, section teardown and visibility teardown/restoration.
- Hidden locking coverage now checks the backend while the photo tree is unmounted.

Local review note: collect feedback from the installed build and, before publication, add any controlled WebKitGTK memory measurements available. Restart-based observations are not a causal benchmark and no 150–200 MiB total-memory guarantee is claimed. This draft excludes the separate Flatpak “Show in Folder” correction.
