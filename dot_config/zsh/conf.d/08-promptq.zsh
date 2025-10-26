# ============================================================================
# Promptq Completions
# ============================================================================

_promptq() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments -C \
    '1: :->command' \
    '*:: :->args'

  case $state in
    command)
      local -a commands
      commands=(
        'add:Add prompt to queue'
        'list:List all queued prompts'
        'count:Show queue size'
        'send:Send first prompt (FIFO)'
        'select-send:Interactive send with fzf'
        'filter:Filter prompts by tag'
        'tags:List all tags with counts'
        'template:Template management'
        'snippet:Snippet management'
        'config:Configuration management'
        'clear:Clear all queued prompts'
        'clr:Clear all queued prompts (alias)'
        'help:Show help'
        'h:Show help (alias)'
        'version:Show version'
        'v:Show version (alias)'
      )
      _describe 'command' commands
      ;;

    args)
      case $words[1] in
        template)
          local -a template_commands
          template_commands=(
            'list:List available templates'
            'show:Show template content'
            'add:Add prompt from template'
          )
          _describe 'template command' template_commands
          ;;

        snippet)
          local -a snippet_commands
          snippet_commands=(
            'list:List available snippets'
            'show:Show snippet content'
            'add:Add prompt from snippet'
          )
          _describe 'snippet command' snippet_commands
          ;;

        config)
          local -a config_commands
          config_commands=(
            'set-pane:Set target tmux pane'
            'show-pane:Show current target pane'
          )
          _describe 'config command' config_commands
          ;;

        filter)
          # Complete with existing tags
          local -a tags
          if command -v promptq &>/dev/null; then
            tags=(${(f)"$(promptq tags 2>/dev/null | awk '{print $1}')"})
            _describe 'tag' tags
          fi
          ;;

        add)
          # For add command, allow free text input
          _message 'prompt text'
          ;;

        *)
          # No further completion
          ;;
      esac
      ;;
  esac
}

_register_promptq_completion() {
  if (( $+functions[compdef] )); then
    compdef _promptq promptq
    compdef _promptq ppq
  fi
}

# Register completion (deferred for performance)
zsh-defer _register_promptq_completion
