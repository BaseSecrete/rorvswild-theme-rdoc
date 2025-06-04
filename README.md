# RoRvsWild theme for RDoc

[RDoc](https://github.com/ruby/rdoc) theme based on [RoRvsWild](https://www.rorvswild.com/) colors.
More than colors, it modifies the layout, navigation, typography and overall look and feel.
Also included in this repository is a script that generates [RubyRubyRubyRuby.dev](https://rubyrubyrubyruby.dev), a documentation website for Ruby, Rails, and a select group of gems.

![RoRvsWild theme RDoc Light](https://cdn.rorvswild.com/assets/blog/2024/rdoc_new-ad5d5ed01e18b11607278cdf97899209dfac8a752b2f0413e83b859b90f48009.png)

![RoRvsWild theme RDoc Dark](https://cdn.rorvswild.com/assets/blog/2024/rdoc_new_dark-06b332002ea3c7df9aafd2a5081fd901d0ca02450b4a002fda08acb4395b29e6.png)

## Usage

If you want to use this theme in your documentation:
```
# Install the gem
gem install rorvswild_theme_rdoc

# Generate the documentation
rdoc --root path/to/source/code --template rorvswild
```

## Development

Call the custom `rorvswild-theme-rdoc` script which automatically loads RoRvsWild's theme.

```
./rorvswild-theme-rdoc --root path/to/source/code
```
