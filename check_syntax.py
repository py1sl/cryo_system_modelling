#!/usr/bin/env python3
"""
Simple syntax checker for Modelica files
Checks for basic structure and common issues
"""

import os
import re
from pathlib import Path

def check_modelica_file(filepath):
    """Check a single Modelica file for basic syntax issues"""
    errors = []
    warnings = []
    
    with open(filepath, 'r') as f:
        content = f.read()
        lines = content.split('\n')
    
    # Check for basic structure
    if not re.search(r'\b(model|package|class)\b', content):
        errors.append("No model, package, or class definition found")
    
    # Check for matching end statement
    starts = len(re.findall(r'\b(model|package|class|function|block)\s+\w+', content))
    ends = len(re.findall(r'\bend\s+\w+;', content))
    
    if starts != ends:
        warnings.append(f"Mismatched definitions: {starts} starts, {ends} ends")
    
    # Check for equation/algorithm sections
    has_vars = bool(re.search(r'\b(Real|Integer|Boolean)\s+\w+', content))
    has_equations = bool(re.search(r'\bequation\b', content))
    has_algorithm = bool(re.search(r'\balgorithm\b', content))
    
    if has_vars and not (has_equations or has_algorithm):
        warnings.append("Variables declared but no equation or algorithm section")
    
    # Check for unclosed parentheses/brackets
    open_parens = content.count('(')
    close_parens = content.count(')')
    if open_parens != close_parens:
        errors.append(f"Unmatched parentheses: {open_parens} open, {close_parens} close")
    
    # Check for semicolons after key statements
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith('//') or not stripped:
            continue
        
        # Check equation statements without semicolons
        if re.search(r'\bequation\b', stripped):
            continue
        if '=' in stripped and not stripped.endswith((';', 'then', 'else', ')')):
            if not re.search(r'(if|for|when|while)', stripped):
                warnings.append(f"Line {i}: Possible missing semicolon")
    
    return errors, warnings

def main():
    """Main function to check all Modelica files"""
    print("=" * 70)
    print("Modelica Syntax Checker")
    print("=" * 70)
    
    cryosystem_path = Path(__file__).parent / 'CryoSystem'
    
    if not cryosystem_path.exists():
        print(f"ERROR: CryoSystem directory not found at {cryosystem_path}")
        return 1
    
    total_files = 0
    total_errors = 0
    total_warnings = 0
    
    for mo_file in cryosystem_path.rglob('*.mo'):
        total_files += 1
        print(f"\nChecking: {mo_file.relative_to(cryosystem_path.parent)}")
        
        errors, warnings = check_modelica_file(mo_file)
        
        if errors:
            total_errors += len(errors)
            print(f"  ❌ ERRORS ({len(errors)}):")
            for error in errors:
                print(f"     - {error}")
        
        if warnings:
            total_warnings += len(warnings)
            print(f"  ⚠️  WARNINGS ({len(warnings)}):")
            for warning in warnings:
                print(f"     - {warning}")
        
        if not errors and not warnings:
            print("  ✅ OK")
    
    print("\n" + "=" * 70)
    print(f"Summary: {total_files} files checked")
    print(f"  Errors: {total_errors}")
    print(f"  Warnings: {total_warnings}")
    print("=" * 70)
    
    if total_errors > 0:
        print("\n⚠️  Please fix errors before running in OpenModelica")
        return 1
    elif total_warnings > 0:
        print("\n⚠️  Warnings found - review before running")
        return 0
    else:
        print("\n✅ All files passed basic syntax checks!")
        print("   Ready to load in OpenModelica")
        return 0

if __name__ == '__main__':
    exit(main())
