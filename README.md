# Code::Blocks Patcher for DreamSDK

[Code::Blocks](http://www.codeblocks.org/) is a free, open-source cross-platform IDE that supports multiple compilers, including the `Sega Dreamcast` through [DreamSDK](https://www.dreamsdk.org/).

This program is responsible of the conversion from a standard [Code::Blocks](http://www.codeblocks.org/) installation into **Code::Blocks for DreamSDK**, directly on the user's computer. Both Code::Blocks 17.12 and 20.03 releases are supported.

## Introduction

The goal of this repository is to build the **Code::Blocks Patcher for DreamSDK** (`codeblocks-patcher.exe`) file.
This patcher will be embedded in **DreamSDK Setup**.

## Prerequisites

You need to build **Code::Blocks 17.12** (x86 only) and **Code::Blocks 20.03** (both x86/x64) before building this project.

## Building Code::Blocks Patcher for DreamSDK

After building the **Code::Blocks** binary packages, follow these steps:

1. If needed, update the Code::Blocks packages directly in `.\src\engine\embedded\packages`.
2. Build the `.\cbpatcher\src\splash\codeblocks-splash.lpi` in **Release** mode from **Lazarus**, then pack the `.\cbpatcher\src\engine\embedded\codeblocks-splash.exe` file with **UPX**.
3. Build the `.\cbpatcher\src\codeblocks-patcher.lpi` in **Release** mode from **Lazarus**.
4. Done!

