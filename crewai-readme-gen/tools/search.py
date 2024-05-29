from crewai_tools import tool
from langchain_community.tools import DuckDuckGoSearchRun

@tool('DuckDuckGoSearch')
def search(search_query: str):
  """Search the web for information on a given topic"""
  return DuckDuckGoSearchRun().run(search_query)