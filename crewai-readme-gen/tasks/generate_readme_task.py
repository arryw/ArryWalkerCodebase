from crewai import Task
from agents.readme_generator_agent import ReadMeGeneratorAgent

generate_readme_task = Task(
  description="""Generate a README file based on the project files and analysis.""",
  expected_output="README file with detailed project information.",
  agent=ReadMeGeneratorAgent,
  output_file='README.md'
)
