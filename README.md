# AI Agents for Coding: A Practical Workshop

**From Zero to Productive with AI-Assisted Development**

Welcome! This repository contains everything you need for the **2-hour hands-on AI Agents for Coding workshop**. Whether you're new to AI coding assistants or exploring advanced patterns, this workshop has something for you.

---

## What's in This Repo?

| File / Folder | Description |
|---|---|
| **[WORKSHOP-GUIDE.md](WORKSHOP-GUIDE.md)** | 🎯 Main guide to follow during the 120-minute workshop session |
| **[DAY-AGENDA.md](DAY-AGENDA.md)** | ⏱️ Timeline and section breakdown for the workshop |
| **[PARTICIPANT-CHECKLIST-MESSAGE.md](PARTICIPANT-CHECKLIST-MESSAGE.md)** | ✅ Pre-workshop setup (takes ~10 minutes) |
| **[exercise-agents-md-template.md](exercise-agents-md-template.md)** | 📝 Template for the hands-on AGENTS.md exercise |
| **[sample-project/](sample-project/)** | 🚀 TaskAPI sample project with 6 progressive exercises |

---

## Getting Started

### 1. Fork This Repo
Click the **Fork** button at the top right of GitHub. This gives you your own copy to work with.

### 2. Complete the Pre-Workshop Checklist
Read **[PARTICIPANT-CHECKLIST-MESSAGE.md](PARTICIPANT-CHECKLIST-MESSAGE.md)** and verify you have:
- ✅ VS Code installed (latest stable)
- ✅ GitHub Copilot extensions installed and activated
- ✅ GitHub account set up and signed into VS Code
- ✅ Copilot license verified on GitHub.com

Takes about 10 minutes. If you get stuck, come 10 minutes early to the workshop!

### 3. Follow the Workshop Guide
During the workshop, follow **[WORKSHOP-GUIDE.md](WORKSHOP-GUIDE.md)** step-by-step. It covers:
- The AI coding landscape and tools
- Prompt engineering for better results
- Writing custom AGENTS.md instructions
- Terminal-based agents and advanced patterns

---

## Sample Project: TaskAPI

### What Is It?
**TaskAPI** is a minimal REST API for managing tasks. It's intentionally imperfect — great for practicing AI-assisted coding.

### Quick Start
```bash
# 1. Install dependencies
pip install -r sample-project/requirements.txt

# 2. Run the server
python sample-project/app.py

# 3. Test it (in another terminal)
curl http://localhost:5000/health
```

> **💡 pip not found?** Many modern Macs don't ship with `pip`. You can use [uv](https://docs.astral.sh/uv/) instead — it's fast and easy to install:
> ```bash
> # Install uv (one-time)
> curl -LsSf https://astral.sh/uv/install.sh | sh
> # Or: brew install uv
>
> # Then use it in place of pip
> uv pip install -r sample-project/requirements.txt
> ```

### The Exercises
The sample project contains 6 progressive exercises:

1. **AGENTS.md Exercise** — Write custom AI agent instructions for the TaskAPI project
2. **Input Validation** — Use AI to add validation to the POST endpoints
3. **Error Handling** — Improve error messages and status codes
4. **Test Coverage** — Expand the test suite with more test cases
5. **Environment Variables** — Move hardcoded config values to `.env`
6. **Logging** — Add logging to track API calls and errors

Each exercise has TODOs in the code marking where improvements are needed.

---

## Workshop Overview

### Duration
**2 hours** — Designed to fit a typical workshop slot with time for hands-on practice.

### What You'll Learn
- ✅ How to write effective prompts for AI coding assistants
- ✅ How to define custom instructions using AGENTS.md
- ✅ Hands-on practice creating and testing your first AGENTS.md
- ✅ Patterns for reusable skills and extensions
- ✅ How to use AI agents beyond the IDE — in the terminal and automation

### Who Should Attend?
- 👨‍💻 Developers of all levels (beginners welcome!)
- 🤖 Anyone curious about AI-assisted development
- 🛠️ Teams looking to adopt AI tools into their workflow

