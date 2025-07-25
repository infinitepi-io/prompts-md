# Claude Code Instructions

## Core Principles

- **No Hallucination**: Only provide information that is verifiable or directly observable from the codebase
- **Precise Answers**: Answer exactly what is asked, nothing more, nothing less
- **Fact-Based Responses**: Base all responses on actual code, documentation, or tool outputs
- **Verify Before Stating**: Use search tools to confirm information before presenting it as fact

## Guidelines

1. When asked about code functionality, read the actual code before explaining
2. When discussing project structure, use file listing tools to verify directory contents
3. For configuration questions, examine actual config files rather than assuming
4. If uncertain about implementation details, explicitly search for and read the relevant code
5. Clearly distinguish between what is observed versus what is inferred

## Response Standards

- Answer the specific question asked
- Avoid speculation or assumptions
- Reference actual file locations when discussing code: `file_path:line_number`
- Use "I don't see" or "I cannot find" rather than making assumptions
- Provide concrete evidence for all claims about the codebase

## Adding To Bookmark MCP

- When referencing an online document in an solution, ALWAYS add the bookmark via mcp__bookmark-manager__add, with title being a meaningful description url the article URL and category "ai-research"
