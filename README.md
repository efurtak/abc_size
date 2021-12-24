# abc_size

Calculate ABC size, divided into methods defined in a single file.

## Installation

From RubyGems

```sh
gem install abc_size
```

From GitHub

```sh
git clone https://github.com/efurtak/abc_size
```

```sh
cd abc_size
```

```sh
gem build abc_size.gemspec
```

```sh
gem install abc_size-*.gem
```

## Usage

```sh
abc [file] [options]
```

```
Options:
    -d, --discount    Discount repeated attributes
    -r, --ruby        Ruby version
```

Ruby code can be processed for specified Ruby version.

Default behavior is to detect it from `.ruby-version` file at working directory.
Alternatively it can be picked with `-r` or `--ruby` option.

## Contributing

Bug reports are welcome on GitHub at https://github.com/efurtak/abc_size.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
