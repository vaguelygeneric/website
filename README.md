# The Generic — Jekyll Site

A podcast website for *The Generic*, built with Jekyll and designed to deploy on GitHub Pages.

---

## Quick Start

### Prerequisites
- Ruby 3.x
- Bundler (`gem install bundler`)

### Local Development

```bash
# Install dependencies
bundle install

# Serve locally with live reload
bundle exec jekyll serve --livereload

# Visit http://localhost:4000
```

---

## Deploying to GitHub Pages

### Option A: GitHub Actions (Recommended)
1. Push this repo to GitHub.
2. Go to **Settings → Pages**.
3. Under **Source**, select **GitHub Actions**.
4. The `.github/workflows/deploy.yml` workflow will build and deploy automatically on every push to `main`.

### Option B: Classic gh-pages Branch
1. Go to **Settings → Pages**.
2. Under **Source**, select **Deploy from a branch** → `gh-pages` → `/(root)`.
3. Run `bundle exec jekyll build` and push the `_site/` folder to the `gh-pages` branch (or use the `gh-pages` gem).

---

## Configuration

Edit `_config.yml` to update:

| Key | What it does |
|-----|-------------|
| `url` | Your GitHub Pages URL, e.g. `https://yourusername.github.io` |
| `baseurl` | Leave blank `""` for user/org sites; use `/repo-name` for project sites |
| `youtube_channel` | Your full YouTube channel URL |
| `podcast.author` | Your name or show host name |
| `podcast.email` | Contact email (shown in RSS feed) |
| `podcast.image` | Path to podcast cover art (see below) |

---

## Adding Episodes

Create a new Markdown file in `_podcast/` following this naming convention:

```
_podcast/YYYY-MM-DD-NNN-episode-slug.md
```

Use this front matter template:

```yaml
---
layout: episode
title: "Your Episode Title"
description: "A one-sentence description for RSS feeds and cards."
date: 2024-06-01
episode_number: 4
duration: "45:30"
audio_url: "https://your-audio-host.com/episode-004.mp3"
audio_size: "43700000"      # file size in bytes (du -b yourfile.mp3)
audio_type: "audio/mpeg"    # audio/mpeg for MP3, audio/x-m4a for AAC
permalink: /podcast/004-your-slug/
---

Episode show notes go here in Markdown.
```

### Hosting Audio Files

You need to host audio files separately. Good free/cheap options:
- **Buzzsprout** / **Transistor** / **Anchor (Spotify)** — dedicated podcast hosts with RSS
- **GitHub Releases** — free, upload .mp3 as a release asset, grab the direct URL
- **Amazon S3** / **Backblaze B2** — very cheap storage with direct links
- **Cloudflare R2** — free tier for small shows

---

## Podcast RSS Feed

The RSS feed lives at `/feed.xml` and is fully compatible with:
- ✅ Apple Podcasts
- ✅ Google Podcasts  
- ✅ Spotify (via RSS submission)
- ✅ Pocket Casts, Overcast, Castro, and all standard apps

The feed is generated from your `_podcast/` files automatically. You can also add episodes manually by editing `feed.xml` directly — see the commented template inside the file.

### Submitting Your Podcast

| Platform | Submission URL |
|----------|---------------|
| Apple Podcasts | https://podcastsconnect.apple.com |
| Spotify | https://podcasters.spotify.com |
| Google Podcasts | Deprecated — submit via Spotify or Apple |
| Amazon Music | https://podcasters.amazon.com |
| iHeart Radio | https://www.iheart.com/content/submit-your-podcast |

Your feed URL to submit: `https://yourusername.github.io/feed.xml`

---

## Podcast Cover Art

Replace `assets/images/podcast-cover.png` with your actual cover art.

**Requirements:**
- Square image (1:1 ratio)
- Minimum 1400×1400 px, recommended 3000×3000 px
- PNG or JPG format
- Under 512KB if possible

---

## Customization

### Colors & Theme
Edit the CSS variables at the top of `assets/css/main.css`:
```css
:root {
  --accent: #c4410c;    /* Change the brand color */
  --bg:     #f5f2eb;    /* Light mode background */
  /* ... */
}
```

### Fonts
The site uses **Syne** (headings) and **Lora** (body) from Google Fonts. To change fonts, update the `<link>` in `_layouts/default.html` and the font variables in `assets/css/main.css`.

### Navigation
Edit `_includes/header.html` to add, remove, or reorder navigation links.

### Subscribe Links
Edit `_includes/subscribe-links.html` to update your Apple Podcasts, Spotify, and other platform URLs once your show is listed.

---

## File Structure

```
the-generic-site/
├── _config.yml              # Site configuration
├── _layouts/
│   ├── default.html         # Base layout (all pages)
│   ├── page.html            # Generic page layout
│   └── episode.html         # Individual episode layout
├── _includes/
│   ├── header.html          # Site header + nav
│   ├── footer.html          # Site footer
│   └── subscribe-links.html # Reusable subscribe buttons
├── _podcast/                # Episode markdown files
│   ├── 2024-01-15-001-pilot.md
│   └── ...
├── assets/
│   ├── css/main.css         # All styles (light + dark mode)
│   ├── js/
│   │   ├── theme.js         # Dark/light mode toggle
│   │   └── main.js          # Navigation + interactions
│   └── images/
│       └── podcast-cover.png  # ← Replace with your art
├── .github/workflows/
│   └── deploy.yml           # GitHub Actions auto-deploy
├── index.html               # Home page
├── podcast.html             # Episode listing page
├── about.md                 # About page
├── feed.xml                 # Podcast RSS feed
├── 404.html                 # 404 page
└── Gemfile                  # Ruby dependencies
```

---

## Light / Dark Mode

The site respects the visitor's OS preference by default (`prefers-color-scheme`). Visitors can override with the sun/moon toggle button in the header. Their preference is saved to `localStorage` and persists across visits.

---

## License

Do whatever you want with this. It's your podcast.
