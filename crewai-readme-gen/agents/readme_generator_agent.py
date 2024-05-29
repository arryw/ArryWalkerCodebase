import os
from crewai import Agent
from dotenv import load_dotenv
from langchain_anthropic import ChatAnthropic
from tools.search import search
from tools.write_readme import write_readme

load_dotenv()

ClaudeHaiku = ChatAnthropic(
  model="claude-3-haiku-20240307"
)
ClaudeSonnet = ChatAnthropic(
  model="claude-3-sonnet-20240229"
)

ReadMeGeneratorAgent = Agent(
  role='ReadMe Generator',
  goal='Generate a README file based on the project files and analysis.',
  backstory="""You are a README generation expert, capable of compiling detailed and informative README files.
    Your task is to create a comprehensive README file based on the project files and analysis provided by the other agents.
    You should structure the README in a clear and concise manner, highlighting key aspects of the project.
    You should highlight any unusual or complex aspects of the project that may require further explanation.
    Your output should be a README file with detailed project information.
    To use the write_readme tool, call it with `write_readme(content)` where `content` is the README content you want to write.""",
  verbose=True,
  allow_delegation=True,
  llm=ClaudeHaiku,
  max_iter=5,
  memory=True,
  tools=[search, write_readme]
)
