from crewai import Task
from agents.order_files_agent import OrderFilesAgent

order_files_task = Task(
  description="""Order the files in the project directory based on their importance and relevance.""",
  expected_output="Ordered list of files based on importance and relevance.",
  agent=OrderFilesAgent
)
