from rich.console import Console
from rich.syntax import Syntax
import yaml
import sys

def print_yaml_file(file_path):
    console = Console()
    
    # Read the YAML file
    with open(file_path, 'r') as file:
        # Load YAML to ensure it's valid
        yaml_content = yaml.safe_load(file)
        # Dump back to string with proper formatting
        formatted_yaml = yaml.dump(yaml_content, default_flow_style=False)
    
    # Create syntax object with YAML highlighting
    syntax = Syntax(formatted_yaml, "yaml", theme="monokai", line_numbers=True)
    
    # Print header
    console.print(f"\n[bold blue]📄 Configuration File:[/bold blue] [yellow]{file_path}[/yellow]\n")
    
    # Print the formatted YAML
    console.print(syntax)
    console.print("\n")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python print_config.py <yaml_file>")
        sys.exit(1)
    
    print_yaml_file(sys.argv[1])