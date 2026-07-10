# VaguelyGeneric - Website

The Jekyll source for [vaguelygeneric.website](https://vaguelygeneric.website) - an umbrella content platform hosting podcasts, webcomics, and serialized fiction.

---

## What's Here

- **Podcast shows** with individual episode pages, show index pages, and per-show RSS feeds
- **Webcomics** with individual strip pages (reading order) and prev/next navigation
- **Serialized stories** with individual chapter pages (reading order) and prev/next navigation
- **Blog** for updates and behind-the-scenes posts
- **People directory** with individual person profiles that auto-populate with their episode appearances
- **Scheduled publishing** - content can be drafted, dated in the future, and gated from feeds/listings until it's meant to go public
- **Light/dark mode** that follows OS preference by default, overridable per-visitor
- **Responsive layout** down to mobile

---

## Content Model

Podcasts, webcomics, and stories all follow the same two-tier pattern:

- A **property** collection (`_shows`, `_comics`, `_stories`) - one Markdown file per show/comic/story, holding its name, description, and metadata. This is what populates listing pages and back-links.
- An **installment** collection (`_podcast`, `_comic`, `_story`) - one Markdown file per episode/strip/chapter, linked to its property via a `show:`/`comic:`/`story:` field.

| Type | Property collection | Installment collection | URL pattern |
|------|---------------------|-------------------------|-------------|
| Podcast | `_shows/*.md` | `_podcast/{slug}/*.md` | `/podcast/{slug}/{episode}/` |
| Webcomic | `_comics/*.md` | `_comic/{slug}/*.md` | `/comics/{slug}/{strip}/` |
| Story | `_stories/*.md` | `_story/{slug}/*.md` | `/story/{slug}/{chapter}/` |

Note stories use the singular `/story/` in their URL, unlike the plural `/comics/` - an intentional inconsistency carried from an earlier naming decision, not a typo. The `stories.html` landing page itself is still at `/stories/`.

Podcast episodes are listed latest-first (it's a feed). Comic strips and story chapters are listed oldest-first (it's a serial - readers start at the beginning).

These are intentionally separate, parallel collections rather than one unified "content" type - a podcast show will never need chapter numbers, and a story chapter will never need an `audio_url`. Adding a new type later means adding another property/installment pair, not reshaping the existing ones.

**Nav note:** Comics and stories don't currently have their own nav dropdown or hero-pill presence - only podcast shows do (`_includes/header.html`). Reachable by direct link/landing page (`/comics/`, `/stories/`) but not yet surfaced in navigation.

---

## Dates: `created` vs `publish_date`

Two separate fields, two separate jobs:

- **`created`** - a full datetime (`2026-07-04T15:44:40`). The content's own timeline: when it was recorded/drawn/written. Doesn't drive anything user-facing on its own.
- **`publish_date`** - a date only (`2026-07-05`), no time-of-day. This is what actually controls visibility and ordering everywhere - feeds, listings, sort order, RSS `pubDate`.

Keep them equal unless you have a specific reason to diverge (e.g. something recorded well before it's actually released). If they do diverge, get `publish_date` right - it's the one that matters publicly, and reflects when something goes live.

**Why not `date`?** `created` used to be named `date`. Renamed because Jekyll silently excludes any document - in *any* collection, not just `_posts` - whose `date` field is in the future, when `site.time` (fixed at build time) is compared against it. That's an automatic, undocumented-feeling behavior with no forgiving error, just a page that never gets generated. `created` and `publish_date` are both plain custom fields Jekyll has no opinion about, so nothing gets silently excluded - visibility is entirely up to `status` and `publish_date`, both explicit and both under our control.

`publish_date` being date-only (not a datetime) is deliberate: it avoids a timing race between when something was actually recorded/authored during the day and when the nightly rebuild happens to run. A date-only `publish_date` becomes `<= now` the moment its UTC day begins, regardless of what time of day anything was created.

---

## Publishing & Scheduling

Every property and installment supports an optional `status` field:

| `status` | Behavior |
|----------|----------|
| `draft` | Never listed, regardless of date. Use this for anything not ready to be seen. |
| `scheduled` | Hidden until `publish_date` (or `created`, if `publish_date` isn't set) has passed. |
| `published` | Always listed, regardless of date. |
| *(unset)* | Same as `scheduled` - this is the default so existing content needs no changes. |

This is enforced by a shared Liquid filter in `_plugins/installment_filters.rb`, not a generator - `listed_installments` (for episodes/strips/chapters) and `listed_strands` (for whole shows/comics/stories). Every template that lists installments or strands calls one of these instead of duplicating a `where`/`where_exp` chain:

```liquid
{% assign episodes = site.podcast | listed_installments: "show", page.slug | sort: "publish_date" | reverse %}
```

**Important:** this only controls whether something is *listed* - it never removes a document from its collection, so every installment's own page still builds and is reachable by direct URL regardless of status or date. There is no page-level gating; `status: draft` hides something from feeds and nav, it does not make the URL 404.

Because this is a static site, `site.time` (what "now" means to the filter above) is only ever as current as the last build. `_plugins/generate_feeds.rb` handles RSS feed generation only - it has no gating logic of its own. Making something appear or disappear on schedule requires an actual rebuild once its `publish_date` has passed, which is what the cron schedule below is for.

---

## Deployment & Scheduled Rebuilds

Pushes to `main` trigger the GitHub Actions workflow at `.github/workflows/deploy.yml`, which builds with Jekyll and deploys to GitHub Pages. The workflow also runs on a daily `cron` schedule (`0 4 * * *`, UTC) so future-dated content goes live without a manual push, and can be triggered manually via `workflow_dispatch`.

Scheduled GitHub Actions runs are best-effort, not exact - they can and do lag the nominal cron time by a few hours, especially during high-load periods. That's normal; it doesn't mean the schedule is broken.

The site's `timezone` is set to `UTC` in `_config.yml` (chosen for travel - no daylight saving/timezone drift to account for). The cron schedule is also in UTC, so the two always agree.

The `development` branch is used for active work; feature branches (e.g. `dev/*`) branch off it for larger changes. Merge to `main` to deploy.

---

## File Structure

```
vaguelygeneric/
├── _config.yml                  # Site config, collections, defaults, timezone
├── _layouts/
│   ├── default.html             # Base layout (all pages)
│   ├── show.html                # Podcast show index page
│   ├── episode.html             # Individual podcast episode page
│   ├── show-cards.html          # Alternate card-style show index (not currently used by any page)
│   ├── comic.html               # Webcomic property index page
│   ├── comic-strip.html         # Individual comic strip page
│   ├── story.html               # Story property index page
│   ├── story-chapter.html       # Individual story chapter page
│   ├── person.html              # Individual person profile page
│   ├── page.html                # Generic content page
│   ├── post.html                # Blog post
│   └── feed.html                # RSS feed template (per show)
├── _includes/
│   ├── header.html              # Site header + nav (Podcasts dropdown only, see note above)
│   ├── footer.html              # Site footer + RSS link
│   ├── show-badge.html          # Shared show lookup + accent-colored badge
│   ├── people-credit.html       # Shared role credit line (host/guests/artist/author/contributors)
│   ├── person-card.html         # Shared person card w/ role badge pills, for /people/
│   ├── person-links.html        # Shared links: renderer (website/twitter/etc.) w/ icons
│   ├── subscribe-links.html     # Platform subscribe links (RSS, Apple, Spotify, etc.)
│   ├── daily-logo.svg           # Show-specific cover art referenced via cover_svg
│   └── lighthouse.svg
├── _shows/                      # Podcast property files
├── _podcast/{slug}/             # Podcast episode files, per show
├── _comics/                     # Webcomic property files
├── _comic/{slug}/               # Webcomic strip files, per comic
├── _stories/                    # Story property files
├── _story/{slug}/               # Story chapter files, per story
├── _people/                     # Person profile markdown files
├── _posts/                      # Blog posts
├── _plugins/
│   ├── generate_feeds.rb        # RSS feed generation only (podcast shows)
│   └── installment_filters.rb   # listed_installments / listed_strands Liquid filters
├── podcast.html                 # All podcast shows landing page
├── comics.html                  # All webcomics landing page
├── stories.html                 # All stories landing page (served at /stories/)
├── blog/index.html              # Blog listing
├── people/index.html            # People directory
├── about.md                     # About page
├── index.html                   # Home page
├── 404.html                     # 404 page
└── assets/
    ├── css/main.css             # All styles (light + dark mode, full design system)
    ├── css/podcast-cards.css    # Card-grid variant for show listings
    ├── js/theme.js              # Dark/light mode - reads OS pref, persists to localStorage
    ├── js/main.js                # Mobile nav, dropdown toggle
    └── images/
```

---

## Local Development

**Prerequisites:** Ruby 3.x, Bundler

```bash
bundle install
bundle exec jekyll serve --livereload
# → http://localhost:4000
```

`site.time` (used for the publish gate) is only recalculated when Jekyll actually rebuilds. If a scheduled item should have gone live since you started `jekyll serve`, restart the server or force a fresh `bundle exec jekyll build` - clock time passing alone doesn't trigger a rebuild, and `--incremental` mode can skip pages that depend on a collection but whose own source file didn't change.

---

## Adding a New Episode

Create a Markdown file in `_podcast/{show-slug}/`:

```
_podcast/daily/0037.md
```

**Front matter:**

```yaml
---
layout: episode
show: daily
title: "Episode 0037"
description: "One sentence - shown on cards, episode lists, and in the RSS feed."
created: 2026-07-10T14:20:00
publish_date: 2026-07-11
status: scheduled              # optional - omit for the same date-gated behavior
episode_number: 37
duration: "8:14"
audio_url: "https://your-audio-host.com/episode-0037.mp3"
audio_size: "6100000"          # bytes - run: du -b yourfile.mp3
audio_type: "audio/mp3"
permalink: /podcast/daily/0037/
host:
  - jane-doe                   # optional - co-host(s)/guest-host(s), same slug rules as guests:
guests:
  - jane-doe                   # must match a filename slug in _people/
contributors:
  - jane-doe                   # optional - thanks/credits not covered by host or guests
thumbnail: "/assets/images/daily/ep37.png"   # optional - see below
thumbnail_alt: "Description of the image for accessibility."
---

Show notes in Markdown here.
```

**Episode thumbnails:**

If an episode has its own image (as opposed to the show's general
cover art), set `thumbnail` (a site-root-relative path) rather than
embedding the image in the Markdown body. This one field drives three
things:
- the episode page shows it as a featured image, above the player
- the episode card on the show index shows it (this already worked
  before `thumbnail` had a writer - `_layouts/show-cards.html` has
  looked for `episode.thumbnail` for a while)
- the RSS feed gets a per-episode `<itunes:image>`, which is the
  standard, widely-supported way podcast apps show episode-specific
  artwork - rather than an app inferring it from whatever image
  happens to appear in the show notes, which only works in apps that
  do that inference (and is that much more markup to hand-type and
  mistype)

`thumbnail_alt` is optional and falls back to the episode title.

**What happens automatically:**
- Episode appears on the show index page once its publish gate opens
- Episode appears in Latest Episodes on the home page if it's among the most recent (by `publish_date`) across all shows
- Episode is added to the show's RSS feed
- If host, guests, or contributors are listed, the episode appears on each credited person's profile page

**What you do manually:**
- Host the audio file and paste the URL
- Get the file size in bytes (`du -b yourfile.mp3`)
- Create a person file first if it's someone new

---

## Quoting a Poem in Show Notes

Use the `{% poem %}` tag rather than hand-typing `<blockquote>` markup.
It only needs plain text - blank lines split it into stanzas, single
line breaks become `<br>`s, and everything is HTML-escaped, so there's
no markup to mistype and nothing for a podcast app to mangle. It
renders as a centered title/byline plate framing a left-ruled body
where the verse itself lives - not a boxed callout:

```liquid
{% poem title="Poem Title" author="Author Name"
   source_title="Book or Collection Title" source_url="https://example.com/source" %}
First line of the first stanza
Second line of the first stanza

First line of the second stanza
Second line of the second stanza
{% endpoem %}
```

- `title` / `author` are optional - omit both to skip the header block.
- `source_title` / `source_url` are optional - omit both to skip the
  footer attribution, or give `source_title` alone for unlinked text.
- A stanza that's just one line starting with `## ` renders as a small
  bolded label (e.g. `## MORAL`) instead of a verse line - this
  matches Project Gutenberg's own convention for section headers, so
  text can usually be pasted in from a Gutenberg HTML edition with
  only light cleanup (stripping page markers, image tags, and `[Pg N]`
  markers).
- `*italic*` and `**bold**` work inline.

See `_podcast/daily/0036.md` for a full example, and
`_plugins/poem_tag.rb` for implementation notes.

---

## Adding a New Comic Strip

Create a Markdown file in `_comic/{comic-slug}/`:

```
_comic/wanderlines/0003.md
```

```yaml
---
comic: wanderlines
title: "Strip Title"
strip_number: 3
created: 2026-07-10T09:00:00
publish_date: 2026-07-10
status: scheduled
arc: "Optional arc/chapter name"
image: "/assets/images/comics/wanderlines/0003.png"
alt_text: "Description of the strip for accessibility."
permalink: /comics/wanderlines/0003/
artist:
  - jane-doe                   # optional - must match a filename slug in _people/
guests:
  - jane-doe                   # optional - for a guest-collab strip
contributors:
  - jane-doe                   # optional - thanks/credits
---

Optional caption/notes in Markdown, shown below the image.
```

---

## Adding a New Story Chapter

Create a Markdown file in `_story/{story-slug}/`:

```
_story/lighthouse-keepers/0003.md
```

```yaml
---
story: lighthouse-keepers
title: "Chapter Title"
chapter_number: 3
created: 2026-07-10T09:00:00
publish_date: 2026-07-10
status: scheduled
arc: "Optional book/arc name"
permalink: /story/lighthouse-keepers/0003/
author:
  - jane-doe                   # optional - must match a filename slug in _people/
contributors:
  - jane-doe                   # optional - thanks/credits
---

Chapter content in Markdown here.
```

---

## Adding a Person

Create a Markdown file in `_people/`:

```
_people/first-last.md
```

```yaml
---
layout: person
name: "First Last"
slug: first-last
title: "Their Title or Descriptor"
pronouns: "she/her"           # optional - shown next to the name
links:                        # optional - each entry is one platform: value
  - website: "https://theirsite.com"   # website expects a full URL
  - twitter: "theirhandle"             # everything else expects a bare handle...
  - github: "theirhandle"              # ...unless the value itself starts with
  - substack: "theirhandle"            # http, in which case it's used as-is
photo:                         # leave blank for silhouette placeholder
---

A short bio in Markdown.
```

Supported `links:` platforms: `website`, `twitter`, `facebook`, `instagram`, `github`, `substack`, `twitch`, `tiktok`. Each is rendered via the shared `_includes/person-links.html` include, which looks up the matching icon in `_includes/icon.html` and builds the profile URL from the handle (or uses the value directly if it's already a full URL - handy for a Substack on a custom domain, or any platform not in the list above). Order in the list is the order they're displayed in.

The `slug` must match exactly what you list under `host:`/`guests:`/`artist:`/`author:`/`contributors:` in installment or post front matter. Appearances populate automatically on the person's page.

**Credit fields, in general:**

`host`, `guests`, `artist`, `author`, and `contributors` all work the
same way wherever they're used - each is a list of person slugs, and
each is rendered by the shared `_includes/people-credit.html` include
(which fields apply depends on the content type: episodes get
`host`/`guests`, comics get `artist`/`guests`, stories and posts get
`author`, and `contributors` is available everywhere for a quick
thanks). A slug with no matching `_people/` file still displays as
plain text rather than breaking the build - useful for a one-off
mention you don't want to make a full profile for, though creating
the profile is what makes it a link and lets it show up on `/people/`.

**How people are displayed:**

`/people/` is a single flat grid, sorted alphabetically by name (no
weighting by role or activity yet - that can wait until there are
enough people for sort order to matter). Each card shows a small row
of role pills - Host, Guest, Artist, Author, Contributor - computed
per person by the `person-card.html` include, so a person with
several roles just gets several pills (e.g. a podcast guest who's
also drawn a comic shows both "Guest" and "Artist"). `author` on
stories and `author` on posts both collapse into the same "Author"
pill; there's no separate "story author" vs. "blog author" badge.

Each person's own page (`_layouts/person.html`) is still broken out
by collection + role - Hosting, Guest Appearances, Comics, Stories,
Blog Posts, and a merged Contributions section - since that's a
one-person view of everything they've done, not a many-people
directory, and the sections there aren't trying to solve a sort-order
problem.

**A note on `{% comment %}`:** Jekyll's Liquid still parses tags
inside `{% comment %}...{% endcomment %}` blocks, so a comment
containing example usage like `{% include foo.html %}` will try to
render that include and can break the build. Keep include/layout
usage notes here in the README instead of in-file comments; if an
in-file comment is truly needed, keep it plain text with no `{% %}`
or `{{ }}` inside it.

---

## Adding a Blog Post

Create a Markdown file in `_posts/`:

```
_posts/2026-07-10-post-slug.md
```

```yaml
---
title: "Post Title"
description: "One sentence shown on the blog listing and home page preview."
date: 2026-07-10
status: published
tags: [updates, behind-the-scenes]
author:
  - jane-doe                   # optional - must match a filename slug in _people/
contributors:
  - jane-doe                   # optional - thanks/credits
---

Post content in Markdown.
```

Note blog posts keep the real `date` field, unlike podcast/comic/story installments - Jekyll's `_posts` collection genuinely needs it for permalink generation, and posts aren't currently scheduled far in advance the way other content is.

---

## Adding a New Podcast Show

Create `_shows/{slug}.md`:

```yaml
---
name: "New Show"
slug: new-show
show: new-show
description: "What it's about."
subtitle: "Tagline"
author: "Vaguely Generic"
email: "podcast+new-show@vaguelygeneric.website"
language: "en-us"
category: "Society &amp; Culture"
subcategory: "Personal Journals"
explicit: "false"
status: draft                  # flip to published/remove when ready to launch
accent: "#hex"                 # optional - tints its hero pill and badge
cover_svg: "new-show-logo.svg" # optional, in _includes/
feed_image: "/assets/images/new-show-feed-logo.png"
spotify_url: "..."
# ...other platform subscribe links
---
```

That's it - the `/podcast/` listing, hero pills, RSS feed (`/feed/{slug}.xml`), and episode back-links all populate automatically from this one file. Add episode files to `_podcast/{slug}/` when ready.

By default, `_plugins/generate_feeds.rb` auto-generates that show's feed page dynamically. Once a show is stable and you'd rather hand-author the feed file directly, create `feed/{slug}.xml` yourself:

```yaml
---
layout: feed
show: daily
permalink: /feed/daily.xml
---
```

The generator checks for an existing page at that permalink first and skips auto-generating one if it finds it - so a manually-created feed file simply takes over, no config change needed. `daily` already works this way; every other show is still auto-generated.

## Adding a New Webcomic or Story

Same pattern: add `_comics/{slug}.md` or `_stories/{slug}.md` with `name`, `slug`, `description`, and optionally `status`/`accent`. Add installment files to `_comic/{slug}/` or `_story/{slug}/`. No RSS feed is generated for these types currently.

**Reference example:** `_comics/wanderlines.md` and `_stories/lighthouse-keepers.md`, both `status: draft`, are intentionally left in the repo as worked examples of the full pattern (property file, installments, arcs, images). They're excluded from feeds/listings by their draft status but not from the build - don't be surprised to find them if you go looking.

---

## RSS Feeds

Podcast shows each get their own feed, generated (or hand-authored - see above) from the `_podcast/{slug}/` collection filtered by `show:` and the publish gate.

Feed URL pattern: `https://vaguelygeneric.website/feed/{slug}.xml`

Feeds are compatible with Apple Podcasts, Spotify (via RSS import), Pocket Casts, Overcast, and all standard podcast apps.

**Submitting to platforms:**

| Platform | URL |
|----------|-----|
| Apple Podcasts | https://podcastsconnect.apple.com |
| Spotify | https://podcasters.spotify.com |
| Amazon Music | https://podcasters.amazon.com |
| iHeart | https://www.iheart.com/content/submit-your-podcast |

Webcomics and stories don't currently have RSS feeds - everything about them lives on the site itself.

---

## Configuration Reference

Key fields in `_config.yml`:

| Field | Purpose |
|-------|---------|
| `url` | Full site URL - used in RSS feeds and SEO tags |
| `baseurl` | Leave blank for apex domain; use `/repo-name` for project sites |
| `timezone` | `UTC` - anchors the publish gate and RSS `pubDate` |
| `youtube_channel` | YouTube channel URL - used in nav and home page |
| `collections` | Registers `shows`/`podcast`, `comics`/`comic`, `stories`/`story`, `posts`, `people` |

Show/comic/story metadata itself lives in the collections (`_shows/*.md`, etc.), not in `_config.yml`.

---

## Cover Art Requirements

Apple Podcasts requires square artwork between 1400×1400 and 3000×3000 px, PNG or JPG, under 512KB where possible. One image per show, referenced in its `_shows/{slug}.md` file under `feed_image`.

---

## Theme & Colors

CSS variables are defined at the top of `assets/css/main.css` under `:root` (light mode) and `[data-theme="dark"]`. The accent color, background, surface, border, and text colors are all tokenized - change the variables to retheme the entire site.

Individual shows/comics/stories can override their own accent color via the `accent:` field in their property file, which tints their hero pill and badge without touching the CSS.

Font stack: **Syne** (headings/UI) + **Lora** (body), both loaded from Google Fonts in `_layouts/default.html`.
