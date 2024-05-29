from crewai import Task
from agents.analyse_files_agent import AnalyseFilesAgent

analyse_files_task = Task(
  description="""Analyse the content of specific files in the project to extract key information and insights.
  Files should be analysed one at a time ot prevent hitting LLM limits""",
  expected_output="""For each file, you should output the name and a brief explanation of any functions or similar constructs in the file.
                  Check for any dependencies that may be present, including references to elements in other files in the project.
                  Include a summary of the file as a whole.""",
  agent=AnalyseFilesAgent
)
