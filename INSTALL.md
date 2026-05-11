# Installing procurement-skills

These skills work across three Claude surfaces, but each surface stores
skills differently and they do NOT sync between surfaces. Pick the path
that matches where you use Claude most.

## Quick decision

| Where you use Claude | Install path | Time |
|---|---|---|
| Claude.ai web (Pro/Max/Team/Enterprise) | [Path A](#path-a--claudeai-web--claude-desktop--mobile--cowork) | ~5 min |
| Claude Desktop | [Path A](#path-a--claudeai-web--claude-desktop--mobile--cowork) (same as web) | ~5 min |
| Claude mobile | [Path A](#path-a--claudeai-web--claude-desktop--mobile--cowork) (same as web) | ~5 min |
| Cowork | [Path A](#path-a--claudeai-web--claude-desktop--mobile--cowork) (same as web) | ~5 min |
| Claude Code (terminal) | [Path B](#path-b--claude-code) | ~2 min |
| Claude API workspace | [Path C](#path-c--claude-api) | ~10 min |

**Important**: skills uploaded to Claude.ai are NOT visible in Claude
Code, and vice versa. If you use both, you need to install in both
places. The skills themselves are identical; the storage is what
differs.

---

## Path A — Claude.ai web / Claude Desktop / mobile / Cowork

These four surfaces share the same backend skills library, tied to
your Anthropic account. Upload once, available everywhere you log in.

### Step 1 — Get the zips

You need 5 individual zip files, one per skill. Two ways:

**If you have the repo cloned locally:**
```
cd procurement-skills
./install.sh --package
```
This produces 5 zips in `dist/`: `redline-sentry.zip`, `spend-prism.zip`,
`bid-compass.zip`, `supplier-truthcheck.zip`, `procure-voice.zip`.

**If you don't want to clone the repo:**
Download the latest release zip from the GitHub Releases page. Unzip it.
Then for each of the 5 skill folders, manually zip the folder itself
(right-click → Compress on Mac, or Send to → Compressed folder on
Windows). The result must be a zip that, when extracted, contains a
single folder named after the skill (e.g. `redline-sentry/SKILL.md`).

### Step 2 — Upload to Claude.ai

1. Open [claude.ai](https://claude.ai) in your browser
2. Click your profile icon (bottom-left or top-right depending on
   layout) and choose **Settings**
3. Find the **Capabilities** section (may be called **Features** on
   some plans)
4. Locate **Skills** → click **Upload skill** (or the equivalent
   upload button)
5. Select one of the zip files from `dist/`
6. Wait for the validation step to confirm the skill name and
   description
7. Repeat for the other 4 zips

### Step 3 — Verify

Open a new chat in Claude.ai. Type `/` — you should see the five
procurement skills appear in the slash menu alongside any other custom
skills you have:

- /redline-sentry
- /spend-prism
- /bid-compass
- /supplier-truthcheck
- /procure-voice

When you invoke one (e.g. `/redline-sentry`), the first response in
the conversation will start with a visible activation tag like:

> 🛡️ **redline-sentry** activated — running contract review.

This confirms the skill fired.

### Plan requirements

Custom skill upload requires **Claude.ai Pro, Max, Team, or Enterprise**,
with code execution enabled. The Free tier does not support custom skill
upload as of this writing.

---

## Path B — Claude Code

Claude Code reads skills from your local filesystem, not your Anthropic
account. Faster install but local-machine-only — skills don't follow
you to other devices.

### Option 1: One-command install (recommended)

```
git clone https://github.com/YOUR_USERNAME/procurement-skills.git
cd procurement-skills
./install.sh
```

The script copies all 5 skills into `~/.claude/skills/` and reports
what was installed. Use `--force` to overwrite existing installs, or
`--skip-existing` to leave them alone.

### Option 2: Manual

Copy each of the 5 skill folders (`redline-sentry/`, `spend-prism/`,
etc.) into `~/.claude/skills/` directly.

### Verify

Start a new Claude Code session. Type `/` — the procurement skills
appear in the menu. They also auto-trigger from natural language
matching the skill descriptions.

---

## Path C — Claude API

Skills uploaded via the API are workspace-wide (all members of your
API workspace see them). They are NOT visible in Claude.ai web or
Claude Code; the API is its own separate skills surface.

See the [Anthropic Skills API documentation](https://docs.claude.com)
for current upload endpoints. The skill folder structure in this repo
is compatible with the API upload format.

---

## Customising for your organisation

Every skill has a `config.yaml` file you can edit:

| Skill | What to edit in config.yaml |
|---|---|
| `redline-sentry/config.yaml` | Liability cap thresholds, jurisdiction, contract-type playbooks |
| `spend-prism/config.yaml` | Your category taxonomy (UNSPSC, eClass, or custom), currency, anomaly thresholds |
| `bid-compass/config.yaml` | Scoring weights per category, quality gates, RFP structure |
| `supplier-truthcheck/config.yaml` | Which checks to run, fuzzy match thresholds, rate limits |
| `procure-voice` | No config — rules are the skill |

**Important for Path A users**: after editing a `config.yaml`, you must
**re-zip the skill folder and re-upload**. Claude.ai stores a snapshot
of the skill at upload time; subsequent edits to your local files don't
sync automatically. Path B (Claude Code) users see edits immediately
since the skill is read from disk every session.

---

## Troubleshooting

**"Skill name must be lowercase letters, numbers, and hyphens"**
The frontmatter `name:` field in SKILL.md must match this format. All
five skills in this repo already comply.

**"Skill upload failed: invalid structure"**
Make sure you're uploading a zip where the top-level entry is the
skill folder, not loose files. The folder must contain SKILL.md at
its root. Verify with: `unzip -l skill-name.zip` — the first entry
should be `skill-name/`, not `SKILL.md`.

**"I uploaded but the skill doesn't appear in the slash menu"**
Refresh the page or start a new chat. Claude.ai's skill cache updates
on session start. If still missing, check Settings > Capabilities to
confirm it's listed.

**"I see the skill but it doesn't fire from natural language"**
Skills auto-trigger when the description matches your prompt. If
auto-trigger fails, invoke explicitly via slash command. You can
also tweak the description in SKILL.md, re-zip, and re-upload.

**"Updates from GitHub don't show in my Claude.ai"**
Correct — they won't. Re-download or re-package the latest version
and re-upload. Path A doesn't auto-sync. Path B does (next session
after `git pull`).
