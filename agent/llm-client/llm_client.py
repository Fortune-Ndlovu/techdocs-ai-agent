## Loads Granite model and generates completions
from transformers import AutoModelForCausalLM, AutoTokenizer, pipeline
import os

class LLMClient:
    def __init__(self, model_id="instructlab/granite-7b-lab"):
        print(f"🔵 Loading model: {model_id}...")

        # Read token from environment
        token = os.getenv("HUGGINGFACE_TOKEN")
        if token is None:
            raise RuntimeError("Missing HUGGINGFACE_TOKEN environment variable.")

        self.tokenizer = AutoTokenizer.from_pretrained(
            model_id,
            token=token,
            trust_remote_code=True
        )
        self.model = AutoModelForCausalLM.from_pretrained(
            model_id,
            device_map="auto",
            trust_remote_code=True,
            token=token
        )
        self.pipe = pipeline("text-generation", model=self.model, tokenizer=self.tokenizer, device_map="auto")

    def generate(self, prompt, max_tokens=100):
        print("⚡ Generating content from LLM...")
        response = self.pipe(
            prompt,
            max_new_tokens=max_tokens,
            do_sample=True,
            temperature=0.7,
            top_p=0.9
        )
        generated_text = response[0]["generated_text"]
        return generated_text

if __name__ == "__main__":
    client = LLMClient()
    test_prompt = "Write a getting-started guide for a Kubernetes deployment project."
    output = client.generate(test_prompt)
    print("\n[📝 OUTPUT]\n")
    print(output)
