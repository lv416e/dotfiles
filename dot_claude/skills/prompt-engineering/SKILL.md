---
name: prompt-engineering
description: "Use when designing, testing, or deploying LLM prompts for applications - systematic prompt design methodology (pattern selection, structured output, evaluation, versioning) ensuring every prompt is tested against ground truth before production | LLMプロンプトの設計、テスト、デプロイ時に使用 - 体系的なプロンプト設計手法（パターン選択、構造化出力、評価、バージョン管理）により、すべてのプロンプトが本番前にグランドトゥルースに対してテスト済みであることを保証"
---

# Prompt Engineering

## Overview

Untested prompts in production are bugs you haven't found yet. Vibes-based prompt tuning is not engineering.

**Core principle:** EVERY prompt is versioned, tested, and evaluated against ground truth before deployment.

**Violating the letter of this process is violating the spirit of LLM engineering.**

## The Iron Law

```
EVERY PROMPT IS VERSIONED, TESTED, AND EVALUATED AGAINST GROUND TRUTH
```

If you haven't evaluated it on a test set, it's not ready for production. "It looked good in the playground" is not evaluation.

## When to Use

Use for ANY LLM integration work:
- Designing new prompts for applications
- Modifying existing prompts
- Building RAG pipelines
- Implementing tool use / function calling
- Optimizing token cost or latency
- Migrating between models
- Evaluating model outputs

**Use this ESPECIALLY when:**
- Prompt "works most of the time"
- You're tuning prompts by hand in a playground
- Someone says "just tweak the prompt a bit"
- Deploying prompt changes without evaluation
- Switching models and assuming prompts transfer

**Don't skip when:**
- The prompt is "simple" (simple prompts fail on edge cases)
- You're "just fixing a typo" (typos change model behavior)
- It's an internal tool (internal users deserve quality too)

## The Five Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Prompt Design

**BEFORE writing ANY prompt:**

1. **Define the Task Precisely**
   - What exactly should the model do?
   - What are valid outputs?
   - What are invalid outputs?
   - What edge cases exist?
   - Write these down. They become your evaluation criteria.

2. **Select the Right Pattern**

   | Pattern | When to Use | Example |
   |---------|------------|---------|
   | **Zero-shot** | Simple, well-defined tasks | Classification, extraction |
   | **Few-shot** | Task needs examples to clarify format/behavior | Structured data extraction, style matching |
   | **Chain-of-thought** | Reasoning, analysis, multi-step logic | Math, code review, complex classification |
   | **System/User/Assistant roles** | Conversational applications | Chatbots, assistants |
   | **Tool use** | Model needs to take actions or access data | API calls, database queries, calculations |

3. **Structure the Prompt**

   <Good>
   ```xml
   <system>
   You are a code review assistant. Analyze code for bugs, security issues,
   and style violations.

   Rules:
   - Report only confirmed issues, not style preferences
   - Include file path and line number for each issue
   - Classify severity as: critical, warning, info
   </system>

   <user>
   Review this code:

   <code>
   {{code_content}}
   </code>

   <context>
   Language: {{language}}
   Framework: {{framework}}
   </context>
   </user>
   ```
   Clear structure, explicit rules, variable injection points
   </Good>

   <Bad>
   ```
   Review this code and tell me if there are any problems: {{code}}
   ```
   Vague instruction, no structure, no output format, no constraints
   </Bad>

4. **Design Output Format**
   - Specify exactly what the output should look like
   - Use JSON mode or tool use for structured output
   - Include examples of expected output in the prompt
   - Constrain the model: what it MUST include, what it MUST NOT include

### Phase 2: Anthropic-Specific Best Practices

**When using Claude models:**

1. **XML Tags for Structure**
   ```xml
   <document>
   {{document_content}}
   </document>

   <instructions>
   Summarize the document above in 3 bullet points.
   Focus on actionable insights only.
   </instructions>
   ```
   - XML tags reduce ambiguity between instructions and content
   - Use them to separate input data from instructions
   - Use them to delineate sections of complex prompts

2. **Prefilling for Format Control**
   ```
   Assistant: {"analysis": [
   ```
   - Start the assistant response to lock in format
   - Prevents preamble ("Sure, I'd be happy to...")
   - Forces specific output structure

