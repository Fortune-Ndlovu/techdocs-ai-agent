import json
import os
from llm_client import LLMClient
from prompt_builder import build_prompt_for_file
from doc_writer import save_doc
from jinja2 import Template

# Root path = the "agent" folder where templates are located
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

TEMPLATE_PATHS = {
    "mkdocs.yaml": os.path.join(ROOT_DIR, "templates/mkdocs.yaml.tpl"),
    "catalog-info.yaml": os.path.join(ROOT_DIR, "templates/catalog-info.yaml.tpl"),
    "index.md": os.path.join(ROOT_DIR, "templates/index.md.tpl"),
}

def render_template(template_path, variables):
    with open(template_path, "r") as f:
        content = f.read()
    template = Template(content)
    return template.render(**variables)

def generate_all_docs(repo_summary_path, repo_dir):
    client = LLMClient()

    with open(repo_summary_path, "r") as f:
        repo_summary = json.load(f)

    repo_name = repo_summary.get("repo_name", "unknown-repo")
    docs_dir = os.path.join(repo_dir, "docs")
    os.makedirs(docs_dir, exist_ok=True)

    # Ensure mkdocs.yaml
    mkdocs_path = os.path.join(repo_dir, "mkdocs.yaml")
    if not os.path.exists(mkdocs_path):
        print("📄 Creating mkdocs.yaml from template...")
        mkdocs_content = render_template(TEMPLATE_PATHS["mkdocs.yaml"], {"repo_name": repo_name})
        with open(mkdocs_path, "w") as f:
            f.write(mkdocs_content)

    # Ensure catalog-info.yaml
    catalog_path = os.path.join(repo_dir, "catalog-info.yaml")
    if not os.path.exists(catalog_path):
        print("📄 Creating catalog-info.yaml from template...")
        catalog_content = render_template(TEMPLATE_PATHS["catalog-info.yaml"], {"repo_name": repo_name})
        with open(catalog_path, "w") as f:
            f.write(catalog_content)

    # Generate docs/index.md using LLM
    print(f"✍️ Generating index.md using LLM...")
    prompt = build_prompt_for_file(repo_summary)
    generated_content = client.generate(prompt, max_tokens=2000)
    save_doc(docs_dir, "index.md", generated_content)

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: python generate_full_docs.py /path/to/repo-summary.json /path/to/repo")
        sys.exit(1)

    generate_all_docs(sys.argv[1], sys.argv[2])
