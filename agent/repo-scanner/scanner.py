import os
import json
from pathlib import Path
from rich import print

# Basic extension to language mapping
EXTENSION_MAP = {
    '.py': 'Python',
    '.js': 'JavaScript',
    '.ts': 'TypeScript',
    '.java': 'Java',
    '.go': 'Go',
    '.sh': 'Shell',
    '.yaml': 'YAML',
    '.yml': 'YAML',
    '.md': 'Markdown',
    '.Dockerfile': 'Dockerfile',
    '.rb': 'Ruby',
    '.html': 'HTML',
    '.css': 'CSS',
}

IMPORTANT_FILES = ["README.md", "Dockerfile", "docker-compose.yml"]

def classify_file(file_path):
    ext = Path(file_path).suffix
    return EXTENSION_MAP.get(ext, "Other")

def scan_repo(repo_path):
    repo_summary = {
        "repo_name": Path(repo_path).name,
        "languages_detected": set(),
        "key_files": {},
        "folder_structure": [],
        "config_files": [],
        "test_files": [],
        "docs_files": []
    }

    for root, dirs, files in os.walk(repo_path):
        # Save folder structure
        for d in dirs:
            folder_rel = os.path.relpath(os.path.join(root, d), repo_path)
            repo_summary["folder_structure"].append(folder_rel)

        for file in files:
            file_rel = os.path.relpath(os.path.join(root, file), repo_path)

            # Classify by extension
            lang = classify_file(file)
            if lang != "Other":
                repo_summary["languages_detected"].add(lang)

            # Important files extraction
            if os.path.basename(file) in IMPORTANT_FILES:
                try:
                    with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                        content = f.read(5000)  # only read first 5000 chars max
                        repo_summary["key_files"][file_rel] = content
                except Exception as e:
                    print(f"[red]Error reading {file}: {e}[/red]")

            # Special folders
            if file_rel.startswith('tests/'):
                repo_summary["test_files"].append(file_rel)
            if file_rel.startswith('docs/'):
                repo_summary["docs_files"].append(file_rel)
            if file.endswith(('.yaml', '.yml')) or 'docker' in file.lower():
                repo_summary["config_files"].append(file_rel)

    repo_summary["languages_detected"] = list(repo_summary["languages_detected"])
    return repo_summary

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("[bold red]Usage:[/bold red] python scanner.py /path/to/repo")
        sys.exit(1)

    repo_path = sys.argv[1]
    result = scan_repo(repo_path)
    print(json.dumps(result, indent=2))