3. **Prompt Caching**
   - Place stable content (system prompt, reference docs) first
   - Place variable content (user input) last
   - Use cache breakpoints for long static contexts
   - Measure cost savings: cached tokens are significantly cheaper

4. **Extended Thinking**
   - Enable for complex reasoning tasks
   - Budget thinking tokens appropriately
   - Don't enable for simple extraction/classification (waste of tokens)

### Phase 3: RAG Design Patterns

**When building retrieval-augmented generation:**

1. **Retrieval Quality First**
   - Bad retrieval = bad generation, regardless of prompt quality
   - Test retrieval independently before testing generation
   - Measure retrieval recall: are relevant documents being found?

2. **Context Window Management**
   ```xml
   <retrieved_documents>
   <document index="1" source="{{source_1}}" relevance_score="{{score_1}}">
   {{content_1}}
   </document>
   <document index="2" source="{{source_2}}" relevance_score="{{score_2}}">
   {{content_2}}
   </document>
   </retrieved_documents>

   <instructions>
   Answer the user's question using ONLY the documents above.
   If the answer is not in the documents, say "I don't have enough information."
   Cite document numbers for each claim.
   </instructions>
   ```

3. **Grounding and Attribution**
   - Require citations to source documents
   - Instruct the model to say "I don't know" when information is missing
   - Test for hallucination: ask questions NOT in the context
   - Verify the model doesn't fabricate sources

4. **Chunking Strategy**
   - Chunk size affects retrieval quality
   - Too small: loses context
   - Too large: dilutes relevance
   - Test different chunk sizes and measure retrieval recall

### Phase 4: Testing and Evaluation

**BEFORE deploying ANY prompt:**

1. **Build an Evaluation Dataset**
   - Minimum 20-50 examples for basic evaluation
   - Cover happy paths AND edge cases
   - Include adversarial inputs
   - Include ground truth (expected outputs)
   - Version your eval dataset alongside your prompts

2. **Define Metrics**

   | Task Type | Metrics |
   |-----------|---------|
   | **Classification** | Accuracy, precision, recall, F1 |
   | **Extraction** | Exact match, partial match, field-level accuracy |
   | **Generation** | LLM-as-judge, human eval, ROUGE/BLEU (limited) |
   | **RAG** | Faithfulness, relevance, citation accuracy |

3. **Run Evaluations Systematically**
   ```python
   # Every prompt change triggers evaluation
   results = evaluate(
       prompt=prompt_v2,
       dataset=eval_dataset,
       metrics=[accuracy, faithfulness, latency],
   )

   # Compare against previous version
   assert results.accuracy >= baseline.accuracy - REGRESSION_THRESHOLD
   assert results.faithfulness >= 0.95
   ```

4. **Test for Failure Modes**
   - Prompt injection attempts
   - Extremely long inputs
   - Empty or malformed inputs
   - Inputs in unexpected languages
   - Adversarial edge cases designed to break the prompt

5. **LLM-as-Judge for Generation Quality**
   - Use a separate LLM call to evaluate output quality
   - Define rubrics: what makes a good vs. bad output
   - Calibrate judge against human evaluations
   - Don't use the same model to judge itself when possible

### Phase 5: Versioning and Operations

**Every prompt in production follows these rules:**

1. **Version Control**
   ```
   prompts/
   ├── code-review/
   │   ├── v1.0.0.txt        # Initial version
   │   ├── v1.1.0.txt        # Added severity classification
   │   ├── v2.0.0.txt        # Restructured for tool use
   │   ├── eval_dataset.jsonl # Test cases
   │   └── CHANGELOG.md      # What changed and why
   ```
   - Semantic versioning: major.minor.patch
   - Major: behavior change. Minor: improvement. Patch: typo/formatting.
   - Every version has evaluation results recorded

2. **A/B Testing**
   - Route traffic between prompt versions
   - Measure real-world performance
   - Statistical significance before declaring winner
   - Don't declare "better" from 10 examples

