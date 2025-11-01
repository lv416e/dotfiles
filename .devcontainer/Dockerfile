# syntax=docker/dockerfile:1

# Force x86_64/amd64 architecture for Homebrew bottles support
# ARM64 Linux is Tier 2 (no bottles, must build from source - very slow)
FROM --platform=linux/amd64 mcr.microsoft.com/devcontainers/base:ubuntu

# Set architecture labels for verification
LABEL architecture="amd64"
LABEL homebrew.bottles.supported="true"
