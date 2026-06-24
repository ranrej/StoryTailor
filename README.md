# 📚 StoryTailor — AI-Powered Children's Story Generator

<div align="center">

**An AI-powered storytelling application that generates personalized children's stories, illustrations, and educational content through an intuitive web and desktop experience.**

[![Figma](https://img.shields.io/badge/Figma-Design-F24E1E?style=for-the-badge\&logo=figma\&logoColor=white)](https://www.figma.com/design/uqYux438V7jFzF0mvO3jb2/MiniMe?node-id=0-1&t=AQE98oJGVegdFh2F-1)
[![Research Paper](https://img.shields.io/badge/Research-Paper-red?style=for-the-badge\&logo=adobeacrobatreader\&logoColor=white)](docs/StoryTailor_Thesis.pdf)
[![Defence Slides](https://img.shields.io/badge/Defence-Slides-orange?style=for-the-badge\&logo=microsoftpowerpoint\&logoColor=white)](docs/StoryTailor_Defence_Slides.pdf)
[![YouTube Demo](https://img.shields.io/badge/YouTube-Demo-FF0000?style=for-the-badge\&logo=youtube\&logoColor=white)](https://youtu.be/i7ZC9KNvEoU)
[![Google Cloud](https://img.shields.io/badge/Google_Cloud-Live_App-4285F4?style=for-the-badge\&logo=googlecloud\&logoColor=white)](https://storygenaiv2-157136237046.europe-west1.run.app)

</div>

<br>

<div align="center">
  <img src="assets/storytailor-demo.gif" alt="StoryTailor Demo" width="800">
</div>

---

## About The Project

Creating engaging and personalized stories for children can be time-consuming for parents, educators, and content creators.

**StoryTailor** simplifies this process by leveraging AI to generate custom children's stories based on user preferences, themes, characters, and learning objectives. The platform combines advanced language models with AI-generated illustrations to create unique storytelling experiences in seconds.

Designed for accessibility and ease of use, StoryTailor is available both as a web application and as a standalone macOS desktop application.

---

## Key Features

### ✨ AI Story Generation

Generate personalized children's stories with:

* Custom characters
* Unique story themes
* Adjustable age groups
* Educational storytelling elements

### 🎨 AI Illustration Generation

Create story-specific illustrations using Google Gemini image generation.

### 📖 Interactive Story Experience

* Beautiful reading interface
* Structured story chapters
* Dynamic content generation
* Child-friendly presentation

### ⚙️ Flexible Deployment

Access StoryTailor through:

* Hosted web application
* Standalone macOS desktop application
* Local development environment

### 🔑 Secure API Key Management

Supports multiple credential storage methods:

* In-app settings
* Environment variables
* `.env` files
* macOS Keychain

---

## Live Demo

### 🌐 Web Application

Launch StoryTailor instantly:

**https://storygenaiv2-157136237046.europe-west1.run.app**

No installation required.

### 💻 Desktop Application

A standalone macOS application is available for users who prefer a desktop experience.

---

## Screenshots

| Home Page            | Story Generator           | Story Reader           |
| -------------------- | ------------------------- | ---------------------- |
| ![](assets/home.png) | ![](assets/generator.png) | ![](assets/reader.png) |

---

## Built With

### AI & APIs

* OpenAI API
* Google Gemini API

### Backend

* Python
* Flask

### Frontend

* HTML
* CSS
* JavaScript

### Deployment

* Google Cloud Run

### Desktop Packaging

* PyInstaller

---

## Installation

### Prerequisites

* Python 3.11+
* OpenAI API Key
* Google API Key (optional)

### Clone the Repository

```bash
git clone YOUR_REPOSITORY_URL
cd StoryTailor
```

### Install Dependencies

Using pip:

```bash
python3 -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt
```

Using uv:

```bash
uv sync
```

---

## Configuration

StoryTailor requires API credentials to access AI-powered story and image generation services.

### Required API Keys

| Key              | Purpose                                | Where to Get It                                            |
| ---------------- | -------------------------------------- | ---------------------------------------------------------- |
| `OPENAI_API_KEY` | Story generation (required)            | [OpenAI API Keys](https://platform.openai.com/api-keys)    |
| `GOOGLE_API_KEY` | Image generation via Gemini (optional) | [Google AI Studio](https://aistudio.google.com/app/apikey) |

### Option 1 — .env File

Create a `.env` file in the project root:

```bash
OPENAI_API_KEY="sk-..."
GOOGLE_API_KEY="AIza..."
```

### Option 2 — macOS Keychain

```bash
python -m keyring set storygenai OPENAI_API_KEY

python -m keyring set storygenai GOOGLE_API_KEY
```

### Option 3 — Environment Variables

```bash
export OPENAI_API_KEY="sk-..."
export GOOGLE_API_KEY="AIza..."
```

---

## Running Locally

Using pip:

```bash
source .venv/bin/activate
python main.py
```

Using uv:

```bash
uv run storygenai
```

Open:

```text
http://127.0.0.1:8080
```

To specify a custom port:

```bash
PORT=9000 python main.py
```

---

## Desktop Application

Build a standalone macOS application:

```bash
bash build_app.sh
```

The generated application will be located at:

```text
dist/StoryTailor.app
```

Users can launch the application without installing Python or additional dependencies.

---

## Research Paper

This project was accompanied by a formal research and design paper documenting the problem space, system architecture, AI integration approach, implementation details, and evaluation of the StoryTailor platform.

📄 **Download the Thesis Paper**

[StoryTailor Thesis Paper](docs/StoryTailor_Thesis.pdf)

### Topics Covered

* Problem Definition
* System Architecture
* AI Story Generation Pipeline
* Prompt Engineering Strategy
* Image Generation Workflow
* Security & API Management
* Evaluation & Results
* Future Research Directions

---

## Defence Presentation

This presentation was used during the formal project defence and summarizes the motivation, architecture, implementation details, research findings, and future work for StoryTailor.

📊 **Download the Defence Slides**

[StoryTailor Defence Presentation](docs/StoryTailor_Defence_Slides.pdf)

### Presentation Highlights

* Project Motivation
* System Architecture
* AI Pipeline Overview
* Technical Challenges
* Evaluation Results
* Future Enhancements

---

## Demo Video

Watch a complete walkthrough of StoryTailor, including story generation, image creation, configuration, and deployment features.

🎥 **YouTube Demonstration**

[Watch the Demo Video](https://youtu.be/i7ZC9KNvEoU)

---

## Design

🎨 **Figma Prototype**

[View the Figma Project](https://www.figma.com/design/uqYux438V7jFzF0mvO3jb2/MiniMe?node-id=0-1&t=AQE98oJGVegdFh2F-1)

---

## Repository Structure

```text
StoryGenAIv2/
├── app/
│   ├── evals/
│   ├── evaluation/
│   ├── prompt/
│   ├── static/
│   ├── templates/
│   ├── db.py
│   ├── routes.py
│   └── image_assets.py
├── database/
│   ├── images/
│   ├── sessions/
│   ├── stories/
│   └── tables/
├── results/
├── scripts/
├── src/
│   └── storygenai/
├── main.py
├── requirements.txt
├── pyproject.toml
├── package.json
└── README.md
```

---

## Future Improvements

* Story voice narration
* Multi-language story generation
* Storybook PDF exports
* Character memory across stories
* Parent and educator dashboards
* Story sharing and collaboration
* Mobile application support

---

## License

This project was developed for educational and research purposes.
