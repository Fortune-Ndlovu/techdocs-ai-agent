## Overview

This project provides an **AI-powered agent** that **automates** the process of onboarding GitHub repositories into [Red Hat Developer Hub (RHDH)](https://developers.redhat.com/products/rhdh/overview).

The agent:
- Clones any GitHub repository
- Deeply scans the repo to understand its purpose and structure
- Generates TechDocs-ready documentation:
  - `catalog-info.yaml`
  - `mkdocs.yaml`
  - `docs/index.md`
- Opens a Pull Request (PR) automatically back to the repository
- (Optional) Registers the project directly into a running Red Hat Developer Hub instance

This saves hours of manual work and ensures a consistent, scalable documentation strategy across many repositories.

## ✨ Key Features

- 🧠 AI-generated `docs/index.md` based on real extracted repo content (not hallucinated)
- 📄 Auto-create `catalog-info.yaml` and `mkdocs.yaml` using Jinja templates
- 🤖 GitHub PR automation using GitHub CLI
- 🔗 Optional Developer Hub component registration after PR merge
- ⚡ Modular architecture (scanner, LLM client, PR creator, runner)
- 🛠️ Built from scratch for full transparency and customization

## 📂 Project Structure

```plaintext
agent/
├── llm-client/
│   ├── doc_writer.py
│   ├── generate_full_docs.py
│   ├── llm_client.py
│   └── prompt_builder.py
├── repo-scanner/
│   ├── scanner.py
│   └── requirements.txt
├── templates/
│   ├── catalog-info.yaml.tpl
│   ├── mkdocs.yaml.tpl
│   └── index.md.tpl (optional fallback)
├── commit_and_pr.sh
register_component.sh (optional)
runner.sh
README.md
```

## 🚀 How It Works

1. Provide the GitHub repository URL.
2. `runner.sh` clones the repo locally.
3. `scanner.py` analyzes the project and outputs a `repo-summary.json`.
4. `generate_full_docs.py` uses the summary to create TechDocs files.
5. `commit_and_pr.sh` stages the files, commits, and opens a pull request.
6. (Optional) `register_component.sh` waits for PR merge and registers the project into Developer Hub.

## 🛠️ Prerequisites

- **Python 3.8+**
- **Bash**
- **GitHub CLI (`gh`)** installed and authenticated
- **jq** (for parsing JSON)
- Access to an **OpenAI API key** or compatible LLM provider
- (Optional) Access token for Red Hat Developer Hub instance

## 🔥 Quick Start

1. **Install Python dependencies** (inside `repo-scanner/`):

   ```bash
   pip install -r agent/repo-scanner/requirements.txt
   ```

2. **Authenticate GitHub CLI**:

   ```bash
   gh auth login
   ```

3. **Run the agent**:

   ```bash
   bash runner.sh https://github.com/your-org/your-repo
   ```

4. **Merge the Pull Request** once created.

5. **(Optional)** Register the component into Developer Hub manually or automatically after merge.

## ⚙️ Configuration

In `register_component.sh`, configure:

- `DEVHUB_URL`: Your Developer Hub instance URL (e.g., `https://developer-hub.apps.cluster.example.com`)
- `RHDH_TOKEN`: Service Account or OIDC token with permissions to register components

## 📈 Example Output

After a successful run:

- Pull Request created with:
  - `catalog-info.yaml`
  - `mkdocs.yaml`
  - `docs/index.md`
- Documentation ready to be served in Red Hat Developer Hub.
- Component registered in the internal software catalog.

## 🤔 Why Build This Agent?

- **Scale**: Onboard hundreds of repositories effortlessly
- **Consistency**: Enforce consistent documentation patterns
- **Speed**: Reduce manual work dramatically
- **Intelligence**: Leverage real project content, not empty templates
- **Extensibility**: Add GitLab, Bitbucket support easily in future phases

## 🔮 Future Enhancements

- Full Dockerization for OpenShift Pipelines or GitHub Actions
- Support for GitLab and Bitbucket repositories
- Dynamic owner assignment in `catalog-info.yaml`
- Smart duplicate detection (avoid onboarding repos twice)
- Slack or email notification after successful onboarding

## 📄 License

This project is provided under the [MIT License](LICENSE).

## 🙌 Contributions

Contributions, feedback, and improvements are welcome!  
Feel free to open Issues or Pull Requests.
