#!/bin/bash

# Œcie¿ka do projektu
PROJECT_PATH="fpga/build/vga_project.xpr"

# Uruchomienie Vivado w trybie GUI i otwarcie projektu
vivado -mode gui -source "$PROJECT_PATH"
