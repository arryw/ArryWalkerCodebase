import json
import time
from crewai_tools import tool, FileReadTool
from pathlib import Path


@tool('analyse_files')
def analyse_files(file_name):
  """Analyse a single file in the project by fetching the base path from config and appending it to the filename."""
  try:
    # Load the base path from the config file
    with open('config.json', 'r') as config_file:
      config = json.load(config_file)
    base_path = config.get('last_path', '')

    # Construct the full path to the file
    full_path = Path(base_path) / file_name

    # Introduce a delay to manage rate limits
    time.sleep(8)

    # Perform the file analysis
    file_tool = FileReadTool(file_path=str(full_path))
    content = file_tool.run()
    return {file_name: content}
  except FileNotFoundError:
    print(f"Error: 'config.json' not found or '{file_name}' does not exist.")
    return {file_name: None}
  except json.JSONDecodeError:
    print("Error: JSON decoding failed. Check the format of 'config.json'.")
    return {file_name: None}
  except Exception as e:
    print(f"Error analysing file {full_path}: {e}")
    return {file_name: None}
