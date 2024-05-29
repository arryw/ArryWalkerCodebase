import json
from crewai_tools import tool


@tool('list_files')
def list_files():
  """Load a list of file paths from a JSON file."""
  try:
    with open('all_files.json', 'r') as f:
      files = json.load(f)
    return files
  except FileNotFoundError:
    print("Error: 'all_files.json' file not found.")
    return []  # Return an empty list if the file is not found
  except json.JSONDecodeError:
    print("Error: JSON decoding failed. Check the format of 'all_files.json'.")
    return []  # Return an empty list if there is a decoding error