#! /usr/bin/ruby -r yaml -r json
plist = YAML.load ARGF.read
plist['Label'] ||= ENV['LABEL']

plist.to_a.map &-> key, value {

  # Expand [any] $ENVIRONMENT_VARIABLES or ~/paths.
  expand = -> envar {
    if envar.is_a? String
      envar.gsub /\${?(\w+)}?/ do ENV[$1] end
    else envar
    end
  }

  plist[key] = case value
  when Hash then Hash[value.map &-> key ,value { [ key, expand[value]] }]
  when Array then value.map &expand
  when String then expand[value]
  else value
  end

  # Resolve [any] aliases.
  aliases = YAML.load_file "#{__dir__}/aliases.yml"
  aliases.map &-> replace, patterns {
    if patterns.any? &-> pattern { key[/#{pattern}/i] }
      plist[replace] = plist.delete key
    end
  }
}

print JSON[plist]
