import json
from pathlib import Path
from crewai import Crew
from agents.order_files_agent import OrderFilesAgent
from agents.analyse_files_agent import AnalyseFilesAgent
from agents.readme_generator_agent import ReadMeGeneratorAgent
from tasks.order_files_task import order_files_task
from tasks.analyse_files_task import analyse_files_task
from tasks.generate_readme_task import generate_readme_task
from utils.file_utils import list_directory_contents, load_ignore_patterns

readme_crew = Crew(
  agents=[OrderFilesAgent, AnalyseFilesAgent, ReadMeGeneratorAgent],
  tasks=[order_files_task, analyse_files_task, generate_readme_task],
  verbose=2
)

def main():
  # Load or initialize configuration
  config_path = Path('./config.json')
  if config_path.exists():
    with open(config_path, 'r') as file:
      config = json.load(file)
    last_path = config.get('last_path', '')
    last_gitignore_dir = config.get('last_gitignore_dir', '')
    last_ignore_dir = config.get('last_ignore_dir', '')
  else:
    last_path, last_gitignore_dir, last_ignore_dir = '', '', ''
    config = {}

  # Get user inputs
  path_input = input(f'Enter directory path [{last_path}]: ') or last_path
  gitignore_dir_input = input(f'Enter directory containing .gitignore [{last_gitignore_dir}]: ') or last_gitignore_dir
  ignore_dir_input = input(f'Enter directory containing .ignore [{last_ignore_dir}]: ') or last_ignore_dir

  # Save the used paths to config.json
  config.update({
    'last_path': path_input,
    'last_gitignore_dir': gitignore_dir_input,
    'last_ignore_dir': ignore_dir_input
  })
  with open(config_path, 'w') as file:
    json.dump(config, file, indent=4)

  # List the directory contents
  files = list_directory_contents(path_input, gitignore_dir_input, ignore_dir_input)
  if files:
    print("Files listed:", len(files))

    # Write the list of filtered files to a JSON file for inspection
    with open('all_files.json', 'w') as f:
      json.dump([str(file) for file in files], f, indent=4)

    # Pass the list to the order_files_crew and kick off its process
    result = readme_crew.kickoff()

    print("Generated README Content:", result)
  else:
    print("No files found or operation cancelled.")


if __name__ == '__main__':
  main()
