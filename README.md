# VaguelyGeneric — Website

The Jekyll source for [vaguelygeneric.website](https://vaguelygeneric.website) — an umbrella content platform hosting media content.

---

## What's Here

- **Podcast shows** with individual episode pages, show index pages, and per-show RSS feeds
- **Blog** for updates and behind-the-scenes posts
- **Guest directory** with individual guest profiles that auto-populate with their episode appearances
- **Light/dark mode** that follows OS preference by default, overridable per-visitor
- **Responsive layout** down to mobile

---

## Shows

| Show | Slug | Feed |
|------|------|------|
| The Generic | `generic` | `/feed/generic.xml` |
| Ramblings | `ramblings` | `/feed/ramblings.xml` |
| Readings | `readings` | `/feed/readings.xml` |

Show metadata (name, description, author, RSS category, cover art path, feed URL) lives in `_config.yml` under `shows:`. Adding or renaming a show means editing that block — the nav dropdown, show index pages, RSS feeds, and episode back-links all pull from it.

---

## File Structure

```
vaguelygeneric/
├── _config.yml                  # Site config, show metadata, collections
├── _layouts/
│   ├── default.html             # Base layout (all pages)
│   ├── episode.html             # Individual episode page
│   ├── guest.html               # Individual guest profile page
│   ├── page.html                # Generic content page
│   └── post.html                # Blog post
├── _includes/
│   ├── header.html              # Site header + nav (with dropdown)
│   ├── footer.html              # Site footer + RSS link
│   ├── show-index.html          # Reusable show episode listing
│   └── subscribe-links.html     # Platform subscribe links (RSS, Apple, Spotify, etc.)
├── _podcast/
│   ├── generic/                 # Episodes for The Generic
│   ├── ramblings/               # Episodes for Ramblings
│   └── readings/                # Episodes for Readings
├── _guests/                     # Guest profile markdown files
├── _posts/                      # Blog posts
├── podcast/
│   ├── generic/index.html       # Show index page — The Generic
│   ├── ramblings/index.html     # Show index page — Ramblings
│   └── readings/index.html      # Show index page — Readings
├── feed/
│   ├── generic.xml              # RSS feed — The Generic
│   ├── ramblings.xml            # RSS feed — Ramblings
│   └── readings.xml             # RSS feed — Readings
├── blog/index.html              # Blog listing
├── guests/index.html            # Guest directory
├── podcast.html                 # All shows landing page
├── about.md                     # About page
├── index.html                   # Home page
├── 404.html                     # 404 page
└── assets/
    ├── css/main.css             # All styles (light + dark mode, full design system)
    ├── js/theme.js              # Dark/light mode — reads OS pref, persists to localStorage
    ├── js/main.js               # Mobile nav, dropdown toggle
    └── images/
        ├── guest-placeholder.svg
        ├── podcast-cover.png            # Cover art — The Generic
        ├── podcast-cover-ramblings.png  # Cover art — Ramblings
        └── podcast-cover-readings.png   # Cover art — Readings
```

---

## Local Development

**Prerequisites:** Ruby 3.x, Bundler

```bash
bundle install
bundle exec jekyll serve --livereload
# → http://localhost:4000
```

---

## Deployment

Pushes to `main` trigger the GitHub Actions workflow at `.github/workflows/deploy.yml`, which builds with Jekyll and deploys to GitHub Pages automatically.

The `development` branch is used for active work. Merge to `main` to deploy.

---

## Adding a New Episode

Create a Markdown file in `_podcast/{show-slug}/`:

```
_podcast/generic/2024-06-01-004-episode-slug.md
```

**Front matter:**

```yaml
---
show: generic
title: "Episode Title"
description: "One sentence — shown on cards, episode lists, and in the RSS feed."
date: 2024-06-01
episode_number: 4
duration: "45:30"
audio_url: "https://your-audio-host.com/episode-004.mp3"
audio_size: "43700000"        # bytes — run: du -b yourfile.mp3
audio_type: "audio/mpeg"      # audio/mpeg for MP3, audio/x-m4a for AAC
permalink: /podcast/generic/004-episode-slug/
guests:
  - jane-doe                   # must match a filename slug in _guests/
---

Show notes in Markdown here.
```

**What happens automatically:**
- Episode appears on the show index page (`/podcast/generic/`)
- Episode appears in Latest Episodes on the home page if it's one of the 3 most recent across all shows
- Episode is added to the show's RSS feed (`/feed/generic.xml`)
- If guests are listed, the episode appears on each guest's profile page

**What you do manually:**
- Host the audio file (GitHub Releases, S3, Backblaze B2, Buzzsprout, etc.) and paste the URL
- Get the file size in bytes (`du -b yourfile.mp3`)
- Create a guest file first if it's someone new

---

## Adding a Guest

Create a Markdown file in `_guests/`:

```
_guests/first-last.md
```

```yaml
---
layout: guest
name: "First Last"
slug: first-last
title: "Their Title or Descriptor"
website: "https://theirsite.com"
twitter: "theirhandle"
instagram: "theirhandle"
photo:                         # leave blank for silhouette placeholder
---

A short bio in Markdown.
```

The `slug` must match exactly what you list under `guests:` in episode front matter. Episode appearances populate automatically on the guest's page.

---

## Adding a Blog Post

Create a Markdown file in `_posts/`:

```
_posts/2024-06-01-post-slug.md
```

```yaml
---
title: "Post Title"
description: "One sentence shown on the blog listing and home page preview."
date: 2024-06-01
tags: [updates, behind-the-scenes]
---

Post content in Markdown.
```

---

## Adding a New Show

1. Add an entry to `shows:` in `_config.yml`:

```yaml
- name: "New Show"
  slug: new-show
  description: "What it's about."
  subtitle: "Tagline"
  author: "VaguelyGeneric"
  email: "hello@vaguelygeneric.website"
  language: "en-us"
  category: "Society & Culture"
  subcategory: "Personal Journals"
  explicit: "false"
  image: "/assets/images/podcast-cover-new-show.png"
  feed_url: "/feed/new-show.xml"
```

2. Create `_podcast/new-show/` for episode files
3. Create `podcast/new-show/index.html` (copy an existing show index, update `show_slug` and `permalink`)
4. Create `feed/new-show.xml` (copy an existing feed file, update `show_slug` in the front matter)
5. Add cover art to `assets/images/`
6. The nav dropdown populates from `shows:` automatically

---

## RSS Feeds

Each show has its own feed, generated from the `_podcast/{slug}/` collection filtered by `show:` field:

| Feed | URL |
|------|-----|
| The Generic | `https://vaguelygeneric.website/feed/generic.xml` |
| Ramblings | `https://vaguelygeneric.website/feed/ramblings.xml` |
| Readings | `https://vaguelygeneric.website/feed/readings.xml` |

Feeds are compatible with Apple Podcasts, Spotify (via RSS import), Pocket Casts, Overcast, and all standard podcast apps. Each feed file also contains a commented-out manual episode template for adding episodes without a Markdown file.

**Submitting to platforms:**

| Platform | URL |
|----------|-----|
| Apple Podcasts | https://podcastsconnect.apple.com |
| Spotify | https://podcasters.spotify.com |
| Amazon Music | https://podcasters.amazon.com |
| iHeart | https://www.iheart.com/content/submit-your-podcast |

---

## Configuration Reference

Key fields in `_config.yml`:

| Field | Purpose |
|-------|---------|
| `url` | Full site URL — used in RSS feeds and SEO tags |
| `baseurl` | Leave blank for apex domain; use `/repo-name` for project sites |
| `youtube_channel` | YouTube channel URL — used in nav and home page |
| `shows` | Array of show definitions — drives nav, RSS, episode back-links |

---

## Cover Art Requirements

Apple Podcasts requires square artwork between 1400×1400 and 3000×3000 px, PNG or JPG, under 512KB where possible. One image per show, referenced in `_config.yml` under `shows[].image`.

---

## Theme & Colors

CSS variables are defined at the top of `assets/css/main.css` under `:root` (light mode) and `[data-theme="dark"]`. The accent color, background, surface, border, and text colors are all tokenized — change the variables to retheme the entire site.

Font stack: **Syne** (headings/UI) + **Lora** (body), both loaded from Google Fonts in `_layouts/default.html`.