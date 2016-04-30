# -*- mode: ruby -*-
if ENV['EMACS']
  Pry.config.pager = false
  Pry.config.correct_indent = false
  Pry.config.color = false
end

if defined?(PryByebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end
