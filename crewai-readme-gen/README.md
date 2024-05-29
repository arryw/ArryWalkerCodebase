# CrewAI Agentic AI Crew

A collection of agents designed to work together seamlessly, enabling you to analyse and generate insights from specific files in your project.

## How to run

Set the `ANTHROPIC_API_KEY` environment variable to your Anthropic API key. This is required for the ChatAnthropic agent to function correctly.

```bash
export ANTHROPIC_API_KEY=your_api_key
```

Create a virtual environment and install the required dependencies.

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Call the main.py file to run the agents and tasks.

```bash
python main.py
```

## Additional Tips

Always run agents and tasks in a virtual environment to prevent any potential conflicts or dependencies.
Be mindful of the LLM limits when analysing large files or collections of files. Consider breaking down your analysis into smaller, more manageable chunks if necessary.
Keep an eye on the output files and adjust your analysis as needed.

## Crew Members

This crew consists of three agents:

OrderFilesAgent: Organizes files in a suitable format for analysis.
AnalyseFilesAgent: Extracts key information and insights from each file.
ReadMeGeneratorAgent: Generates a comprehensive README file summarizing the analyzed files.

## Tasks

order_files_task: Orders files for analysis.
analyse_files_task: Analyzes files to extract key information and insights.
generate_readme_task: Generates a README file summarizing the analyzed files.