3. **Cost Optimization**
   - Measure tokens per request (input and output)
   - Choose the right model for the task (don't use the largest model for simple classification)
   - Use prompt caching for repeated contexts
   - Batch requests where possible
   - Monitor cost per request in production

4. **Security**
   - Input sanitization before prompt injection
   - Output validation before returning to users
   - Rate limiting on LLM endpoints
   - Never expose system prompts to end users
   - Test for jailbreak and extraction attacks

## Red Flags - STOP and Follow Process

If you catch yourself thinking:
- "It works in the playground, ship it"
- "Just tweak the wording a bit"
- "We don't need an eval set for this"
- "The prompt is simple enough"
- "We'll add evaluation later"
- "Same prompt works across models"
- "Users won't try to break it"
- "Cost doesn't matter, use the biggest model"
- "Just add more examples to fix it"
- "The model should figure it out"

**ALL of these mean: STOP. Return to Phase 1.**

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Works in the playground" | Playground tests 3-5 cases. Production sees thousands of edge cases. |
| "Simple prompt, no eval needed" | Simple prompts fail on edge cases you haven't imagined. Evaluate. |
| "We'll add tests later" | Later means after the first production incident. Test now. |
| "Same prompt works across models" | Models have different behaviors. Re-evaluate on every model change. |
| "Just add more few-shot examples" | More examples without evaluation is guess-and-check. Measure first. |
| "Users won't try to break it" | Users will absolutely try to break it. Test adversarial inputs. |
| "Cost doesn't matter" | Cost scales with traffic. A 2x token reduction saves thousands. |
| "Bigger model fixes everything" | Bigger model with a bad prompt is still bad. Fix the prompt. |
| "LLM evaluation is unreliable" | LLM-as-judge with good rubrics correlates well with human eval. Calibrate it. |
| "Prompt engineering isn't real engineering" | Untested prompts are untested code. Same discipline applies. |

## Anti-Patterns

| Anti-Pattern | Consequence | Correct Approach |
|-------------|-------------|-----------------|
| **Untested prompts in production** | Silent failures, inconsistent outputs, user complaints | Evaluation dataset, automated testing |
| **No evaluation metrics** | Can't measure improvement, can't detect regression | Define metrics per task type, track over time |
| **Prompt injection vulnerabilities** | Data leaks, unauthorized actions, system prompt exposure | Input sanitization, output validation, adversarial testing |
| **Vibes-based tuning** | Fixes one case, breaks three others | Systematic evaluation, regression testing |
| **No versioning** | Can't rollback, can't compare, can't reproduce | Version control prompts like code |
| **Model coupling** | Prompt breaks on model update or migration | Test across model versions, abstract model-specific syntax |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Design** | Define task, select pattern, structure prompt, design output | Clear prompt with explicit constraints |
| **2. Anthropic** | XML tags, prefilling, caching, extended thinking | Model-specific optimizations applied |
| **3. RAG** | Retrieval testing, context management, grounding | Faithful, cited, hallucination-resistant |
| **4. Evaluation** | Build eval set, define metrics, test failure modes | Meets accuracy targets, handles edge cases |
| **5. Operations** | Version, A/B test, optimize cost, secure | Versioned, monitored, cost-efficient, secure |

## Verification Checklist

Before deploying any prompt to production:

- [ ] Task precisely defined with valid/invalid output examples
- [ ] Prompt pattern selected with justification
- [ ] Output format specified and constrained
- [ ] Evaluation dataset created (minimum 20-50 examples)
- [ ] Metrics defined and measured
- [ ] Evaluation results meet defined thresholds
- [ ] Adversarial inputs tested (prompt injection, edge cases)
- [ ] Prompt versioned in source control
- [ ] Token usage and cost measured
- [ ] Model-specific optimizations applied (caching, prefilling)
- [ ] Security review completed (no prompt leakage, input sanitized)
- [ ] Rollback plan in place (previous prompt version ready)

Can't check all boxes? You're not ready to deploy.

## Integration with Other Skills

**This skill requires using:**
- **test-driven-development** - REQUIRED for building evaluation datasets and writing automated prompt tests

**Complementary skills:**
- **documentation-generation** - Document prompt design decisions, evaluation results, and versioning strategy
- **systematic-debugging** - Use when prompt behavior is inconsistent or outputs are unexpected

## Final Rule

```
No eval dataset → no production deployment
No metrics → no "improvement"
No version control → no prompt changes
```

Design. Test. Evaluate. Version. Deploy. Monitor. In that order. Always.

