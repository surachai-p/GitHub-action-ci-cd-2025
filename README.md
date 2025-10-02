 # Flask CI/CD Demo

Demo project สำหรับ Lab 00 - Docker Compose และ GitHub Actions

## Requirements

- Docker Desktop
- Git

## Quick Start

1. Clone repository:
\`\`\`bash
git clone <your-repo-url>
cd my-flask-app
\`\`\`

2. Setup environment:
\`\`\`bash
cp .env.example .env
# แก้ไขค่าใน .env
\`\`\`

3. Start services:
\`\`\`bash
docker compose up -d
\`\`\`

4. Test API:
\`\`\`bash
curl http://localhost:5000/
curl http://localhost:5000/health
\`\`\`

## Project Structure

\`\`\`
my-flask-app/
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   └── tests/
│       └── test_app.py
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── docker-compose.yml
├── Dockerfile
├── .env.example
├── .gitignore
└── README.md
\`\`\`
