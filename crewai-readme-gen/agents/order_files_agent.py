import os
from crewai import Agent
from dotenv import load_dotenv
from langchain_anthropic import ChatAnthropic
from tools.list_files import list_files

load_dotenv()

ClaudeHaiku = ChatAnthropic(
  model="claude-3-haiku-20240307"
)
ClaudeSonnet = ChatAnthropic(
  model="claude-3-sonnet-20240229"
)

ANTHROPIC_API_KEY = os.environ.get('ANTHROPIC_API_KEY')

OrderFilesAgent = Agent(
  role='File Prioritise Agent',
  goal='Order files based on importance and relevance.',
  backstory="""You are a file prioritisation expert with a keen eye for detail.
    Your task is to order the files in the project directory based on their importance and relevance.
    You should rely solely on the `list_files` tool to list the project files out, based on their name and file type, you should recognise the type of project and order them accordingly.
    Your output should be in the same format as the input list, including all files and their paths, if that was what was passed to you.
    Pass this information on to the `AnalyseFilesAgent` for further analysis.""",
  verbose=True,
  allow_delegation=True,
  llm=ClaudeHaiku,
  max_iter=5,
  memory=True,
  tools=[list_files]
)
