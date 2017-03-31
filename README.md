# Code Climate Grep Engine

[![Code
Climate](https://codeclimate.com/github/codeclimate/codeclimate-grep/badges/gpa.svg)](https://codeclimate.com/github/codeclimate/codeclimate-grep)

`codeclimate-grep` is a Code Climate engine that finds specified text and gives
a message.

Example config:

```
engines:
  grep:
    enabled: true
    config:
      patterns:
        no-set-methods:
          pattern: /def set_\w+/
          annotation: "Don't define methods that start with `set_`"
          severity: minor
          categories: Bug Risk
          content: >
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id
            urna eget libero fermentum bibendum. Duis dapibus, neque vel aliquet
            tincidunt, diam eros tempor neque
          path_patterns:
            - "**.rb"
```

`patterns` is a list of match configurations. Each key in it is an issue's check
name. Values are individual match configurations.

`pattern' is a required entry. It's a pattern to look for. This engine uses [GNU
Extended Regular Expression syntax][] for patterns.

`annotation` is a required entry. It's the issue description.

`severity` is an optional entry, default is `minor`. Possible values are `info`,
`minor`, `major`, `critical`, or `blocker`.

`categories` is an optional entry, defaults to `["Bug Risk"]`. It's a list of
categories this issue falls into. Maybe a string if you want to specify only one
category. Possible vallues are `Bug Risk`, `Clarity`, `Compatibility`,
`Complexity`, `Duplication`, `Performance`, `Security`, and `Style`.

`content` is an optional entry. It's an extended description of the issue.

`path\_patterns` is an optional entry, defaults to all scannable files. It's a
list of file path patterns (in shell glob syntax) to limit files this match is
applied to. This patterns are used as a filter agains `include\_paths`.

### Installation

1. If you haven't already, [install the Code Climate CLI][].
2. Run `codeclimate engines:enable grep`. This command both installs the engine
   and enables it in your `.codeclimate.yml` file.
3. Edit your `.codelcimate.yml` and add patterns and message.
3. You're ready to analyze! Browse into your project's folder and run
   `codeclimate analyze`.

### Need help?

If you're running into a Code Climate issue, first look over this project's
[GitHub Issues](https://github.com/codeclimate/codeclimate-grep/issues), as
your question may have already been covered. If not, [go ahead and open a
support ticket with us](https://codeclimate.com/help).

[GNU Extended Regular Expression syntax]: https://www.gnu.org/software/grep/manual/grep.html#Regular-Expressions
[install the Code Climate CLI]: https://github.com/codeclimate/codeclimate
