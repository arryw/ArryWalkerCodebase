import json
from crewai_tools import tool
from pathlib import Path

@tool('write_readme')
def write_readme(content):
    """Write the README content to a file in the output directory."""
    try:
        # Load the base path from the config file
        with open('config.json', 'r') as config_file:
            config = json.load(config_file)
        base_path = config.get('last_path', '')

        # Define the output directory and create it if it doesn't exist
        output_dir = Path("./output")
        output_dir.mkdir(parents=True, exist_ok=True)

        # Construct the README file path
        readme_path = output_dir / "README.md"

        # Write the README content to the file in the output directory
        with open(readme_path, 'w', encoding='utf-8') as file:
            file.write(content)

        return f"README file written to {readme_path}"
    except FileNotFoundError:
        print("Error: 'config.json' not found.")
        return "Error writing README file."
    except json.JSONDecodeError:
        print("Error: JSON decoding failed. Check the format of 'config.json'.")
        return "Error writing README file."
    except Exception as e:
        print(f"Error writing README file: {e}")
        return "Error writing README file."
