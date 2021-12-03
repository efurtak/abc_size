# abc_size

Calculate ABC size, divided into methods defined in a single file.

## Installation with bundler - as a part of an application

Add this line to your application's Gemfile:

```ruby
gem 'abc_size', git: 'https://github.com/efurtak/abc_size'
```

And then execute:

```sh
bundle install
```

## Installation without bundler - as a local gem

If it works:

```sh
gem install abc_size -s 'https://github.com/efurtak/abc_size'
```

Otherwise:

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
```

## Contributing

Bug reports are welcome on GitHub at https://github.com/efurtak/abc_size.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