### What to Bring
- 💻 Your laptop (macOS, Windows, or Linux)
- ⚡ A charged battery
- 🧠 Your curiosity and questions!

---

## Key Files Overview

### WORKSHOP-GUIDE.md
The main presenter's guide with:
- Pre-workshop checklist and troubleshooting
- Detailed agenda with timing for each section
- Presentation notes and discussion points
- Hands-on exercise instructions
- Q&A and next steps

### DAY-AGENDA.md
A quick reference timeline showing:
- Each section's duration and mode (presentation vs. hands-on)
- What you'll learn in each section
- Practical logistics and what to bring

### PARTICIPANT-CHECKLIST-MESSAGE.md
A friendly setup checklist to make sure everyone is ready before the workshop. Covers:
- VS Code installation
- Copilot extensions
- Account sign-in verification
- Quick troubleshooting tips

### exercise-agents-md-template.md
A template you'll fill in during the workshop to create your first AGENTS.md file. Includes sections for:
- Project overview and tech stack
- Coding conventions
- Architecture and design decisions
- Security requirements
- Testing and validation guidelines
- Common tasks and "Do NOT" boundaries

---

## Sample Project Structure

```
sample-project/
├── app.py              # Flask REST API (intentionally has gaps)
├── models.py           # Task data model
├── database.py         # In-memory database
├── config.py           # Configuration (hardcoded — fix this!)
├── tests_app.py        # Pytest tests (incomplete)
├── requirements.txt    # Python dependencies
├── Dockerfile          # Container definition
├── .env.example        # Example environment variables
├── README.md           # Project README
├── AGENTS.md           # Your first exercise! (empty template)
└── FILES-MANIFEST.txt  # File listing and exercise guide
```

---

## Running the Sample Project

### Install Dependencies
```bash
cd sample-project
pip install -r requirements.txt
# Or with uv: uv pip install -r requirements.txt
```

### Start the API Server
```bash
python app.py
```

The server runs at `http://localhost:5000`.

### Test the API
```bash
# Health check
curl http://localhost:5000/health

# Create a task
curl -X POST http://localhost:5000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Buy milk", "description": "2% milk", "due_date": "2024-12-25"}'

# Get all tasks
curl http://localhost:5000/tasks
```

### Run the Tests
```bash
pytest sample-project/tests_app.py -v
```

---

## Additional Utility: Progress OpenEdge Cobrand Import

This repository also includes a standalone Progress OpenEdge procedure,
`import-cobrand-koder.p`, for importing `cobrand` codes into the `koder` table
from an Excel-exported CSV.

- Expected source data: column C contains the cobrand code to import
- Accepted code format: integer values, including optional leading `+` or `-`
- Supported delimiters: `,` and `;` (auto-detected per line)
- Header handling: the first row is treated as header/non-data and skipped
  when column C is not an integer
- Example invocation:

```abl
RUN import-cobrand-koder.p (INPUT "C:\temp\cobrands.csv").
```

If the input parameter is blank, the procedure falls back to `SESSION:PARAMETER`
and then to `sample-cobrand-koder.csv` in the repository root. A small sample
file is included for manual testing.

---

## Why This Project?

TaskAPI is **intentionally imperfect**. It has:
- ❌ Missing input validation
- ❌ Incomplete error handling
- ❌ Hardcoded configuration
- ❌ Incomplete test coverage
- ❌ No logging

This is **by design**. You'll practice asking AI to fix these issues — great preparation for real-world work!

---

## License

MIT — Feel free to use, modify, and share.

---

## Questions?

Before the workshop:
- Check the [Troubleshooting](WORKSHOP-GUIDE.md#troubleshooting) section in WORKSHOP-GUIDE.md
- Ask the organizers if you get stuck on setup

During the workshop:
- No question is too basic — we're all learning together! 🚀

After the workshop:
- Keep practicing with the sample project
- Apply what you learned to your own projects
- Share your AGENTS.md with your team

---

**Ready to get started? Fork this repo, complete the checklist, and see you at the workshop!**
