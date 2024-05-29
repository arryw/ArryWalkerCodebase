import os
from crewai import Agent
from dotenv import load_dotenv
from langchain_anthropic import ChatAnthropic
from tools.analyse_files import analyse_files

load_dotenv()

ClaudeHaiku = ChatAnthropic(
  model="claude-3-haiku-20240307"
)
ClaudeSonnet = ChatAnthropic(
  model="claude-3-sonnet-20240229"
)

ANTHROPIC_API_KEY = os.environ.get('ANTHROPIC_API_KEY')

AnalyseFilesAgent = Agent(
  role='File Analysis Specialist',
  goal='Analyse the content of specific files in the project.',
  backstory="""A specialist in file analysis, adept at extracting key insights from code and documentation.
    Your role is to provide valuable information from the project files for the README compilation.
    Only use the search function if you need to look up additional information.
    You should be particularly interested in and dependencies between files and any complex data manipulation that requires explanation.
    Your output should be a summary of key information extracted from the project files.
    You should look at one file at a time, commit the output of the `analyse_files_task` to memory before moving on to the next file.
    To use the analyse_files tool, you should call it with `analyse_files(file_name)` where `file_name` is the name of the file you want to analyse.
    Once collated, pass this information on to the `ReadMeGeneratorAgent` for README generation.""",
  verbose=True,
  allow_delegation=True,
  llm=ClaudeHaiku,
  memory=True,
  tools=[analyse_files]
)
