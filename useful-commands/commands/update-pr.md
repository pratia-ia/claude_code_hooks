---
description: Update the existing pull request in Azure DevOps
---

# Update Pull Request

Update the existing pull request to main branch in Azure DevOps for the Mesa de Ayuda project.

## Instructions

You are tasked with updating the existing pull request for the current branch to main in Azure DevOps. Follow these steps:

1. **Verify Git Status**

   - Check current branch name
   - Verify there are no uncommitted changes (if there are, commit them first with an appropriate message)
   - Ensure the branch is pushed to origin

2. **Analyze Changes**

   - Run `git log origin/main..HEAD --oneline` to see commits since main
   - Run `git diff --stat origin/main...HEAD` to see file changes
   - Analyze the commits and changes to understand what was worked on

3. **Extract Work Items**

   - Look for work item references in commit messages (e.g., #123, #456)
   - Search commit messages for keywords like "fix", "feat", "refactor", "docs", etc.

4. **Update PR Description**
   Based on the commits and changes, update the detailed PR description following this template:

   ```
   ## Summary
   - [Brief bullet points of main changes]

   ## Cambios principales

   ### [Category] (#work-item-id if applicable)
   - **File1**: Description of changes
   - **File2**: Description of changes
   - Key functionality added/modified

   ### [Another Category]
   - Details...

   ## Archivos modificados
   - X archivos modificados
   - +Y líneas agregadas
   - -Z líneas eliminadas

   ## Test plan
   - [ ] Test item 1
   - [ ] Test item 2
   - [ ] Test item 3

   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   ```

5. **Create Pull Request**

   - Repository ID: `f418af6f-1fc2-4c57-b203-eab2685ec6ce`
   - Source: Current branch (refs/heads/[branch-name])
   - Target: `refs/heads/main`
   - Title: Generate a concise title based on the main change (e.g., "feat: Add feature X", "fix: Resolve issue Y")
   - Description: Use the generated description from step 4
   - Work Items: Include any work item IDs found in commits (space-separated)

6. **Output Result**
   - Show the PR number and URL
   - Provide a summary of what was included

## Important Notes

- The repository name is `mesa_ayuda_back` in the project `Demo Mesa de Ayuda`
- Always link work items if references are found in commits
- Generate Spanish descriptions since the project is in Spanish
- Be thorough in analyzing changes to create an accurate description
- If there are uncommitted changes, ask user if they want to commit them first
- If the PR description already has images, retain them in the updated description
