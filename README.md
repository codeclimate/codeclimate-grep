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
      - def set_\w+
      - \.set_\w+
      output: "Found a deprecated set_ method"
```

`patterns` is a list of expressions you want to match. This engine uses [GNU
Extended Regular Expression syntax][] for patterns.

`output` is the message you will get on match.

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
