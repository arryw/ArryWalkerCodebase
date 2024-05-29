import pathspec
from pathlib import Path


def load_ignore_patterns(path, filename):
  ignore_file = Path(path) / filename
  if ignore_file.exists():
    with open(ignore_file, 'r') as file:
      spec = pathspec.PathSpec.from_lines('gitwildmatch', file)
  else:
    spec = None
  return spec


def list_directory_contents(path_input, gitignore_dir_input, ignore_dir_input):
  """ List files in directory while respecting .gitignore and .ignore files. """
  path_input = Path(path_input)
  gitignore_spec = load_ignore_patterns(gitignore_dir_input, '.gitignore')
  ignore_spec = load_ignore_patterns(ignore_dir_input, '.ignore')

  all_files = list(path_input.rglob('*'))
  filtered_files = []

  for file in all_files:
    # Convert file path to relative path from path_input for matching
    relative_path = file.relative_to(path_input)
    # Check each spec to see if the file should be ignored
    if gitignore_spec and gitignore_spec.match_file(str(relative_path)):
      continue
    if ignore_spec and ignore_spec.match_file(str(relative_path)):
      continue
    filtered_files.append(file)

  return filtered_files
