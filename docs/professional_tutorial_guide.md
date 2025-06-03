# Professional Killercoda Tutorial Structure Guide

This guide outlines best practices for creating professional, effective, and easy-to-follow Killercoda tutorials, particularly for technical product integrations like Keeper Secrets Manager (KSM).

## I. `index.json` - The Scenario Blueprint

The `index.json` file defines the overall structure and behavior of your Killercoda scenario.

**Key Fields & Best Practices:**

*   **`title`**: A clear, concise title for the tutorial (e.g., "KSM Integration: GitLab CI/CD").
*   **`description`**: A brief (1-2 sentences) overview of what the tutorial covers and its main benefit.
*   **`details.steps`**: An array defining each step of the tutorial.
    *   **`title`**: A short, descriptive title for each step (e.g., "Step 1: Configure KSM Application").
    *   **`text`**: The Markdown file for the step's content (e.g., "step1.md").
    *   **`script` (optional)**: A shell script to run automatically when the step loads (e.g., "install-prereqs.sh"). Useful for step-specific setup.
*   **`details.intro`**:
    *   **`text`**: "intro.md" - Always include a dedicated introduction.
    *   **`courseData` (optional)**: A shell script to run once at the very beginning of the scenario (e.g., "install-powershell-ubuntu.sh"). Ideal for global environment setup.
*   **`details.finish`**:
    *   **`text`**: "finish.md" - Always include a dedicated conclusion/summary.
*   **`environment`**:
    *   **`hideintro`**: Set to `false` to display the `intro.md`.
    *   **`hidefinish`**: Set to `false` to display the `finish.md`.
    *   **`uilayout`**: Choose an appropriate layout.
        *   `terminal`: For primarily command-line focused tutorials.
        *   `editor-terminal`: When users need to view/edit files and use the terminal.
        *   `ide`: For more complex scenarios involving a file tree editor.
*   **`backend.imageid`**: Specify the base OS image (e.g., "ubuntu", "centos").

## II. `intro.md` - Setting the Stage

The introduction is crucial for setting user expectations and preparing them for the tutorial.

**Content Sections:**

1.  **Welcome Message**: Brief and welcoming.
2.  **"About [Technology/Integration]"**: What is it? What problem does it solve?
3.  **"Key Features/Benefits"**: Bullet points highlighting advantages.
4.  **"What You'll Learn"**: Clear, actionable learning objectives (e.g., "You will learn how to...").
5.  **"Prerequisites"**: A list of what the user needs before starting (e.g., accounts, software, prior knowledge).
6.  **"Environment Setup" (Killercoda Specific)**: Explain how the Killercoda environment is prepared (e.g., "PowerShell will be installed for you. Wait for completion and type `pwsh` if not automatically in the prompt.").
7.  **Call to Action**: e.g., "Let's get started!"

## III. Step Files (`stepN.md`) - Guided Learning

Each step should guide the user through a specific part of the process.

**Structure & Best Practices:**

*   **Clear Title**: `### Step N: Descriptive Title of the Step`.
*   **Introduction**: Briefly explain the goal of this specific step.
*   **Numbered/Bulleted Sub-sections**: Break down the step into logical actions (e.g., "1. Install Module", "2. Register Vault").
*   **Killercoda Directives**:
    *   `{{execute}}`: For commands the user should run.
    *   `{{copy}}`: For commands or code blocks the user should copy.
*   **Clear Instructions**:
    *   Explain *why* a command is being run, not just *what* to run.
    *   Use **bolding** for emphasis on commands, filenames, UI elements.
    *   Use `backticks` for inline code, commands, and file paths.
*   **Placeholders**:
    *   Use clear placeholders like `[YOUR_ONE_TIME_TOKEN]`, `KEEPER_RECORD_UID`, `your-repo-name`.
    *   Explicitly instruct the user to replace these placeholders with their actual values.
*   **Example Outputs**: Include example console output where it helps the user verify their actions. Use Markdown code blocks.
*   **Images**:
    *   Store in an `assets` subfolder within the scenario directory.
    *   Reference using relative paths: `![](./assets/your-image.png)`.
    *   Ensure images are clear, cropped appropriately, and add value.
*   **Security Notes & Best Practices**: Include these where relevant (e.g., protecting CI/CD variables, principle of least privilege for KSM app permissions - view or edit, not share).

## IV. `finish.md` - Wrapping Up

The finish screen should summarize and provide next steps.

**Content Sections:**

1.  **Congratulations Message**: e.g., "Congratulations! You've successfully...".
2.  **Recap of Learned Skills**: Use checkmarks (✅) for a quick summary of accomplishments.
3.  **"Next Steps & Further Learning"**:
    *   Suggest related activities or more advanced topics.
    *   Link to official product documentation.
    *   Link to relevant API references or community resources.
4.  **Thank You Note**.

## V. Asset Management

*   **`assets` Folder**: Create an `assets` subfolder within each scenario's directory for images, configuration snippets, or other supporting files.
*   **Naming**: Use clear, descriptive names for assets (e.g., `gitlab-ci-variable-setup.png`).

## VI. Scripts (`.sh`, `.ps1`)

Scripts used for `courseData` or `script` directives.

*   **Shebang**: Start shell scripts with `#!/bin/bash` (or appropriate interpreter).
*   **Echo Progress**: Use `echo` statements to inform the user what the script is doing, especially for longer operations. This is crucial in Killercoda as it provides feedback in the terminal.
*   **Error Handling**: Basic error checking can be helpful (`set -e` in bash).
*   **Killercoda Background Scripts**: If a script is meant to complete before a step is fully "ready" (often used in `courseData` or as a `setup.sh` equivalent), end it with `echo "done" >> /opt/.backgroundfinished` to signal Killercoda.
*   **Command Structure**: For `courseData` or step `script` directives, especially for setup, prefer chaining commands into one-liners (e.g., using `&&`) where feasible. Killercoda can occasionally be sensitive to complex multi-line command sequences in these scripts.
*   **Permissions**: Ensure scripts are executable (`chmod +x yourscript.sh`).

## VII. General Style & Tone

*   **Consistency**: Maintain consistent formatting, terminology, and command presentation.
*   **Clarity and Conciseness**: Get straight to the point. Avoid jargon where possible, or explain it.
*   **Action-Oriented**: Use imperative verbs for instructions (e.g., "Run the command...", "Create a file...").
*   **User-Centric**: Anticipate user questions or potential points of confusion.

By following these guidelines, you can create high-quality Killercoda tutorials that provide a great learning experience. 