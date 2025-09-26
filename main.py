import argparse
import os
import sys
import asyncio
from pathlib import Path
from mmengine import DictAction

root = str(Path(__file__).resolve().parents[0])
sys.path.append(root)

from src.logger import logger
from src.config import config
from src.models import model_manager
from src.agent import create_agent

def parse_args():
    parser = argparse.ArgumentParser(description='main')
    parser.add_argument("--config", default=os.path.join(root, "configs", "config_custom.py"), help="config file path")

    parser.add_argument(
        '--cfg-options',
        nargs='+',
        action=DictAction,
        help='override some settings in the used config, the key-value pair '
        'in xxx=yyy format will be merged into config file. If the value to '
        'be overwritten is a list, it should be like key="[a,b]" or key=a,b '
        'It also allows nested list/tuple values, e.g. key="[(a,b),(c,d)]" '
        'Note that the quotation marks are necessary and that no white space '
        'is allowed.')
    args = parser.parse_args()
    return args


async def main():
    # Parse command line arguments
    args = parse_args()

    # Initialize the configuration
    config.init_config(args.config, args)

    # Initialize the logger
    logger.init_logger(log_path=config.log_path)
    logger.info(f"| Logger initialized at: {config.log_path}")
    logger.info(f"| Config:\n{config.pretty_text}")

    # Registed models
    model_manager.init_models(use_local_proxy=config.use_local_proxy)
    logger.info("| Registed models: %s", ", ".join(model_manager.registed_models.keys()))

    # Create agent
    agent = await create_agent(config)
    logger.visualize_agent_tree(agent)

    # Interactive mode
    print("\n" + "="*60)
    print("DeepResearchAgent - Hierarchical Agent Interactive Mode")
    print("="*60)
    print("Available agents: deep_analyzer_agent, browser_use_agent, deep_researcher_agent")
    print("Enter your task (or 'quit' to exit):")

    while True:
        task = input("\n> ").strip()

        if task.lower() in ['quit', 'exit', 'q']:
            print("Goodbye!")
            break

        if not task:
            print("Please enter a task.")
            continue

        try:
            print(f"\nProcessing task: {task}")
            print("-" * 50)
            res = await agent.run(task)
            print("-" * 50)
            print(f"Final Result: {res}")
            logger.info(f"| Result: {res}")
        except Exception as e:
            print(f"Error processing task: {e}")
            logger.error(f"Error processing task: {e}")

        print("\nEnter your next task (or 'quit' to exit):")

if __name__ == '__main__':
    asyncio.run(main())